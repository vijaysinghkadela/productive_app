import * as functions from 'firebase-functions';
import { Timestamp, FieldValue } from 'firebase-admin/firestore';
import { getFirestore, getAuth, getMessaging, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { UserDocument, SubscriptionTier } from '../shared/types/firestore.types';
import { cacheDelete } from '../shared/config/redis.config';
import { sendNotification, NotificationTemplates } from '../notifications/notifications.service';
import { checkAndUnlockAchievements } from '../achievements/achievements.engine';

// ─── Firestore onUpdate Trigger for users/{uid} ───
export const onUserDocumentUpdate = functions
  .region(REGION)
  .firestore.document('users/{uid}')
  .onUpdate(async (change, context) => {
    const uid = context.params.uid;
    const before = change.before.data() as UserDocument;
    const after = change.after.data() as UserDocument;
    const db = getFirestore();
    const now = Timestamp.now();

    try {
      // ─── 1. Subscription tier changed → update custom claims ───
      if (before.subscription.tier !== after.subscription.tier) {
        const currentClaims = (await getAuth().getUser(uid)).customClaims || {};
        await getAuth().setCustomUserClaims(uid, {
          ...currentClaims,
          tier: after.subscription.tier,
        });

        // Invalidate subscription cache
        await cacheDelete(`user:${uid}:subscription`);
        await cacheDelete(`user:${uid}:profile`);

        console.log(`User ${uid}: tier changed ${before.subscription.tier} → ${after.subscription.tier}`);

        // Update FCM topic subscriptions based on tier
        const tierTopics: Record<string, string[]> = {
          free: ['all_users', 'free_users'],
          basic: ['all_users', 'basic_users', 'paid_users'],
          pro: ['all_users', 'pro_users', 'paid_users'],
          elite: ['all_users', 'elite_users', 'paid_users'],
          lifetime: ['all_users', 'lifetime_users', 'paid_users'],
        };

        // Unsubscribe from old tier topics
        const oldTopics = tierTopics[before.subscription.tier] || [];
        const newTopics = tierTopics[after.subscription.tier] || [];
        const messaging = getMessaging();

        for (const token of after.fcmTokens) {
          for (const topic of oldTopics.filter((t) => !newTopics.includes(t))) {
            try {
              await messaging.unsubscribeFromTopic(token, topic);
            } catch { /* token may be invalid */ }
          }
          for (const topic of newTopics.filter((t) => !oldTopics.includes(t))) {
            try {
              await messaging.subscribeToTopic(token, topic);
            } catch { /* token may be invalid */ }
          }
        }
      }

      // ─── 2. Username changed → check uniqueness, update references ───
      if (before.username !== after.username) {
        // Verify uniqueness
        const existingUser = await db.collection(Collections.USERS)
          .where('username', '==', after.username)
          .limit(2)
          .get();

        const otherUsers = existingUser.docs.filter((d) => d.id !== uid);
        if (otherUsers.length > 0) {
          // Revert username change
          await change.after.ref.update({
            username: before.username,
            updatedAt: now,
          });
          console.error(`Username ${after.username} already taken, reverted for ${uid}`);
          return;
        }

        // Update leaderboard entries
        const periods = ['alltime'];
        const today = new Date();
        const weekNum = getWeekNumber(today);
        periods.push(
          `daily_${today.toISOString().split('T')[0]}`,
          `weekly_${today.getFullYear()}-W${String(weekNum).padStart(2, '0')}`,
          `monthly_${today.toISOString().slice(0, 7)}`,
        );

        const batch = db.batch();
        for (const period of periods) {
          const entryRef = db.collection(Collections.LEADERBOARD).doc(period)
            .collection(Collections.ENTRIES).doc(uid);
          batch.update(entryRef, {
            username: after.username,
            displayName: after.displayName,
            updatedAt: now,
          });
        }

        // Update accountability pairs
        const pairsSnap = await db.collection(Collections.ACCOUNTABILITY_PAIRS)
          .where('userIds', 'array-contains', uid).get();
        for (const pairDoc of pairsSnap.docs) {
          // Username stored in messages, not top-level — no batch needed
        }

        try { await batch.commit(); } catch { /* some entries may not exist */ }
        await cacheDelete(`user:${uid}:profile`);
        console.log(`User ${uid}: username changed ${before.username} → ${after.username}`);
      }

      // ─── 3. Notification settings changed → update FCM topic subscriptions ───
      if (JSON.stringify(before.settings.notifications) !== JSON.stringify(after.settings.notifications)) {
        const messaging = getMessaging();
        const settingsTopics: { key: keyof typeof after.settings.notifications; topic: string }[] = [
          { key: 'weeklyReport', topic: 'weekly_report' },
          { key: 'achievementAlerts', topic: 'achievement_alerts' },
          { key: 'challengeUpdates', topic: 'challenge_updates' },
          { key: 'aiInsights', topic: 'ai_insights' },
        ];

        for (const { key, topic } of settingsTopics) {
          const wasEnabled = before.settings.notifications[key];
          const isEnabled = after.settings.notifications[key];
          if (wasEnabled !== isEnabled) {
            for (const token of after.fcmTokens) {
              try {
                if (isEnabled) {
                  await messaging.subscribeToTopic(token, topic);
                } else {
                  await messaging.unsubscribeFromTopic(token, topic);
                }
              } catch { /* invalid token */ }
            }
          }
        }
      }

      // ─── 4. Level changed → notification + achievement check ───
      if (before.stats.level !== after.stats.level && after.stats.level > before.stats.level) {
        const tmpl = NotificationTemplates.levelUp(after.stats.level);
        await sendNotification({
          userId: uid,
          type: 'achievement',
          title: tmpl.title,
          body: tmpl.body,
          data: { level: after.stats.level.toString() },
        });

        await checkAndUnlockAchievements(uid, 'level_up', {
          userLevel: after.stats.level,
        });
      }

      // ─── 5. Streak changed to 0 → send streak broken notification ───
      if (before.stats.currentStreak > 0 && after.stats.currentStreak === 0) {
        const tmpl = NotificationTemplates.streakBroken();
        await sendNotification({
          userId: uid,
          type: 'streak_alert',
          title: tmpl.title,
          body: tmpl.body,
        });
      }

      // ─── 6. Streak milestones → notification + XP + achievements ───
      const streakMilestones = [3, 7, 14, 30, 60, 90, 180, 365];
      if (after.stats.currentStreak > before.stats.currentStreak) {
        for (const milestone of streakMilestones) {
          if (after.stats.currentStreak >= milestone && before.stats.currentStreak < milestone) {
            const tmpl = NotificationTemplates.streakMilestone(milestone);
            await sendNotification({
              userId: uid,
              type: 'streak_alert',
              title: tmpl.title,
              body: tmpl.body,
              data: { streak: milestone.toString() },
            });

            // Grant bonus XP for milestones
            const milestoneXp: Record<number, number> = {
              3: 50, 7: 100, 14: 200, 30: 500, 60: 1000, 90: 2000, 180: 5000, 365: 10000,
            };
            if (milestoneXp[milestone]) {
              await change.after.ref.update({
                'stats.totalXp': FieldValue.increment(milestoneXp[milestone]),
              });
            }

            await checkAndUnlockAchievements(uid, 'streak_updated', {
              currentStreak: after.stats.currentStreak,
            });
            break; // Only send for highest reached milestone
          }
        }
      }
    } catch (err) {
      console.error(`onUserDocumentUpdate failed for ${uid}:`, err);
    }
  });

function getWeekNumber(d: Date): number {
  const date = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
  date.setUTCDate(date.getUTCDate() + 4 - (date.getUTCDay() || 7));
  const yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
  return Math.ceil(((date.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
}

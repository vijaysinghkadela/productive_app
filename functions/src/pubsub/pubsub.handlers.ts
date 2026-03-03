import * as functions from 'firebase-functions';
import { getFirestore, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { checkAndUnlockAchievements } from '../achievements/achievements.engine';
import { sendNotification } from '../notifications/notifications.service';

const TOPICS = {
  USER_CREATED: 'user.created',
  USER_DELETED: 'user.deleted',
  SESSION_COMPLETED: 'session.completed',
  USAGE_SYNCED: 'usage.synced',
  ACHIEVEMENT_UNLOCKED: 'achievement.unlocked',
  SUBSCRIPTION_CHANGED: 'subscription.changed',
  CHALLENGE_COMPLETED: 'challenge.completed',
  REPORT_READY: 'report.ready',
  STREAK_MILESTONE: 'streak.milestone',
  LEVEL_UP: 'level.up',
};

// ─── Session Completed Handler ───
export const onSessionCompleted = functions
  .region(REGION)
  .pubsub.topic(TOPICS.SESSION_COMPLETED)
  .onPublish(async (message) => {
    const data = message.json as {
      userId: string;
      sessionId: string;
      durationMinutes: number;
      type: string;
      distractionCount: number;
      completionRate: number;
    };

    const {
      userId,
      sessionId,
      durationMinutes,
      type: _type,
      distractionCount,
      completionRate,
    } = data;
    const db = getFirestore();

    try {
      // Check session-based achievements
      const userSnap = await db.collection(Collections.USERS).doc(userId).get();
      const user = userSnap.data();
      if (!user) return;

      const triggerData: Record<string, unknown> = {
        durationMinutes,
        sessionsCompleted: user.stats?.totalSessionsCompleted || 0,
        totalFocusMinutes: user.stats?.totalFocusMinutes || 0,
        longestSessionMinutes: durationMinutes,
      };

      // Deep work check (120+ minutes)
      if (durationMinutes >= 120) {
        triggerData.deepSessionsCount = (user.stats?.deepSessionsCount || 0) + 1;
      }

      // Perfect session check
      if (distractionCount === 0 && completionRate === 100) {
        triggerData.perfectSessions = 1;
      }

      // Early bird / night owl
      const currentHour = new Date().getHours();
      if (currentHour < 8) triggerData.earlySessions = (user.stats?.earlySessions || 0) + 1;
      if (currentHour >= 21) triggerData.lateSessions = (user.stats?.lateSessions || 0) + 1;

      await checkAndUnlockAchievements(userId, 'session_completed', triggerData);

      console.log(`PubSub session.completed processed for ${userId}: ${sessionId}`);
    } catch (err) {
      console.error(`PubSub session.completed failed for ${userId}:`, err);
    }
  });

// ─── Usage Synced Handler ───
export const onUsageSynced = functions
  .region(REGION)
  .pubsub.topic(TOPICS.USAGE_SYNCED)
  .onPublish(async (message) => {
    const data = message.json as {
      userId: string;
      date: string;
      socialMediaMinutes: number;
      appsBlocked: number;
    };

    const { userId, date, socialMediaMinutes, appsBlocked } = data;

    try {
      const triggerData: Record<string, unknown> = {
        appsBlocked,
        socialMediaMinutes,
      };

      if (socialMediaMinutes === 0) {
        triggerData.socialFreeDays = 1;
        await checkAndUnlockAchievements(userId, 'social_media_free_day', triggerData);
      }

      await checkAndUnlockAchievements(userId, 'usage_synced', triggerData);

      console.log(`PubSub usage.synced processed for ${userId}: ${date}`);
    } catch (err) {
      console.error(`PubSub usage.synced failed for ${userId}:`, err);
    }
  });

// ─── Achievement Unlocked Handler ───
export const onAchievementUnlocked = functions
  .region(REGION)
  .pubsub.topic(TOPICS.ACHIEVEMENT_UNLOCKED)
  .onPublish(async (message) => {
    const data = message.json as {
      userId: string;
      achievementId: string;
      xpEarned: number;
      rarity: string;
    };

    const { userId, achievementId, xpEarned, rarity } = data;

    try {
      // Send enhanced notification for rare+ achievements
      if (['epic', 'legendary'].includes(rarity)) {
        await sendNotification({
          userId,
          type: 'achievement',
          title: `🏆 ${rarity === 'legendary' ? 'LEGENDARY' : 'EPIC'} Achievement!`,
          body: `You unlocked a ${rarity} achievement and earned ${xpEarned} XP!`,
          data: { achievementId, xpEarned: xpEarned.toString() },
        });
      }

      console.log(`PubSub achievement.unlocked processed: ${achievementId} for ${userId}`);
    } catch (err) {
      console.error(`PubSub achievement.unlocked failed:`, err);
    }
  });

// ─── Subscription Changed Handler ───
export const onSubscriptionChanged = functions
  .region(REGION)
  .pubsub.topic(TOPICS.SUBSCRIPTION_CHANGED)
  .onPublish(async (message) => {
    const data = message.json as {
      userId: string;
      previousTier: string;
      newTier: string;
      eventType: string;
    };

    const { userId, previousTier, newTier, eventType } = data;
    const _db = getFirestore();

    try {
      // Sync to BigQuery
      try {
        const { BigQuery } = await import('@google-cloud/bigquery');
        const bigquery = new BigQuery();
        const datasetId = process.env.BIGQUERY_DATASET_ID || 'focusguard_analytics';

        await bigquery
          .dataset(datasetId)
          .table('subscriptions')
          .insert([
            {
              userId,
              eventType,
              tier: newTier,
              previousTier,
              platform: 'revenuecat',
              eventDate: new Date().toISOString(),
            },
          ]);
      } catch {
        /* BigQuery sync is best-effort */
      }

      console.log(`PubSub subscription.changed: ${userId} ${previousTier} → ${newTier}`);
    } catch (err) {
      console.error(`PubSub subscription.changed failed:`, err);
    }
  });

// ─── Report Ready Handler ───
export const onReportReady = functions
  .region(REGION)
  .pubsub.topic(TOPICS.REPORT_READY)
  .onPublish(async (message) => {
    const data = message.json as {
      userId: string;
      reportId: string;
      type: 'weekly' | 'monthly';
    };

    try {
      await sendNotification({
        userId: data.userId,
        type: 'weekly_report',
        title: `📊 Your ${data.type} report is ready!`,
        body: `See how you performed and get personalized insights.`,
        data: { reportId: data.reportId, action: 'view_report' },
      });

      console.log(`PubSub report.ready: ${data.reportId} for ${data.userId}`);
    } catch (err) {
      console.error(`PubSub report.ready failed:`, err);
    }
  });

// ─── Level Up Handler ───
export const onLevelUp = functions
  .region(REGION)
  .pubsub.topic(TOPICS.LEVEL_UP)
  .onPublish(async (message) => {
    const data = message.json as {
      userId: string;
      newLevel: number;
      previousLevel: number;
    };

    try {
      await checkAndUnlockAchievements(data.userId, 'level_up', {
        userLevel: data.newLevel,
      });

      console.log(`PubSub level.up: ${data.userId} → Level ${data.newLevel}`);
    } catch (err) {
      console.error(`PubSub level.up failed:`, err);
    }
  });

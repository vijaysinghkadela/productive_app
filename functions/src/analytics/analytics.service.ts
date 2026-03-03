import * as functions from 'firebase-functions';
import { Timestamp } from 'firebase-admin/firestore';
import { getFirestore, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { DailyStatsDocument, UserDocument } from '../shared/types/firestore.types';

// BigQuery table schemas reference (for documentation and BigQuery setup)
export const BIGQUERY_SCHEMAS = {
  daily_stats: {
    fields: [
      { name: 'userId', type: 'STRING', mode: 'REQUIRED' },
      { name: 'date', type: 'DATE', mode: 'REQUIRED' },
      { name: 'productivityScore', type: 'INTEGER' },
      { name: 'socialMediaMinutes', type: 'INTEGER' },
      { name: 'focusMinutes', type: 'INTEGER' },
      { name: 'sessionsCompleted', type: 'INTEGER' },
      { name: 'sessionsAbandoned', type: 'INTEGER' },
      { name: 'goalsMetCount', type: 'INTEGER' },
      { name: 'habitsCompleted', type: 'INTEGER' },
      { name: 'streak', type: 'INTEGER' },
      { name: 'totalScreenTimeMinutes', type: 'INTEGER' },
      { name: 'phonePickups', type: 'INTEGER' },
      { name: 'country', type: 'STRING' },
      { name: 'tier', type: 'STRING' },
      { name: 'level', type: 'INTEGER' },
      { name: 'xpEarned', type: 'INTEGER' },
      { name: 'syncedAt', type: 'TIMESTAMP', mode: 'REQUIRED' },
    ],
  },
  sessions: {
    fields: [
      { name: 'sessionId', type: 'STRING', mode: 'REQUIRED' },
      { name: 'userId', type: 'STRING', mode: 'REQUIRED' },
      { name: 'type', type: 'STRING' },
      { name: 'mode', type: 'STRING' },
      { name: 'durationMinutes', type: 'INTEGER' },
      { name: 'completionRate', type: 'FLOAT' },
      { name: 'distractionCount', type: 'INTEGER' },
      { name: 'xpEarned', type: 'INTEGER' },
      { name: 'status', type: 'STRING' },
      { name: 'date', type: 'DATE' },
      { name: 'hour', type: 'INTEGER' },
      { name: 'syncedAt', type: 'TIMESTAMP', mode: 'REQUIRED' },
    ],
  },
  subscriptions: {
    fields: [
      { name: 'userId', type: 'STRING', mode: 'REQUIRED' },
      { name: 'eventType', type: 'STRING', mode: 'REQUIRED' },
      { name: 'tier', type: 'STRING' },
      { name: 'previousTier', type: 'STRING' },
      { name: 'platform', type: 'STRING' },
      { name: 'eventDate', type: 'TIMESTAMP', mode: 'REQUIRED' },
    ],
  },
  ai_usage: {
    fields: [
      { name: 'userId', type: 'STRING', mode: 'REQUIRED' },
      { name: 'tokensUsed', type: 'INTEGER' },
      { name: 'messageCount', type: 'INTEGER' },
      { name: 'tier', type: 'STRING' },
      { name: 'date', type: 'DATE' },
      { name: 'syncedAt', type: 'TIMESTAMP', mode: 'REQUIRED' },
    ],
  },
  user_events: {
    fields: [
      { name: 'userId', type: 'STRING', mode: 'REQUIRED' },
      { name: 'eventName', type: 'STRING', mode: 'REQUIRED' },
      { name: 'eventParams', type: 'JSON' },
      { name: 'platform', type: 'STRING' },
      { name: 'appVersion', type: 'STRING' },
      { name: 'timestamp', type: 'TIMESTAMP', mode: 'REQUIRED' },
    ],
  },
  achievements: {
    fields: [
      { name: 'achievementId', type: 'STRING', mode: 'REQUIRED' },
      { name: 'userId', type: 'STRING', mode: 'REQUIRED' },
      { name: 'category', type: 'STRING' },
      { name: 'rarity', type: 'STRING' },
      { name: 'xpReward', type: 'INTEGER' },
      { name: 'unlockDate', type: 'DATE' },
      { name: 'syncedAt', type: 'TIMESTAMP', mode: 'REQUIRED' },
    ],
  },
  notifications: {
    fields: [
      { name: 'notificationId', type: 'STRING', mode: 'REQUIRED' },
      { name: 'userId', type: 'STRING', mode: 'REQUIRED' },
      { name: 'type', type: 'STRING' },
      { name: 'delivered', type: 'BOOLEAN' },
      { name: 'opened', type: 'BOOLEAN' },
      { name: 'actioned', type: 'BOOLEAN' },
      { name: 'date', type: 'DATE' },
      { name: 'syncedAt', type: 'TIMESTAMP', mode: 'REQUIRED' },
    ],
  },
};

// ─── Sync Daily Stats to BigQuery (Firestore trigger) ───
export const syncDailyStatsToBigQuery = functions
  .region(REGION)
  .firestore.document('users/{uid}/daily_stats/{date}')
  .onWrite(async (change, context) => {
    const uid = context.params.uid;
    const date = context.params.date;

    if (!change.after.exists) return; // Deleted — skip

    const stats = change.after.data() as DailyStatsDocument;
    const db = getFirestore();

    // Get user metadata for denormalization
    const userSnap = await db.collection(Collections.USERS).doc(uid).get();
    const user = userSnap.exists ? (userSnap.data() as UserDocument) : null;

    const goalsMetCount = Object.values(stats.goals || {}).filter((g) => g.met).length;
    const habitsCompleted = Object.values(stats.habits || {}).filter((h) => h.completed).length;

    const row = {
      userId: uid,
      date,
      productivityScore: stats.productivityScore?.final || 0,
      socialMediaMinutes: stats.socialMediaMinutes || 0,
      focusMinutes: stats.focusSessions?.totalMinutes || 0,
      sessionsCompleted: stats.focusSessions?.completed || 0,
      sessionsAbandoned: stats.focusSessions?.abandoned || 0,
      goalsMetCount,
      habitsCompleted,
      streak: user?.stats?.currentStreak || 0,
      totalScreenTimeMinutes: stats.totalScreenTimeMinutes || 0,
      phonePickups: stats.phonePickups || 0,
      country: user?.country || 'unknown',
      tier: user?.subscription?.tier || 'free',
      level: user?.stats?.level || 1,
      xpEarned: stats.xpEarned || 0,
      syncedAt: new Date().toISOString(),
    };

    try {
      const { BigQuery } = await import('@google-cloud/bigquery');
      const bigquery = new BigQuery();
      const datasetId = process.env.BIGQUERY_DATASET_ID || 'focusguard_analytics';

      await bigquery.dataset(datasetId).table('daily_stats').insert([row]);
      console.log(`BigQuery sync: daily_stats for ${uid}/${date}`);
    } catch (err: unknown) {
      // Log but don't fail the function — BigQuery inserts are best-effort
      const error = err as { name?: string; errors?: unknown[] };
      if (error.name === 'PartialFailureError') {
        console.error('BigQuery partial failure:', JSON.stringify(error.errors));
      } else {
        console.error('BigQuery sync failed:', err);
      }
    }
  });

// ─── Weekly Analytics Aggregation (Scheduled, Monday 2am UTC) ───
export const aggregateWeeklyAnalytics = functions
  .region(REGION)
  .runWith({ timeoutSeconds: 540, memory: '512MB' })
  .pubsub.schedule('0 2 * * 1')
  .timeZone('UTC')
  .onRun(async () => {
    const db = getFirestore();
    const now = new Date();
    const weekEnd = new Date(now);
    weekEnd.setDate(weekEnd.getDate() - 1);
    const weekStart = new Date(weekEnd);
    weekStart.setDate(weekStart.getDate() - 6);

    const weekEndStr = weekEnd.toISOString().split('T')[0];
    const weekStartStr = weekStart.toISOString().split('T')[0];

    // Aggregate platform metrics
    const usersSnap = await db
      .collection(Collections.USERS)
      .where('accountStatus', '==', 'active')
      .get();

    const metrics = {
      totalUsers: usersSnap.size,
      activeUsersThisWeek: 0,
      avgScore: 0,
      totalFocusHours: 0,
      totalSessions: 0,
      tierBreakdown: { free: 0, basic: 0, pro: 0, elite: 0, lifetime: 0 },
    };



    for (const userDoc of usersSnap.docs) {
      const user = userDoc.data() as UserDocument;
      const tier = user.subscription?.tier || 'free';
      if (tier in metrics.tierBreakdown) {
        metrics.tierBreakdown[tier as keyof typeof metrics.tierBreakdown]++;
      }

      if (user.stats?.lastActiveDate && user.stats.lastActiveDate >= weekStartStr) {
        metrics.activeUsersThisWeek++;
      }
    }

    // Store aggregated metrics in admin collection
    await db
      .collection('admin')
      .doc(`weekly_metrics_${weekEndStr}`)
      .set({
        ...metrics,
        weekStart: weekStartStr,
        weekEnd: weekEndStr,
        generatedAt: Timestamp.now(),
      });

    console.log(`Weekly analytics aggregated: ${metrics.activeUsersThisWeek} active users`);
  });

// ─── Cleanup Old Notifications (Scheduled, weekly Sunday midnight) ───
export const cleanupOldNotifications = functions
  .region(REGION)
  .runWith({ timeoutSeconds: 300 })
  .pubsub.schedule('0 0 * * 0')
  .timeZone('UTC')
  .onRun(async () => {
    const db = getFirestore();
    const ninetyDaysAgo = new Date(Date.now() - 90 * 86400000);
    const cutoffTimestamp = Timestamp.fromDate(ninetyDaysAgo);

    const usersSnap = await db
      .collection(Collections.USERS)
      .where('accountStatus', '==', 'active')
      .limit(500)
      .get();

    let deleted = 0;

    for (const userDoc of usersSnap.docs) {
      const notifsSnap = await db
        .collection(Collections.USERS)
        .doc(userDoc.id)
        .collection(Collections.NOTIFICATIONS)
        .where('createdAt', '<', cutoffTimestamp)
        .where('read', '==', true)
        .limit(100)
        .get();

      if (notifsSnap.empty) continue;

      const batch = db.batch();
      notifsSnap.docs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
      deleted += notifsSnap.size;
    }

    console.log(`Cleaned up ${deleted} old notifications`);
  });

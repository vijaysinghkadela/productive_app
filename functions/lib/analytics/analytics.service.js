"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.cleanupOldNotifications = exports.aggregateWeeklyAnalytics = exports.syncDailyStatsToBigQuery = exports.BIGQUERY_SCHEMAS = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
// BigQuery table schemas reference (for documentation and BigQuery setup)
exports.BIGQUERY_SCHEMAS = {
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
exports.syncDailyStatsToBigQuery = functions
    .region(firebase_config_1.REGION)
    .firestore.document('users/{uid}/daily_stats/{date}')
    .onWrite(async (change, context) => {
    const uid = context.params.uid;
    const date = context.params.date;
    if (!change.after.exists)
        return; // Deleted — skip
    const stats = change.after.data();
    const db = (0, firebase_config_1.getFirestore)();
    // Get user metadata for denormalization
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const user = userSnap.exists ? userSnap.data() : null;
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
        const { BigQuery } = await Promise.resolve().then(() => __importStar(require('@google-cloud/bigquery')));
        const bigquery = new BigQuery();
        const datasetId = process.env.BIGQUERY_DATASET_ID || 'focusguard_analytics';
        await bigquery.dataset(datasetId).table('daily_stats').insert([row]);
        console.log(`BigQuery sync: daily_stats for ${uid}/${date}`);
    }
    catch (err) {
        // Log but don't fail the function — BigQuery inserts are best-effort
        const error = err;
        if (error.name === 'PartialFailureError') {
            console.error('BigQuery partial failure:', JSON.stringify(error.errors));
        }
        else {
            console.error('BigQuery sync failed:', err);
        }
    }
});
// ─── Weekly Analytics Aggregation (Scheduled, Monday 2am UTC) ───
exports.aggregateWeeklyAnalytics = functions
    .region(firebase_config_1.REGION)
    .runWith({ timeoutSeconds: 540, memory: '512MB' })
    .pubsub.schedule('0 2 * * 1')
    .timeZone('UTC')
    .onRun(async () => {
    const db = (0, firebase_config_1.getFirestore)();
    const now = new Date();
    const weekEnd = new Date(now);
    weekEnd.setDate(weekEnd.getDate() - 1);
    const weekStart = new Date(weekEnd);
    weekStart.setDate(weekStart.getDate() - 6);
    const weekEndStr = weekEnd.toISOString().split('T')[0];
    const weekStartStr = weekStart.toISOString().split('T')[0];
    // Aggregate platform metrics
    const usersSnap = await db
        .collection(collections_constants_1.Collections.USERS)
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
        const user = userDoc.data();
        const tier = user.subscription?.tier || 'free';
        if (tier in metrics.tierBreakdown) {
            metrics.tierBreakdown[tier]++;
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
        generatedAt: firestore_1.Timestamp.now(),
    });
    console.log(`Weekly analytics aggregated: ${metrics.activeUsersThisWeek} active users`);
});
// ─── Cleanup Old Notifications (Scheduled, weekly Sunday midnight) ───
exports.cleanupOldNotifications = functions
    .region(firebase_config_1.REGION)
    .runWith({ timeoutSeconds: 300 })
    .pubsub.schedule('0 0 * * 0')
    .timeZone('UTC')
    .onRun(async () => {
    const db = (0, firebase_config_1.getFirestore)();
    const ninetyDaysAgo = new Date(Date.now() - 90 * 86400000);
    const cutoffTimestamp = firestore_1.Timestamp.fromDate(ninetyDaysAgo);
    const usersSnap = await db
        .collection(collections_constants_1.Collections.USERS)
        .where('accountStatus', '==', 'active')
        .limit(500)
        .get();
    let deleted = 0;
    for (const userDoc of usersSnap.docs) {
        const notifsSnap = await db
            .collection(collections_constants_1.Collections.USERS)
            .doc(userDoc.id)
            .collection(collections_constants_1.Collections.NOTIFICATIONS)
            .where('createdAt', '<', cutoffTimestamp)
            .where('read', '==', true)
            .limit(100)
            .get();
        if (notifsSnap.empty)
            continue;
        const batch = db.batch();
        notifsSnap.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
        deleted += notifsSnap.size;
    }
    console.log(`Cleaned up ${deleted} old notifications`);
});
//# sourceMappingURL=analytics.service.js.map
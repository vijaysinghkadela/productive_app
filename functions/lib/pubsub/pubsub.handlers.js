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
exports.onLevelUp = exports.onReportReady = exports.onSubscriptionChanged = exports.onAchievementUnlocked = exports.onUsageSynced = exports.onSessionCompleted = void 0;
const functions = __importStar(require("firebase-functions"));
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const achievements_engine_1 = require("../achievements/achievements.engine");
const notifications_service_1 = require("../notifications/notifications.service");
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
exports.onSessionCompleted = functions
    .region(firebase_config_1.REGION)
    .pubsub.topic(TOPICS.SESSION_COMPLETED)
    .onPublish(async (message) => {
    const data = message.json;
    const { userId, sessionId, durationMinutes, distractionCount, completionRate, } = data;
    const db = (0, firebase_config_1.getFirestore)();
    try {
        // Check session-based achievements
        const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(userId).get();
        const user = userSnap.data();
        if (!user)
            return;
        const triggerData = {
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
        if (currentHour < 8)
            triggerData.earlySessions = (user.stats?.earlySessions || 0) + 1;
        if (currentHour >= 21)
            triggerData.lateSessions = (user.stats?.lateSessions || 0) + 1;
        await (0, achievements_engine_1.checkAndUnlockAchievements)(userId, 'session_completed', triggerData);
        console.log(`PubSub session.completed processed for ${userId}: ${sessionId}`);
    }
    catch (err) {
        console.error(`PubSub session.completed failed for ${userId}:`, err);
    }
});
// ─── Usage Synced Handler ───
exports.onUsageSynced = functions
    .region(firebase_config_1.REGION)
    .pubsub.topic(TOPICS.USAGE_SYNCED)
    .onPublish(async (message) => {
    const data = message.json;
    const { userId, date, socialMediaMinutes, appsBlocked } = data;
    try {
        const triggerData = {
            appsBlocked,
            socialMediaMinutes,
        };
        if (socialMediaMinutes === 0) {
            triggerData.socialFreeDays = 1;
            await (0, achievements_engine_1.checkAndUnlockAchievements)(userId, 'social_media_free_day', triggerData);
        }
        await (0, achievements_engine_1.checkAndUnlockAchievements)(userId, 'usage_synced', triggerData);
        console.log(`PubSub usage.synced processed for ${userId}: ${date}`);
    }
    catch (err) {
        console.error(`PubSub usage.synced failed for ${userId}:`, err);
    }
});
// ─── Achievement Unlocked Handler ───
exports.onAchievementUnlocked = functions
    .region(firebase_config_1.REGION)
    .pubsub.topic(TOPICS.ACHIEVEMENT_UNLOCKED)
    .onPublish(async (message) => {
    const data = message.json;
    const { userId, achievementId, xpEarned, rarity } = data;
    try {
        // Send enhanced notification for rare+ achievements
        if (['epic', 'legendary'].includes(rarity)) {
            await (0, notifications_service_1.sendNotification)({
                userId,
                type: 'achievement',
                title: `🏆 ${rarity === 'legendary' ? 'LEGENDARY' : 'EPIC'} Achievement!`,
                body: `You unlocked a ${rarity} achievement and earned ${xpEarned} XP!`,
                data: { achievementId, xpEarned: xpEarned.toString() },
            });
        }
        console.log(`PubSub achievement.unlocked processed: ${achievementId} for ${userId}`);
    }
    catch (err) {
        console.error(`PubSub achievement.unlocked failed:`, err);
    }
});
// ─── Subscription Changed Handler ───
exports.onSubscriptionChanged = functions
    .region(firebase_config_1.REGION)
    .pubsub.topic(TOPICS.SUBSCRIPTION_CHANGED)
    .onPublish(async (message) => {
    const data = message.json;
    const { userId, previousTier, newTier, eventType } = data;
    try {
        // Sync to BigQuery
        try {
            const { BigQuery } = await Promise.resolve().then(() => __importStar(require('@google-cloud/bigquery')));
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
        }
        catch {
            /* BigQuery sync is best-effort */
        }
        console.log(`PubSub subscription.changed: ${userId} ${previousTier} → ${newTier}`);
    }
    catch (err) {
        console.error(`PubSub subscription.changed failed:`, err);
    }
});
// ─── Report Ready Handler ───
exports.onReportReady = functions
    .region(firebase_config_1.REGION)
    .pubsub.topic(TOPICS.REPORT_READY)
    .onPublish(async (message) => {
    const data = message.json;
    try {
        await (0, notifications_service_1.sendNotification)({
            userId: data.userId,
            type: 'weekly_report',
            title: `📊 Your ${data.type} report is ready!`,
            body: `See how you performed and get personalized insights.`,
            data: { reportId: data.reportId, action: 'view_report' },
        });
        console.log(`PubSub report.ready: ${data.reportId} for ${data.userId}`);
    }
    catch (err) {
        console.error(`PubSub report.ready failed:`, err);
    }
});
// ─── Level Up Handler ───
exports.onLevelUp = functions
    .region(firebase_config_1.REGION)
    .pubsub.topic(TOPICS.LEVEL_UP)
    .onPublish(async (message) => {
    const data = message.json;
    try {
        await (0, achievements_engine_1.checkAndUnlockAchievements)(data.userId, 'level_up', {
            userLevel: data.newLevel,
        });
        console.log(`PubSub level.up: ${data.userId} → Level ${data.newLevel}`);
    }
    catch (err) {
        console.error(`PubSub level.up failed:`, err);
    }
});
//# sourceMappingURL=pubsub.handlers.js.map
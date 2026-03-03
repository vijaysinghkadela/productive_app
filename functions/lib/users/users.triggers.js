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
exports.onUserDocumentUpdate = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const redis_config_1 = require("../shared/config/redis.config");
const notifications_service_1 = require("../notifications/notifications.service");
const achievements_engine_1 = require("../achievements/achievements.engine");
// ─── Firestore onUpdate Trigger for users/{uid} ───
exports.onUserDocumentUpdate = functions
    .region(firebase_config_1.REGION)
    .firestore.document('users/{uid}')
    .onUpdate(async (change, context) => {
    const uid = context.params.uid;
    const before = change.before.data();
    const after = change.after.data();
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    try {
        // ─── 1. Subscription tier changed → update custom claims ───
        if (before.subscription.tier !== after.subscription.tier) {
            const currentClaims = (await (0, firebase_config_1.getAuth)().getUser(uid)).customClaims || {};
            await (0, firebase_config_1.getAuth)().setCustomUserClaims(uid, {
                ...currentClaims,
                tier: after.subscription.tier,
            });
            // Invalidate subscription cache
            await (0, redis_config_1.cacheDelete)(`user:${uid}:subscription`);
            await (0, redis_config_1.cacheDelete)(`user:${uid}:profile`);
            console.log(`User ${uid}: tier changed ${before.subscription.tier} → ${after.subscription.tier}`);
            // Update FCM topic subscriptions based on tier
            const tierTopics = {
                free: ['all_users', 'free_users'],
                basic: ['all_users', 'basic_users', 'paid_users'],
                pro: ['all_users', 'pro_users', 'paid_users'],
                elite: ['all_users', 'elite_users', 'paid_users'],
                lifetime: ['all_users', 'lifetime_users', 'paid_users'],
            };
            // Unsubscribe from old tier topics
            const oldTopics = tierTopics[before.subscription.tier] || [];
            const newTopics = tierTopics[after.subscription.tier] || [];
            const messaging = (0, firebase_config_1.getMessaging)();
            for (const token of after.fcmTokens) {
                for (const topic of oldTopics.filter((t) => !newTopics.includes(t))) {
                    try {
                        await messaging.unsubscribeFromTopic(token, topic);
                    }
                    catch {
                        /* token may be invalid */
                    }
                }
                for (const topic of newTopics.filter((t) => !oldTopics.includes(t))) {
                    try {
                        await messaging.subscribeToTopic(token, topic);
                    }
                    catch {
                        /* token may be invalid */
                    }
                }
            }
        }
        // ─── 2. Username changed → check uniqueness, update references ───
        if (before.username !== after.username) {
            // Verify uniqueness
            const existingUser = await db
                .collection(collections_constants_1.Collections.USERS)
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
            periods.push(`daily_${today.toISOString().split('T')[0]}`, `weekly_${today.getFullYear()}-W${String(weekNum).padStart(2, '0')}`, `monthly_${today.toISOString().slice(0, 7)}`);
            const batch = db.batch();
            for (const period of periods) {
                const entryRef = db
                    .collection(collections_constants_1.Collections.LEADERBOARD)
                    .doc(period)
                    .collection(collections_constants_1.Collections.ENTRIES)
                    .doc(uid);
                batch.update(entryRef, {
                    username: after.username,
                    displayName: after.displayName,
                    updatedAt: now,
                });
            }
            // Update accountability pairs
            // const pairsSnap = await db
            //   .collection(Collections.ACCOUNTABILITY_PAIRS)
            //   .where('userIds', 'array-contains', uid)
            //   .get();
            // for (const _pairDoc of pairsSnap.docs) {
            //   // Username stored in messages, not top-level — no batch needed
            // }
            try {
                await batch.commit();
            }
            catch {
                /* some entries may not exist */
            }
            await (0, redis_config_1.cacheDelete)(`user:${uid}:profile`);
            console.log(`User ${uid}: username changed ${before.username} → ${after.username}`);
        }
        // ─── 3. Notification settings changed → update FCM topic subscriptions ───
        if (JSON.stringify(before.settings.notifications) !==
            JSON.stringify(after.settings.notifications)) {
            const messaging = (0, firebase_config_1.getMessaging)();
            const settingsTopics = [
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
                            }
                            else {
                                await messaging.unsubscribeFromTopic(token, topic);
                            }
                        }
                        catch {
                            /* invalid token */
                        }
                    }
                }
            }
        }
        // ─── 4. Level changed → notification + achievement check ───
        if (before.stats.level !== after.stats.level && after.stats.level > before.stats.level) {
            const tmpl = notifications_service_1.NotificationTemplates.levelUp(after.stats.level);
            await (0, notifications_service_1.sendNotification)({
                userId: uid,
                type: 'achievement',
                title: tmpl.title,
                body: tmpl.body,
                data: { level: after.stats.level.toString() },
            });
            await (0, achievements_engine_1.checkAndUnlockAchievements)(uid, 'level_up', {
                userLevel: after.stats.level,
            });
        }
        // ─── 5. Streak changed to 0 → send streak broken notification ───
        if (before.stats.currentStreak > 0 && after.stats.currentStreak === 0) {
            const tmpl = notifications_service_1.NotificationTemplates.streakBroken();
            await (0, notifications_service_1.sendNotification)({
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
                    const tmpl = notifications_service_1.NotificationTemplates.streakMilestone(milestone);
                    await (0, notifications_service_1.sendNotification)({
                        userId: uid,
                        type: 'streak_alert',
                        title: tmpl.title,
                        body: tmpl.body,
                        data: { streak: milestone.toString() },
                    });
                    // Grant bonus XP for milestones
                    const milestoneXp = {
                        3: 50,
                        7: 100,
                        14: 200,
                        30: 500,
                        60: 1000,
                        90: 2000,
                        180: 5000,
                        365: 10000,
                    };
                    if (milestoneXp[milestone]) {
                        await change.after.ref.update({
                            'stats.totalXp': firestore_1.FieldValue.increment(milestoneXp[milestone]),
                        });
                    }
                    await (0, achievements_engine_1.checkAndUnlockAchievements)(uid, 'streak_updated', {
                        currentStreak: after.stats.currentStreak,
                    });
                    break; // Only send for highest reached milestone
                }
            }
        }
    }
    catch (err) {
        console.error(`onUserDocumentUpdate failed for ${uid}:`, err);
    }
});
function getWeekNumber(d) {
    const date = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
    date.setUTCDate(date.getUTCDate() + 4 - (date.getUTCDay() || 7));
    const yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
    return Math.ceil(((date.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
}
//# sourceMappingURL=users.triggers.js.map
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
exports.NotificationTemplates = exports.sendStreakReminders = void 0;
exports.sendNotification = sendNotification;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
/**
 * Send a notification to a user (FCM + Firestore)
 */
async function sendNotification(input) {
    const { userId, type, title, body, data = {} } = input;
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    // Check user notification preferences
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(userId).get();
    if (!userSnap.exists)
        return;
    const user = userSnap.data();
    const prefs = user.settings.notifications;
    if (!prefs.enabled)
        return;
    // Type-specific opt-in check
    const typeToSetting = {
        blocking_alert: prefs.blockingAlerts,
        goal_warning: prefs.goalWarnings,
        goal_achieved: prefs.goalWarnings,
        streak_alert: prefs.streakReminders,
        achievement: prefs.achievementAlerts,
        partner_activity: prefs.partnerActivity,
        challenge_update: prefs.challengeUpdates,
        weekly_report: prefs.weeklyReport,
        ai_insight: prefs.aiInsights,
        system: true,
        referral: true,
        bedtime: true,
    };
    if (typeToSetting[type] === false)
        return;
    // Check quiet hours
    const nowHour = new Date().getHours();
    const nowMinute = new Date().getMinutes();
    const nowTime = `${String(nowHour).padStart(2, '0')}:${String(nowMinute).padStart(2, '0')}`;
    if (prefs.quietHoursStart && prefs.quietHoursEnd) {
        const qStart = prefs.quietHoursStart;
        const qEnd = prefs.quietHoursEnd;
        if (qStart > qEnd) {
            // Crosses midnight (22:00 → 07:00)
            if (nowTime >= qStart || nowTime < qEnd) {
                if (type !== 'system')
                    return; // Don't send during quiet hours (except system)
            }
        }
        else {
            if (nowTime >= qStart && nowTime < qEnd) {
                if (type !== 'system')
                    return;
            }
        }
    }
    // Create Firestore notification document
    const notifRef = db
        .collection(collections_constants_1.Collections.USERS)
        .doc(userId)
        .collection(collections_constants_1.Collections.NOTIFICATIONS)
        .doc();
    let fcmMessageId = null;
    // Send via FCM if user has tokens
    if (user.fcmTokens.length > 0) {
        try {
            const messaging = (0, firebase_config_1.getMessaging)();
            const message = {
                notification: { title, body },
                data: { ...data, notificationId: notifRef.id, type },
                tokens: user.fcmTokens,
                android: {
                    priority: 'high',
                    notification: {
                        channelId: `focusguard_${type}`,
                        sound: 'default',
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: 'default',
                            badge: 1,
                            'content-available': 1,
                        },
                    },
                },
            };
            const response = await messaging.sendEachForMulticast(message);
            // Handle invalid tokens
            const invalidTokens = [];
            response.responses.forEach((resp, idx) => {
                if (!resp.success) {
                    const errCode = resp.error?.code;
                    if (errCode === 'messaging/invalid-registration-token' ||
                        errCode === 'messaging/registration-token-not-registered') {
                        invalidTokens.push(user.fcmTokens[idx]);
                    }
                }
                else {
                    fcmMessageId = resp.messageId || null;
                }
            });
            // Remove invalid tokens
            if (invalidTokens.length > 0) {
                const validTokens = user.fcmTokens.filter((t) => !invalidTokens.includes(t));
                await db.collection(collections_constants_1.Collections.USERS).doc(userId).update({
                    fcmTokens: validTokens,
                });
            }
        }
        catch (err) {
            console.error(`FCM send failed for user ${userId}:`, err);
        }
    }
    // Save notification document
    await notifRef.set({
        notificationId: notifRef.id,
        userId,
        type,
        title,
        body,
        data,
        read: false,
        readAt: null,
        actionTaken: null,
        fcmMessageId,
        deliveredAt: fcmMessageId ? now : null,
        createdAt: now,
    });
}
// ─── Streak Reminders (Scheduled, daily 8pm UTC) ───
exports.sendStreakReminders = functions
    .region(firebase_config_1.REGION)
    .pubsub.schedule('0 20 * * *')
    .timeZone('UTC')
    .onRun(async () => {
    const db = (0, firebase_config_1.getFirestore)();
    const today = new Date().toISOString().split('T')[0];
    // Get users with active streaks who haven't completed today's goals
    const usersSnap = await db
        .collection(collections_constants_1.Collections.USERS)
        .where('stats.currentStreak', '>', 0)
        .where('accountStatus', '==', 'active')
        .limit(500)
        .get();
    let sent = 0;
    for (const userDoc of usersSnap.docs) {
        const user = userDoc.data();
        // Check if they have activity today
        if (user.stats.lastActiveDate === today) {
            // They were active, check if goals are met
            const dailySnap = await db
                .collection(collections_constants_1.Collections.USERS)
                .doc(userDoc.id)
                .collection(collections_constants_1.Collections.DAILY_STATS)
                .doc(today)
                .get();
            if (dailySnap.exists) {
                const stats = dailySnap.data();
                if (stats.focusSessions?.completed > 0)
                    continue; // Already focused
            }
        }
        await sendNotification({
            userId: userDoc.id,
            type: 'streak_alert',
            title: `🔥 ${user.stats.currentStreak}-day streak at risk!`,
            body: 'Start a quick focus session to keep your streak alive!',
            data: { action: 'navigate', destination: '/focus' },
        });
        sent++;
    }
    console.log(`Sent ${sent} streak reminders`);
});
// ─── Notification templates ───
exports.NotificationTemplates = {
    welcomeUser: (name) => ({
        title: 'Welcome to FocusGuard Pro! 🎉',
        body: `Hey ${name}, your journey to better digital wellness starts now!`,
    }),
    goalWarning: (goalName, percentage) => ({
        title: `⚠️ ${goalName} at ${percentage}%`,
        body: `You're approaching your ${goalName} limit. Consider a focus session instead!`,
    }),
    goalExceeded: (goalName) => ({
        title: `🚫 ${goalName} exceeded`,
        body: `You've gone over your ${goalName} limit. Tomorrow is a new day!`,
    }),
    goalMet: (goalName) => ({
        title: `✅ ${goalName} achieved!`,
        body: `Great job staying within your ${goalName} limit!`,
    }),
    streakMilestone: (days) => ({
        title: `🔥 ${days}-day streak!`,
        body: `Incredible! You've maintained a ${days}-day focus streak!`,
    }),
    streakBroken: () => ({
        title: '💔 Streak broken',
        body: 'Your streak was broken, but every expert was once a beginner. Start fresh!',
    }),
    sessionComplete: (minutes, xp) => ({
        title: `🎯 ${minutes}min session complete!`,
        body: `You earned ${xp} XP. Keep the momentum going!`,
    }),
    achievementUnlocked: (name, xp) => ({
        title: `🏆 Achievement: ${name}`,
        body: `You unlocked "${name}" and earned ${xp} XP!`,
    }),
    weeklyReport: () => ({
        title: '📊 Your weekly report is ready!',
        body: 'See how you performed this week and get insights.',
    }),
    levelUp: (level) => ({
        title: `🎉 Level ${level}!`,
        body: `You've reached Level ${level}! Keep growing!`,
    }),
    partnerActivity: (partnerName, action) => ({
        title: `👋 ${partnerName} ${action}`,
        body: `Your accountability partner is making progress!`,
    }),
    bedtimeReminder: () => ({
        title: '🌙 Time to wind down',
        body: 'Put your phone away and get some rest. You deserve it!',
    }),
};
//# sourceMappingURL=notifications.service.js.map
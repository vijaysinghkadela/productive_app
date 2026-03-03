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
exports.getUsageAnalytics = exports.syncDailyUsage = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const common_validators_1 = require("../shared/validators/common.validators");
// ─── Sync Daily Usage (Callable) ───
exports.syncDailyUsage = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const parsed = common_validators_1.syncDailyUsageSchema.safeParse(data);
    if (!parsed.success) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid usage data', {
            errors: parsed.error.errors,
        });
    }
    const input = parsed.data;
    const now = firestore_1.Timestamp.now();
    // Only allow today or yesterday
    const today = new Date().toISOString().split('T')[0];
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    if (input.date !== today && input.date !== yesterday) {
        throw new functions.https.HttpsError('invalid-argument', 'Can only sync usage for today or yesterday');
    }
    const dailyRef = db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.DAILY_STATS)
        .doc(input.date);
    // Use transaction for idempotent merge
    const result = await db.runTransaction(async (tx) => {
        const existing = await tx.get(dailyRef);
        const existingData = existing.exists ? existing.data() : {};
        // Merge app usage (don't overwrite, merge per-app)
        const mergedAppUsage = { ...existingData.appUsage };
        let totalScreenTime = 0;
        let socialMediaMinutes = 0;
        let productiveMinutes = 0;
        let entertainmentMinutes = 0;
        let otherMinutes = 0;
        const socialCategories = ['social_media', 'messaging', 'social'];
        const productiveCategories = ['productivity', 'education', 'business', 'developer_tools'];
        const entertainmentCategories = ['entertainment', 'games', 'video', 'music'];
        for (const [appId, appData] of Object.entries(input.appUsage)) {
            mergedAppUsage[appId] = {
                appName: appData.appName,
                category: appData.category,
                totalMinutes: appData.totalMinutes,
                sessions: appData.sessions,
                firstUsed: appData.firstUsed,
                lastUsed: appData.lastUsed,
                hourlyMinutes: appData.hourlyMinutes,
                isBlocked: appData.isBlocked,
                goalMinutes: mergedAppUsage[appId]?.goalMinutes ?? null,
                goalExceeded: false, // Will be recalculated
                overrideCount: appData.overrideCount,
            };
            totalScreenTime += appData.totalMinutes;
            const cat = appData.category.toLowerCase();
            if (socialCategories.includes(cat))
                socialMediaMinutes += appData.totalMinutes;
            else if (productiveCategories.includes(cat))
                productiveMinutes += appData.totalMinutes;
            else if (entertainmentCategories.includes(cat))
                entertainmentMinutes += appData.totalMinutes;
            else
                otherMinutes += appData.totalMinutes;
        }
        // Merge hourly screen time
        const hourlyScreenTime = new Array(24).fill(0);
        for (const appData of Object.values(input.appUsage)) {
            for (let h = 0; h < 24; h++) {
                hourlyScreenTime[h] += appData.hourlyMinutes[h] || 0;
            }
        }
        // Check goals
        const goalsSnap = await db
            .collection(collections_constants_1.Collections.USERS)
            .doc(uid)
            .collection(collections_constants_1.Collections.GOALS)
            .where('status', '==', 'active')
            .get();
        const goalsExceeded = [];
        const approachingLimits = [];
        for (const goalDoc of goalsSnap.docs) {
            const goal = goalDoc.data();
            if (goal.type === 'app_limit' && goal.appId) {
                const usage = mergedAppUsage[goal.appId];
                if (usage) {
                    usage.goalMinutes = goal.targetValue;
                    if (usage.totalMinutes > goal.targetValue) {
                        usage.goalExceeded = true;
                        goalsExceeded.push(goal.name);
                    }
                    else if (usage.totalMinutes > goal.targetValue * 0.8) {
                        approachingLimits.push(goal.name);
                    }
                }
            }
        }
        const updateData = {
            date: input.date,
            userId: uid,
            appUsage: mergedAppUsage,
            totalScreenTimeMinutes: Math.round(totalScreenTime),
            socialMediaMinutes: Math.round(socialMediaMinutes),
            productiveMinutes: Math.round(productiveMinutes),
            entertainmentMinutes: Math.round(entertainmentMinutes),
            otherMinutes: Math.round(otherMinutes),
            hourlyScreenTime,
            phonePickups: input.phonePickups,
            hourlyPickups: input.hourlyPickups,
            firstPhoneUse: input.firstPhoneUse,
            lastPhoneUse: input.lastPhoneUse,
            updatedAt: now,
        };
        if (!existing.exists) {
            updateData.createdAt = now;
            updateData.focusSessions = {
                completed: 0,
                abandoned: 0,
                totalMinutes: 0,
                averageLength: 0,
                longestSession: 0,
            };
            updateData.goals = {};
            updateData.habits = {};
            updateData.mood = null;
            updateData.journalCompleted = false;
            updateData.gratitudeCompleted = false;
            updateData.xpEarned = 0;
            updateData.achievementsUnlocked = [];
            updateData.sleepData = {
                bedtime: null,
                wakeTime: null,
                quality: null,
                lateNightUsageMinutes: 0,
            };
            updateData.productivityScore = {
                final: 0,
                components: {
                    baseScore: 100,
                    socialMediaDeduction: 0,
                    screenTimeDeduction: 0,
                    overrideDeduction: 0,
                    abandonedSessionDeduction: 0,
                    habitDeduction: 0,
                    focusBonus: 0,
                    goalBonus: 0,
                    habitBonus: 0,
                    streakBonus: 0,
                    journalBonus: 0,
                    morningRoutineBonus: 0,
                    socialMediaFreeBonus: 0,
                },
                hourlySnapshots: [],
                calculatedAt: now,
            };
        }
        tx.set(dailyRef, updateData, { merge: true });
        return { goalsExceeded, approachingLimits };
    });
    // Update last active date
    await db.collection(collections_constants_1.Collections.USERS).doc(uid).update({
        'stats.lastActiveDate': input.date,
        updatedAt: now,
    });
    return {
        goalsExceeded: result.goalsExceeded,
        approachingLimits: result.approachingLimits,
        scoreChange: 0, // Will be recalculated async
    };
});
// ─── Get Usage Analytics (Callable) ───
exports.getUsageAnalytics = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { startDate, endDate, compareWithPrevious = false } = data;
    if (!startDate || !endDate) {
        throw new functions.https.HttpsError('invalid-argument', 'startDate and endDate required');
    }
    const statsSnap = await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.DAILY_STATS)
        .where('date', '>=', startDate)
        .where('date', '<=', endDate)
        .orderBy('date', 'desc')
        .get();
    const stats = statsSnap.docs.map((d) => d.data());
    // Aggregate per-app
    const appTotals = {};
    let totalScreenTime = 0;
    let totalSocialMedia = 0;
    let totalProductive = 0;
    const scores = [];
    // Hourly heatmap (7 days × 24 hours)
    const hourlyHeatmap = [];
    for (const stat of stats) {
        totalScreenTime += stat.totalScreenTimeMinutes;
        totalSocialMedia += stat.socialMediaMinutes;
        totalProductive += stat.productiveMinutes;
        if (stat.productivityScore?.final)
            scores.push(stat.productivityScore.final);
        hourlyHeatmap.push(stat.hourlyScreenTime || new Array(24).fill(0));
        for (const [appId, usage] of Object.entries(stat.appUsage)) {
            if (!appTotals[appId]) {
                appTotals[appId] = { appName: usage.appName, category: usage.category, totalMinutes: 0 };
            }
            appTotals[appId].totalMinutes += usage.totalMinutes;
        }
    }
    const avgScore = scores.length > 0 ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length) : 0;
    const topApps = Object.entries(appTotals)
        .sort(([, a], [, b]) => b.totalMinutes - a.totalMinutes)
        .slice(0, 10)
        .map(([appId, data]) => ({ appId, ...data }));
    let comparison = null;
    if (compareWithPrevious) {
        const daysDiff = Math.ceil((new Date(endDate).getTime() - new Date(startDate).getTime()) / (24 * 60 * 60 * 1000)) + 1;
        const prevStart = new Date(new Date(startDate).getTime() - daysDiff * 86400000)
            .toISOString()
            .split('T')[0];
        const prevEnd = new Date(new Date(startDate).getTime() - 86400000).toISOString().split('T')[0];
        const prevSnap = await db
            .collection(collections_constants_1.Collections.USERS)
            .doc(uid)
            .collection(collections_constants_1.Collections.DAILY_STATS)
            .where('date', '>=', prevStart)
            .where('date', '<=', prevEnd)
            .get();
        const prevStats = prevSnap.docs.map((d) => d.data());
        const prevScreenTime = prevStats.reduce((s, d) => s + d.totalScreenTimeMinutes, 0);
        const prevSocial = prevStats.reduce((s, d) => s + d.socialMediaMinutes, 0);
        const prevScores = prevStats
            .map((d) => d.productivityScore?.final)
            .filter((s) => s != null);
        const prevAvgScore = prevScores.length > 0
            ? Math.round(prevScores.reduce((a, b) => a + b, 0) / prevScores.length)
            : 0;
        comparison = {
            screenTimeChange: prevScreenTime > 0
                ? Math.round(((totalScreenTime - prevScreenTime) / prevScreenTime) * 100)
                : 0,
            socialMediaChange: prevSocial > 0 ? Math.round(((totalSocialMedia - prevSocial) / prevSocial) * 100) : 0,
            scoreChange: avgScore - prevAvgScore,
        };
    }
    return {
        totalScreenTime: Math.round(totalScreenTime),
        totalSocialMedia: Math.round(totalSocialMedia),
        totalProductive: Math.round(totalProductive),
        averageScore: avgScore,
        dailyAvgScreenTime: stats.length > 0 ? Math.round(totalScreenTime / stats.length) : 0,
        topApps,
        hourlyHeatmap,
        scores: stats.map((s) => ({
            date: s.date,
            score: s.productivityScore?.final || 0,
        })),
        comparison,
    };
});
//# sourceMappingURL=usage.service.js.map
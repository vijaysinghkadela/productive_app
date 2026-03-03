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
exports.generateMonthlyReport = exports.generateWeeklyReport = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const notifications_service_1 = require("../notifications/notifications.service");
// ─── Generate Weekly Report (Scheduled, Sunday 8pm UTC via Cloud Tasks) ───
exports.generateWeeklyReport = functions
    .region(firebase_config_1.REGION)
    .runWith({ timeoutSeconds: 540, memory: '1GB' })
    .pubsub.schedule('0 20 * * 0')
    .timeZone('UTC')
    .onRun(async () => {
    const db = (0, firebase_config_1.getFirestore)();
    const now = new Date();
    const weekEnd = now.toISOString().split('T')[0];
    // Calculate week start (7 days ago)
    const weekStartDate = new Date(now);
    weekStartDate.setDate(weekStartDate.getDate() - 7);
    const weekStart = weekStartDate.toISOString().split('T')[0];
    // Previous week for comparison
    const prevWeekEndDate = new Date(weekStartDate);
    prevWeekEndDate.setDate(prevWeekEndDate.getDate() - 1);
    const prevWeekEnd = prevWeekEndDate.toISOString().split('T')[0];
    const prevWeekStartDate = new Date(prevWeekEndDate);
    prevWeekStartDate.setDate(prevWeekStartDate.getDate() - 7);
    const prevWeekStart = prevWeekStartDate.toISOString().split('T')[0];
    // Get users with weekly report enabled
    const usersSnap = await db
        .collection(collections_constants_1.Collections.USERS)
        .where('settings.notifications.weeklyReport', '==', true)
        .where('accountStatus', '==', 'active')
        .limit(500)
        .get();
    let generated = 0;
    for (const userDoc of usersSnap.docs) {
        try {
            const uid = userDoc.id;
            const user = userDoc.data();
            // Fetch this week's daily stats
            const statsSnap = await db
                .collection(collections_constants_1.Collections.USERS)
                .doc(uid)
                .collection(collections_constants_1.Collections.DAILY_STATS)
                .where('date', '>=', weekStart)
                .where('date', '<=', weekEnd)
                .orderBy('date', 'asc')
                .get();
            if (statsSnap.empty)
                continue;
            const weekStats = statsSnap.docs.map((d) => d.data());
            // Fetch previous week's stats for comparison
            const prevStatsSnap = await db
                .collection(collections_constants_1.Collections.USERS)
                .doc(uid)
                .collection(collections_constants_1.Collections.DAILY_STATS)
                .where('date', '>=', prevWeekStart)
                .where('date', '<=', prevWeekEnd)
                .orderBy('date', 'asc')
                .get();
            const prevStats = prevStatsSnap.docs.map((d) => d.data());
            // Calculate metrics
            const scores = weekStats.map((s) => s.productivityScore?.final || 0);
            const avgScore = scores.length > 0 ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length) : 0;
            const bestScore = Math.max(...scores, 0);
            const worstScore = Math.min(...scores.filter((s) => s > 0), 100);
            const totalFocusMinutes = weekStats.reduce((s, d) => s + (d.focusSessions?.totalMinutes || 0), 0);
            const totalSessions = weekStats.reduce((s, d) => s + (d.focusSessions?.completed || 0), 0);
            const abandonedSessions = weekStats.reduce((s, d) => s + (d.focusSessions?.abandoned || 0), 0);
            const completionRate = totalSessions + abandonedSessions > 0
                ? Math.round((totalSessions / (totalSessions + abandonedSessions)) * 100)
                : 100;
            const socialMediaMinutes = weekStats.reduce((s, d) => s + d.socialMediaMinutes, 0);
            // Top distracting apps
            const appUsageTotals = {};
            for (const stat of weekStats) {
                for (const [appId, usage] of Object.entries(stat.appUsage || {})) {
                    if (usage.category === 'social_media' || usage.category === 'entertainment') {
                        if (!appUsageTotals[appId])
                            appUsageTotals[appId] = { appName: usage.appName, minutes: 0 };
                        appUsageTotals[appId].minutes += usage.totalMinutes;
                    }
                }
            }
            const topDistractingApps = Object.entries(appUsageTotals)
                .sort(([, a], [, b]) => b.minutes - a.minutes)
                .slice(0, 5)
                .map(([appId, data]) => ({ appId, appName: data.appName, minutes: data.minutes }));
            // Goals and habits
            const goalsMetCount = weekStats.reduce((s, d) => {
                let met = 0;
                for (const g of Object.values(d.goals || {})) {
                    if (g.met)
                        met++;
                }
                return s + met;
            }, 0);
            const goalsTotalCount = weekStats.reduce((s, d) => s + Object.keys(d.goals || {}).length, 0);
            const habitsCompleted = weekStats.reduce((s, d) => {
                let completed = 0;
                for (const h of Object.values(d.habits || {})) {
                    if (h.completed)
                        completed++;
                }
                return s + completed;
            }, 0);
            const habitsTotal = weekStats.reduce((s, d) => s + Object.keys(d.habits || {}).length, 0);
            const habitCompletionRate = habitsTotal > 0 ? Math.round((habitsCompleted / habitsTotal) * 100) : 100;
            // Achievements unlocked
            const achievementsUnlocked = weekStats.flatMap((s) => s.achievementsUnlocked || []);
            const xpEarned = weekStats.reduce((s, d) => s + d.xpEarned, 0);
            // Previous week comparison
            const prevScores = prevStats.map((s) => s.productivityScore?.final || 0);
            const prevAvgScore = prevScores.length > 0
                ? Math.round(prevScores.reduce((a, b) => a + b, 0) / prevScores.length)
                : 0;
            const prevFocusMinutes = prevStats.reduce((s, d) => s + (d.focusSessions?.totalMinutes || 0), 0);
            const prevSocialMinutes = prevStats.reduce((s, d) => s + d.socialMediaMinutes, 0);
            const prevGoalsMet = prevStats.reduce((s, d) => {
                let met = 0;
                for (const g of Object.values(d.goals || {})) {
                    if (g.met)
                        met++;
                }
                return s + met;
            }, 0);
            const socialMediaReduction = prevSocialMinutes > 0
                ? Math.round(((prevSocialMinutes - socialMediaMinutes) / prevSocialMinutes) * 100)
                : 0;
            // AI insight (Elite only)
            let aiInsightSummary = null;
            if (['elite', 'lifetime'].includes(user.subscription.tier)) {
                try {
                    const apiKey = await (0, firebase_config_1.getSecret)('openai-api-key');
                    const { default: OpenAI } = await Promise.resolve().then(() => __importStar(require('openai')));
                    const openai = new OpenAI({ apiKey });
                    const completion = await openai.chat.completions.create({
                        model: 'gpt-4o',
                        messages: [
                            {
                                role: 'system',
                                content: "You are a productivity coach. Generate a 2-3 sentence weekly insight summary based on the user's data. Be encouraging, specific, and actionable.",
                            },
                            {
                                role: 'user',
                                content: `Week summary: Avg score ${avgScore}/100, ${totalFocusMinutes}min focused, ${socialMediaMinutes}min social media, ${totalSessions} sessions, ${goalsMetCount}/${goalsTotalCount} goals met, ${habitCompletionRate}% habit completion, streak: ${user.stats.currentStreak}. Top distracting: ${topDistractingApps.map((a) => a.appName).join(', ')}. Score change: ${avgScore - prevAvgScore}.`,
                            },
                        ],
                        max_tokens: 150,
                        temperature: 0.7,
                    });
                    aiInsightSummary = completion.choices[0]?.message?.content || null;
                }
                catch (err) {
                    console.error(`AI insight failed for ${uid}:`, err);
                }
            }
            // Generate top recommendations
            const recommendations = [];
            if (avgScore < 60)
                recommendations.push('Try starting each day with a 25-minute focus session to build momentum.');
            if (socialMediaMinutes > 300)
                recommendations.push(`Your social media usage was ${Math.round(socialMediaMinutes / 60)}hr this week. Set a daily limit to reduce gradually.`);
            if (habitCompletionRate < 70)
                recommendations.push('Stack your habits — attach a new habit to one you already do consistently.');
            if (totalSessions < 5)
                recommendations.push('Aim for at least 1 focus session per day. Start with 15 minutes if 25 feels too long.');
            if (completionRate < 70)
                recommendations.push('You abandoned some sessions. Try shorter sessions if focus is difficult.');
            if (recommendations.length < 3)
                recommendations.push('Keep up the good work! Consistency is key to long-term productivity.');
            // Create report document
            const reportRef = db.collection(collections_constants_1.Collections.REPORTS).doc();
            const report = {
                reportId: reportRef.id,
                userId: uid,
                type: 'weekly',
                periodStart: firestore_1.Timestamp.fromDate(weekStartDate),
                periodEnd: firestore_1.Timestamp.fromDate(now),
                status: 'ready',
                data: {
                    productivityScores: weekStats.map((s) => ({
                        date: s.date,
                        score: s.productivityScore?.final || 0,
                    })),
                    averageScore: avgScore,
                    bestScore,
                    worstScore,
                    totalFocusMinutes,
                    totalSessionsCompleted: totalSessions,
                    sessionCompletionRate: completionRate,
                    topDistractingApps,
                    socialMediaMinutes,
                    socialMediaReduction,
                    goalsMetCount,
                    goalsTotalCount,
                    habitCompletionRate,
                    achievementsUnlocked,
                    xpEarned,
                    levelUps: 0,
                    streakHighlight: user.stats.currentStreak,
                    aiInsightSummary,
                    topRecommendations: recommendations,
                    comparisonToPrevious: {
                        scoreChange: avgScore - prevAvgScore,
                        focusChange: totalFocusMinutes - prevFocusMinutes,
                        socialMediaChange: socialMediaMinutes - prevSocialMinutes,
                        goalsChange: goalsMetCount - prevGoalsMet,
                    },
                },
                pdfUrl: null,
                emailSent: false,
                viewedAt: null,
                generatedAt: firestore_1.Timestamp.now(),
                createdAt: firestore_1.Timestamp.now(),
            };
            await reportRef.set(report);
            // Send notification
            const tmpl = notifications_service_1.NotificationTemplates.weeklyReport();
            await (0, notifications_service_1.sendNotification)({
                userId: uid,
                type: 'weekly_report',
                title: tmpl.title,
                body: tmpl.body,
                data: { reportId: reportRef.id, action: 'view_report' },
            });
            generated++;
        }
        catch (err) {
            console.error(`Report generation failed for ${userDoc.id}:`, err);
        }
    }
    console.log(`Generated ${generated} weekly reports`);
});
// ─── Generate Monthly Report (Scheduled, 1st of month 6am UTC) ───
exports.generateMonthlyReport = functions
    .region(firebase_config_1.REGION)
    .runWith({ timeoutSeconds: 540, memory: '1GB' })
    .pubsub.schedule('0 6 1 * *')
    .timeZone('UTC')
    .onRun(async () => {
    const db = (0, firebase_config_1.getFirestore)();
    const now = new Date();
    // Previous month
    const monthEnd = new Date(now.getFullYear(), now.getMonth(), 0);
    const monthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const monthEndStr = monthEnd.toISOString().split('T')[0];
    const monthStartStr = monthStart.toISOString().split('T')[0];
    // Month before for comparison
    const prevMonthEnd = new Date(monthStart);
    prevMonthEnd.setDate(prevMonthEnd.getDate() - 1);
    const usersSnap = await db
        .collection(collections_constants_1.Collections.USERS)
        .where('accountStatus', '==', 'active')
        .limit(500)
        .get();
    let generated = 0;
    for (const userDoc of usersSnap.docs) {
        try {
            const uid = userDoc.id;
            const statsSnap = await db
                .collection(collections_constants_1.Collections.USERS)
                .doc(uid)
                .collection(collections_constants_1.Collections.DAILY_STATS)
                .where('date', '>=', monthStartStr)
                .where('date', '<=', monthEndStr)
                .orderBy('date', 'asc')
                .get();
            if (statsSnap.size < 7)
                continue; // Need at least 7 days of data
            const monthStats = statsSnap.docs.map((d) => d.data());
            const scores = monthStats.map((s) => s.productivityScore?.final || 0);
            const avgScore = Math.round(scores.reduce((a, b) => a + b, 0) / scores.length);
            const totalFocusMinutes = monthStats.reduce((s, d) => s + (d.focusSessions?.totalMinutes || 0), 0);
            const socialMediaMinutes = monthStats.reduce((s, d) => s + d.socialMediaMinutes, 0);
            const reportRef = db.collection(collections_constants_1.Collections.REPORTS).doc();
            const report = {
                reportId: reportRef.id,
                userId: uid,
                type: 'monthly',
                periodStart: firestore_1.Timestamp.fromDate(monthStart),
                periodEnd: firestore_1.Timestamp.fromDate(monthEnd),
                status: 'ready',
                data: {
                    productivityScores: monthStats.map((s) => ({
                        date: s.date,
                        score: s.productivityScore?.final || 0,
                    })),
                    averageScore: avgScore,
                    bestScore: Math.max(...scores, 0),
                    worstScore: Math.min(...scores.filter((s) => s > 0), 100),
                    totalFocusMinutes,
                    totalSessionsCompleted: monthStats.reduce((s, d) => s + (d.focusSessions?.completed || 0), 0),
                    sessionCompletionRate: 0,
                    topDistractingApps: [],
                    socialMediaMinutes,
                    socialMediaReduction: 0,
                    goalsMetCount: 0,
                    goalsTotalCount: 0,
                    habitCompletionRate: 0,
                    achievementsUnlocked: monthStats.flatMap((s) => s.achievementsUnlocked || []),
                    xpEarned: monthStats.reduce((s, d) => s + d.xpEarned, 0),
                    levelUps: 0,
                    streakHighlight: 0,
                    aiInsightSummary: null,
                    topRecommendations: [],
                    comparisonToPrevious: {
                        scoreChange: 0,
                        focusChange: 0,
                        socialMediaChange: 0,
                        goalsChange: 0,
                    },
                },
                pdfUrl: null,
                emailSent: false,
                viewedAt: null,
                generatedAt: firestore_1.Timestamp.now(),
                createdAt: firestore_1.Timestamp.now(),
            };
            await reportRef.set(report);
            generated++;
        }
        catch (err) {
            console.error(`Monthly report failed for ${userDoc.id}:`, err);
        }
    }
    console.log(`Generated ${generated} monthly reports`);
});
//# sourceMappingURL=reports.service.js.map
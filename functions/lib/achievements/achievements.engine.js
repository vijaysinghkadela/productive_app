"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkAndUnlockAchievements = checkAndUnlockAchievements;
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const achievements_definitions_1 = require("./achievements.definitions");
const score_calculator_1 = require("../shared/utils/score.calculator");
const redis_config_1 = require("../shared/config/redis.config");
// Map trigger types to relevant achievement metric sources
const TRIGGER_METRIC_MAP = {
    session_completed: [
        'sessions_completed',
        'total_focus_minutes',
        'longest_session_minutes',
        'deep_sessions_count',
        'early_sessions',
        'late_sessions',
        'perfect_sessions',
    ],
    usage_synced: [
        'apps_blocked',
        'social_free_days',
        'social_free_streak',
        'monthly_social_minutes',
        'social_reduction_pct',
        'goal_under_50_days',
        'reels_blocked',
    ],
    goal_met: ['all_goals_met_streak'],
    habit_completed: [
        'daily_habits_completed',
        'habit_streak',
        'all_habits_week',
        'all_habits_month',
        'morning_free_days',
        'templates_used',
    ],
    streak_updated: ['current_streak', 'comeback_streak', 'no_skip_streak'],
    level_up: ['user_level'],
    challenge_completed: ['challenges_completed'],
    accountability_started: ['partner_days'],
    referral_completed: ['referral_count'],
    leaderboard_rank_changed: ['leaderboard_rank'],
    social_media_free_day: ['social_free_days', 'social_free_streak'],
    score_calculated: ['daily_score'],
};
/**
 * Check and unlock achievements based on a trigger
 */
async function checkAndUnlockAchievements(userId, triggerType, triggerData) {
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    // Load user's unlocked achievements (cached)
    const cacheKey = `user:${userId}:achievements`;
    let unlockedIds = await (0, redis_config_1.cacheGet)(cacheKey);
    if (!unlockedIds) {
        const achievSnap = await db
            .collection(collections_constants_1.Collections.USERS)
            .doc(userId)
            .collection(collections_constants_1.Collections.ACHIEVEMENTS)
            .get();
        unlockedIds = achievSnap.docs.map((d) => d.id);
        await (0, redis_config_1.cacheSet)(cacheKey, unlockedIds, 3600);
    }
    // Get relevant metrics for this trigger type
    const relevantMetrics = TRIGGER_METRIC_MAP[triggerType] || [];
    // Filter achievements that are relevant and not yet unlocked
    const candidates = achievements_definitions_1.ACHIEVEMENT_DEFINITIONS.filter((a) => !unlockedIds.includes(a.achievementId) && relevantMetrics.includes(a.condition.metric));
    if (candidates.length === 0)
        return [];
    // Load user data for evaluation
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(userId).get();
    if (!userSnap.exists)
        return [];
    const user = userSnap.data();
    const newlyUnlocked = [];
    for (const achievement of candidates) {
        let metricValue;
        // Resolve metric value from user stats or trigger data
        switch (achievement.condition.metric) {
            case 'sessions_completed':
                metricValue = user.stats.totalSessionsCompleted;
                break;
            case 'total_focus_minutes':
                metricValue = user.stats.totalFocusMinutes;
                break;
            case 'longest_session_minutes':
                metricValue = triggerData.durationMinutes || 0;
                break;
            case 'apps_blocked':
                metricValue = user.stats.totalAppsBlocked;
                break;
            case 'current_streak':
                metricValue = user.stats.currentStreak;
                break;
            case 'habits_created':
                metricValue = triggerData.habitsCount || 0;
                break;
            case 'daily_habits_completed':
                metricValue = triggerData.dailyHabitsCompleted || 0;
                break;
            case 'habit_streak':
                metricValue = triggerData.habitStreak || 0;
                break;
            case 'challenges_completed':
                metricValue = triggerData.challengesCompleted || 0;
                break;
            case 'partner_days':
                metricValue = triggerData.partnerDays || 0;
                break;
            case 'referral_count':
                metricValue = user.stats.referralCount;
                break;
            case 'leaderboard_rank':
                metricValue = triggerData.rank || Infinity;
                break;
            case 'user_level':
                metricValue = user.stats.level;
                break;
            case 'daily_score':
                metricValue = triggerData.score || 0;
                break;
            case 'social_free_days':
                metricValue = triggerData.socialFreeDays || 0;
                break;
            case 'social_free_streak':
                metricValue = triggerData.socialFreeStreak || 0;
                break;
            default:
                metricValue = triggerData[achievement.condition.metric] || 0;
        }
        if (metricValue === undefined)
            continue;
        // Evaluate condition
        let conditionMet = false;
        switch (achievement.condition.operator) {
            case 'gte':
                conditionMet = metricValue >= achievement.condition.value;
                break;
            case 'lte':
                conditionMet = metricValue <= achievement.condition.value;
                break;
            case 'eq':
                conditionMet = metricValue === achievement.condition.value;
                break;
            case 'special':
                // Special handling for OG user
                if (achievement.achievementId === 'og_user') {
                    const sixMonthsFromLaunch = new Date('2025-06-01');
                    conditionMet = user.createdAt.toDate() <= sixMonthsFromLaunch;
                }
                break;
        }
        if (conditionMet) {
            newlyUnlocked.push(achievement.achievementId);
            // Create achievement document
            const achievDoc = {
                achievementId: achievement.achievementId,
                userId,
                unlockedAt: now,
                xpEarned: achievement.xpReward,
                progress: 100,
                notified: false,
            };
            await db
                .collection(collections_constants_1.Collections.USERS)
                .doc(userId)
                .collection(collections_constants_1.Collections.ACHIEVEMENTS)
                .doc(achievement.achievementId)
                .set(achievDoc);
            // Grant XP
            const previousXp = user.stats.totalXp;
            const newXp = previousXp + achievement.xpReward;
            const levelResult = (0, score_calculator_1.checkLevelUp)(previousXp, newXp);
            const userUpdate = {
                'stats.totalXp': firestore_1.FieldValue.increment(achievement.xpReward),
                'stats.totalAchievementsUnlocked': firestore_1.FieldValue.increment(1),
                updatedAt: now,
            };
            if (levelResult.leveledUp) {
                userUpdate['stats.level'] = levelResult.newLevel;
                try {
                    const claims = (await (0, firebase_config_1.getAuth)().getUser(userId)).customClaims || {};
                    await (0, firebase_config_1.getAuth)().setCustomUserClaims(userId, { ...claims, level: levelResult.newLevel });
                }
                catch (e) {
                    console.error('Failed to update level claims:', e);
                }
            }
            await db.collection(collections_constants_1.Collections.USERS).doc(userId).update(userUpdate);
            // Create notification
            const notifRef = db
                .collection(collections_constants_1.Collections.USERS)
                .doc(userId)
                .collection(collections_constants_1.Collections.NOTIFICATIONS)
                .doc();
            await notifRef.set({
                notificationId: notifRef.id,
                userId,
                type: 'achievement',
                title: `🏆 Achievement Unlocked: ${achievement.name}`,
                body: achievement.unlockMessage,
                data: {
                    achievementId: achievement.achievementId,
                    xpEarned: achievement.xpReward.toString(),
                    rarity: achievement.rarity,
                },
                read: false,
                readAt: null,
                actionTaken: null,
                fcmMessageId: null,
                deliveredAt: null,
                createdAt: now,
            });
            // Update running XP for subsequent checks
            user.stats.totalXp = newXp;
            if (levelResult.leveledUp)
                user.stats.level = levelResult.newLevel;
        }
    }
    // Invalidate cache if any achievements unlocked
    if (newlyUnlocked.length > 0) {
        await (0, redis_config_1.cacheDelete)(cacheKey);
        console.log(`User ${userId}: Unlocked ${newlyUnlocked.length} achievements: ${newlyUnlocked.join(', ')}`);
    }
    return newlyUnlocked;
}
//# sourceMappingURL=achievements.engine.js.map
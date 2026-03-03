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
exports.beforeCreate = exports.beforeSignIn = exports.onUserDeleted = exports.onUserCreated = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const crypto_utils_1 = require("../shared/utils/crypto.utils");
// ─── onCreate Trigger ───
exports.onUserCreated = functions
    .region(firebase_config_1.REGION)
    .auth.user()
    .onCreate(async (user) => {
    const db = (0, firebase_config_1.getFirestore)();
    const batch = db.batch();
    const now = firestore_1.Timestamp.now();
    const today = new Date().toISOString().split('T')[0];
    try {
        // Generate unique username
        let username = (0, crypto_utils_1.generateUsername)(user.displayName || user.email?.split('@')[0] || 'user');
        let usernameExists = true;
        let attempts = 0;
        while (usernameExists && attempts < 5) {
            const snap = await db
                .collection(collections_constants_1.Collections.USERS)
                .where('username', '==', username)
                .limit(1)
                .get();
            usernameExists = !snap.empty;
            if (usernameExists)
                username = (0, crypto_utils_1.generateUsername)(user.displayName || 'user');
            attempts++;
        }
        // Generate referral code
        let referralCode = (0, crypto_utils_1.generateReferralCode)();
        let codeExists = true;
        attempts = 0;
        while (codeExists && attempts < 5) {
            const snap = await db.collection(collections_constants_1.Collections.REFERRALS).doc(referralCode).get();
            codeExists = snap.exists;
            if (codeExists)
                referralCode = (0, crypto_utils_1.generateReferralCode)();
            attempts++;
        }
        // Default subscription
        const subscription = {
            tier: 'free',
            status: 'active',
            trialEndsAt: null,
            currentPeriodStart: null,
            currentPeriodEnd: null,
            cancelAtPeriodEnd: false,
            revenuecatCustomerId: null,
            entitlements: [],
        };
        // Default stats
        const stats = {
            totalFocusMinutes: 0,
            totalSessionsCompleted: 0,
            totalAppsBlocked: 0,
            totalGoalsMet: 0,
            totalHabitsCompleted: 0,
            totalAchievementsUnlocked: 0,
            totalXp: 0,
            level: 1,
            currentStreak: 0,
            longestStreak: 0,
            lastActiveDate: today,
            accountabilityPartnersCount: 0,
            referralCount: 0,
        };
        // Default settings
        const settings = {
            notifications: {
                enabled: true,
                blockingAlerts: true,
                goalWarnings: true,
                streakReminders: true,
                achievementAlerts: true,
                weeklyReport: true,
                aiInsights: true,
                partnerActivity: true,
                challengeUpdates: true,
                quietHoursStart: '22:00',
                quietHoursEnd: '07:00',
                smartScheduling: true,
            },
            privacy: {
                showOnLeaderboard: true,
                showProfileToPartners: true,
                analyticsOptOut: false,
                shareUsageData: true,
            },
            app: {
                theme: 'dark',
                accentColor: '#6C63FF',
                fontSize: 'medium',
                hapticEnabled: true,
                reduceMotion: false,
            },
            blocking: {
                overlayTheme: 'motivational',
                gracePeriodMinutes: 5,
                cooldownAfterOverrides: 15,
                strictModeEnabled: false,
                strictModePinHash: null,
                biometricEnabled: false,
            },
            focus: {
                defaultSessionType: 'deep_work',
                defaultDuration: 25,
                autoStartBreak: true,
                endOfSessionSound: 'bell',
            },
        };
        // Create user document
        const userDoc = {
            uid: user.uid,
            email: user.email || '',
            emailVerified: user.emailVerified || false,
            displayName: user.displayName || '',
            username,
            avatarUrl: user.photoURL || null,
            avatarType: 'illustration',
            avatarId: null,
            bio: null,
            dateOfBirth: null,
            country: 'US',
            timezone: 'America/New_York',
            language: 'en',
            subscription,
            stats,
            settings,
            onboarding: {
                completed: false,
                completedAt: null,
                stepsCompleted: [],
                permissionsGranted: [],
            },
            termsAccepted: {
                version: '1.0.0',
                acceptedAt: now,
                ipAddress: '',
            },
            fcmTokens: [],
            devices: [],
            referralCode,
            referredBy: null,
            accountStatus: 'active',
            deletionScheduledAt: null,
            createdAt: now,
            updatedAt: now,
        };
        batch.set(db.collection(collections_constants_1.Collections.USERS).doc(user.uid), userDoc);
        // Create initial daily_stats
        const dailyStatsRef = db
            .collection(collections_constants_1.Collections.USERS)
            .doc(user.uid)
            .collection(collections_constants_1.Collections.DAILY_STATS)
            .doc(today);
        batch.set(dailyStatsRef, {
            date: today,
            userId: user.uid,
            appUsage: {},
            totalScreenTimeMinutes: 0,
            socialMediaMinutes: 0,
            productiveMinutes: 0,
            entertainmentMinutes: 0,
            otherMinutes: 0,
            hourlyScreenTime: new Array(24).fill(0),
            phonePickups: 0,
            hourlyPickups: new Array(24).fill(0),
            firstPhoneUse: null,
            lastPhoneUse: null,
            focusSessions: {
                completed: 0,
                abandoned: 0,
                totalMinutes: 0,
                averageLength: 0,
                longestSession: 0,
            },
            goals: {},
            habits: {},
            mood: null,
            journalCompleted: false,
            gratitudeCompleted: false,
            productivityScore: {
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
            },
            xpEarned: 0,
            achievementsUnlocked: [],
            sleepData: { bedtime: null, wakeTime: null, quality: null, lateNightUsageMinutes: 0 },
            createdAt: now,
            updatedAt: now,
        });
        // Create default goals
        const defaultGoals = [
            {
                name: 'Instagram Limit',
                appId: 'com.instagram.android',
                targetValue: 60,
                icon: '📸',
                color: '#E1306C',
            },
            {
                name: 'TikTok Limit',
                appId: 'com.zhiliaoapp.musically',
                targetValue: 30,
                icon: '🎵',
                color: '#000000',
            },
            {
                name: 'YouTube Limit',
                appId: 'com.google.android.youtube',
                targetValue: 90,
                icon: '▶️',
                color: '#FF0000',
            },
        ];
        for (const goal of defaultGoals) {
            const goalRef = db
                .collection(collections_constants_1.Collections.USERS)
                .doc(user.uid)
                .collection(collections_constants_1.Collections.GOALS)
                .doc();
            batch.set(goalRef, {
                goalId: goalRef.id,
                userId: user.uid,
                type: 'app_limit',
                name: goal.name,
                appId: goal.appId,
                category: 'social_media',
                targetValue: goal.targetValue,
                unit: 'minutes',
                frequency: 'daily',
                currentStreak: 0,
                longestStreak: 0,
                totalCompletions: 0,
                history: [],
                status: 'active',
                color: goal.color,
                icon: goal.icon,
                reminderEnabled: true,
                reminderTime: '20:00',
                aiSuggested: false,
                difficulty: 'medium',
                createdAt: now,
                updatedAt: now,
            });
        }
        // Create default habits
        const defaultHabits = [
            {
                name: 'No Phone First Hour',
                icon: '📵',
                color: '#6C63FF',
                category: 'digital_wellness',
            },
            {
                name: 'Phone-Free Meals',
                icon: '🍽️',
                color: '#00D4AA',
                category: 'digital_wellness',
            },
            { name: 'Evening Wind-Down', icon: '🌙', color: '#FF6B9D', category: 'sleep' },
            { name: '8hr Sleep', icon: '😴', color: '#4ECDC4', category: 'health' },
            { name: 'Morning Stretch', icon: '🧘', color: '#FFB347', category: 'health' },
        ];
        for (let i = 0; i < defaultHabits.length; i++) {
            const habitRef = db
                .collection(collections_constants_1.Collections.USERS)
                .doc(user.uid)
                .collection(collections_constants_1.Collections.HABITS)
                .doc();
            batch.set(habitRef, {
                habitId: habitRef.id,
                userId: user.uid,
                name: defaultHabits[i].name,
                description: null,
                icon: defaultHabits[i].icon,
                color: defaultHabits[i].color,
                category: defaultHabits[i].category,
                frequency: { type: 'daily', specificDays: null, timesPerWeek: null },
                reminderTime: '08:00',
                reminderDays: [0, 1, 2, 3, 4, 5, 6],
                currentStreak: 0,
                longestStreak: 0,
                totalCompletions: 0,
                totalSkips: 0,
                lastCompletedDate: null,
                completionHistory: [],
                stackedWith: null,
                isTemplate: false,
                templateId: null,
                status: 'active',
                order: i,
                xpPerCompletion: 25,
                createdAt: now,
                updatedAt: now,
            });
        }
        // Create referral document
        batch.set(db.collection(collections_constants_1.Collections.REFERRALS).doc(referralCode), {
            referralCode,
            ownerId: user.uid,
            uses: 0,
            maxUses: null,
            referredUsers: [],
            rewardType: 'free_month_basic',
            status: 'active',
            createdAt: now,
        });
        await batch.commit();
        // Set custom claims
        await (0, firebase_config_1.getAuth)().setCustomUserClaims(user.uid, { tier: 'free', level: 1 });
        // Send welcome notification (non-critical, don't block)
        try {
            const welcomeNotifRef = db
                .collection(collections_constants_1.Collections.USERS)
                .doc(user.uid)
                .collection(collections_constants_1.Collections.NOTIFICATIONS)
                .doc();
            await welcomeNotifRef.set({
                notificationId: welcomeNotifRef.id,
                userId: user.uid,
                type: 'system',
                title: 'Welcome to FocusGuard Pro! 🎉',
                body: 'Your journey to better digital wellness starts now. Set your first focus session!',
                data: { action: 'navigate', destination: '/focus' },
                read: false,
                readAt: null,
                actionTaken: null,
                fcmMessageId: null,
                deliveredAt: null,
                createdAt: now,
            });
        }
        catch (err) {
            console.error('Welcome notification failed:', err);
        }
        console.log(`User created: ${user.uid}, username: ${username}, referralCode: ${referralCode}`);
    }
    catch (error) {
        console.error(`Error creating user ${user.uid}:`, error);
        throw error;
    }
});
// ─── onDelete Trigger ───
exports.onUserDeleted = functions
    .region(firebase_config_1.REGION)
    .auth.user()
    .onDelete(async (user) => {
    const db = (0, firebase_config_1.getFirestore)();
    try {
        // Mark user as deleted
        const userRef = db.collection(collections_constants_1.Collections.USERS).doc(user.uid);
        await userRef.update({
            accountStatus: 'deleted',
            updatedAt: firestore_1.Timestamp.now(),
        });
        // Delete subcollections in batches
        const subcollections = [
            collections_constants_1.Collections.SESSIONS,
            collections_constants_1.Collections.DAILY_STATS,
            collections_constants_1.Collections.GOALS,
            collections_constants_1.Collections.HABITS,
            collections_constants_1.Collections.ACHIEVEMENTS,
            collections_constants_1.Collections.JOURNAL,
            collections_constants_1.Collections.NOTIFICATIONS,
            collections_constants_1.Collections.AI_CONVERSATIONS,
            collections_constants_1.Collections.BLOCKING_SCHEDULE,
            collections_constants_1.Collections.FOCUS_MODES,
        ];
        for (const sub of subcollections) {
            await deleteSubcollection(db, `${collections_constants_1.Collections.USERS}/${user.uid}/${sub}`);
        }
        // Remove from leaderboards
        const periods = ['daily', 'weekly', 'monthly', 'alltime'];
        for (const period of periods) {
            try {
                await db
                    .collection(collections_constants_1.Collections.LEADERBOARD)
                    .doc(period)
                    .collection(collections_constants_1.Collections.ENTRIES)
                    .doc(user.uid)
                    .delete();
            }
            catch {
                /* Entry may not exist */
            }
        }
        // Remove from accountability pairs
        const pairs = await db
            .collection(collections_constants_1.Collections.ACCOUNTABILITY_PAIRS)
            .where('userIds', 'array-contains', user.uid)
            .get();
        for (const pair of pairs.docs) {
            await pair.ref.update({ status: 'ended', updatedAt: firestore_1.Timestamp.now() });
        }
        // Remove from challenge participants
        const challenges = await db
            .collectionGroup(collections_constants_1.Collections.PARTICIPANTS)
            .where('userId', '==', user.uid)
            .get();
        for (const doc of challenges.docs) {
            await doc.ref.delete();
        }
        console.log(`User deleted: ${user.uid}, cleaned up all data`);
    }
    catch (error) {
        console.error(`Error deleting user ${user.uid}:`, error);
        throw error;
    }
});
// ─── beforeSignIn Blocking Function ───
exports.beforeSignIn = functions
    .region(firebase_config_1.REGION)
    .auth.user()
    .beforeSignIn(async (user) => {
    const db = (0, firebase_config_1.getFirestore)();
    const userDoc = await db.collection(collections_constants_1.Collections.USERS).doc(user.uid).get();
    if (userDoc.exists) {
        const data = userDoc.data();
        if (data.accountStatus === 'suspended') {
            throw new functions.auth.HttpsError('permission-denied', 'Your account has been suspended. Contact support@focusguard.app');
        }
        if (data.accountStatus === 'deleted') {
            throw new functions.auth.HttpsError('permission-denied', 'This account has been deleted.');
        }
        // Update last active date
        const today = new Date().toISOString().split('T')[0];
        await userDoc.ref.update({
            'stats.lastActiveDate': today,
            updatedAt: firestore_1.Timestamp.now(),
        });
    }
});
// ─── beforeCreate Blocking Function ───
exports.beforeCreate = functions
    .region(firebase_config_1.REGION)
    .auth.user()
    .beforeCreate(async (user) => {
    // Validate email
    const email = user.email;
    if (!email)
        return;
    // Check banned domains
    const bannedDomains = [
        'tempmail.com',
        'throwaway.email',
        'guerrillamail.com',
        'mailinator.com',
        'yopmail.com',
        'trashmail.com',
        'fakeinbox.com',
        'sharklasers.com',
        'guerrillamailblock.com',
    ];
    const domain = email.split('@')[1]?.toLowerCase();
    if (domain && bannedDomains.includes(domain)) {
        throw new functions.auth.HttpsError('invalid-argument', 'Email domain not allowed. Please use a valid email address.');
    }
});
// ─── Helper: Delete subcollection in batches ───
async function deleteSubcollection(db, path, batchSize = 100) {
    const collectionRef = db.collection(path);
    const query = collectionRef.orderBy('__name__').limit(batchSize);
    let deleted = 0;
    let snapshot = await query.get();
    while (!snapshot.empty) {
        const batch = db.batch();
        snapshot.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
        deleted += snapshot.size;
        if (snapshot.size < batchSize)
            break;
        snapshot = await query.get();
    }
    console.log(`Deleted ${deleted} docs from ${path}`);
}
//# sourceMappingURL=auth.triggers.js.map
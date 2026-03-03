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
exports.calculateHabitStreaks = exports.trackHabit = exports.createHabit = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const common_validators_1 = require("../shared/validators/common.validators");
const feature_flags_1 = require("../shared/constants/feature.flags");
// ─── Create Habit (Callable) ───
exports.createHabit = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const parsed = common_validators_1.createHabitSchema.safeParse(data);
    if (!parsed.success) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid habit data', {
            errors: parsed.error.errors,
        });
    }
    const input = parsed.data;
    const now = firestore_1.Timestamp.now();
    // Check subscription limits
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const tier = (userSnap.data()?.subscription?.tier || 'free');
    const limits = feature_flags_1.TierLimits[tier];
    const existingHabits = await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.HABITS)
        .where('status', '==', 'active')
        .get();
    if (existingHabits.size >= limits.habits) {
        throw new functions.https.HttpsError('resource-exhausted', `Habit limit (${limits.habits}) for ${tier} plan. Upgrade to create more habits.`);
    }
    // Validate stackedWith exists
    if (input.stackedWith) {
        const stackedRef = await db
            .collection(collections_constants_1.Collections.USERS)
            .doc(uid)
            .collection(collections_constants_1.Collections.HABITS)
            .doc(input.stackedWith)
            .get();
        if (!stackedRef.exists) {
            throw new functions.https.HttpsError('not-found', 'Stacked habit not found');
        }
    }
    const habitRef = db.collection(collections_constants_1.Collections.USERS).doc(uid).collection(collections_constants_1.Collections.HABITS).doc();
    const habit = {
        habitId: habitRef.id,
        userId: uid,
        name: input.name,
        description: input.description || null,
        icon: input.icon,
        color: input.color,
        category: input.category,
        frequency: {
            type: input.frequency.type,
            specificDays: input.frequency.specificDays || null,
            timesPerWeek: input.frequency.timesPerWeek || null,
        },
        reminderTime: input.reminderTime || null,
        reminderDays: input.reminderDays,
        currentStreak: 0,
        longestStreak: 0,
        totalCompletions: 0,
        totalSkips: 0,
        lastCompletedDate: null,
        completionHistory: [],
        stackedWith: input.stackedWith || null,
        isTemplate: false,
        templateId: null,
        status: 'active',
        order: existingHabits.size,
        xpPerCompletion: input.xpPerCompletion,
        createdAt: now,
        updatedAt: now,
    };
    await habitRef.set(habit);
    return { habitId: habitRef.id };
});
// ─── Track Habit (Callable) ───
exports.trackHabit = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const parsed = common_validators_1.trackHabitSchema.safeParse(data);
    if (!parsed.success) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid tracking data', {
            errors: parsed.error.errors,
        });
    }
    const input = parsed.data;
    const now = firestore_1.Timestamp.now();
    // Validate date within last 7 days
    const inputDate = new Date(input.date);
    const sevenDaysAgo = new Date(Date.now() - 7 * 86400000);
    if (inputDate < sevenDaysAgo) {
        throw new functions.https.HttpsError('invalid-argument', 'Cannot backdate more than 7 days');
    }
    const habitRef = db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.HABITS)
        .doc(input.habitId);
    const habitSnap = await habitRef.get();
    if (!habitSnap.exists) {
        throw new functions.https.HttpsError('not-found', 'Habit not found');
    }
    const habit = habitSnap.data();
    // Check idempotency — don't double-count
    const existingEntry = habit.completionHistory.find((h) => h.date === input.date);
    if (existingEntry && existingEntry.completed === input.completed) {
        return {
            newStreak: habit.currentStreak,
            xpEarned: 0,
            achievementUnlocked: null,
            message: 'Already tracked for this date',
        };
    }
    // Calculate new streak
    let newStreak = habit.currentStreak;
    let xpEarned = 0;
    if (input.completed) {
        // Check if yesterday was completed or skipped
        const yesterday = new Date(inputDate);
        yesterday.setDate(yesterday.getDate() - 1);
        const yesterdayStr = yesterday.toISOString().split('T')[0];
        const yesterdayEntry = habit.completionHistory.find((h) => h.date === yesterdayStr);
        if (yesterdayEntry && (yesterdayEntry.completed || yesterdayEntry.skipped)) {
            newStreak = habit.currentStreak + 1;
        }
        else if (habit.lastCompletedDate === yesterdayStr) {
            newStreak = habit.currentStreak + 1;
        }
        else {
            newStreak = 1; // New streak
        }
        xpEarned = habit.xpPerCompletion;
    }
    else if (input.skipped) {
        // Count skips this week
        const weekStart = new Date(inputDate);
        weekStart.setDate(weekStart.getDate() - weekStart.getDay());
        const weekStartStr = weekStart.toISOString().split('T')[0];
        const weekSkips = habit.completionHistory.filter((h) => h.date >= weekStartStr && h.date <= input.date && h.skipped).length;
        if (weekSkips < 2) {
            // Skip continues streak
            newStreak = habit.currentStreak;
        }
        else {
            newStreak = 0;
        }
    }
    else {
        newStreak = 0;
    }
    const longestStreak = Math.max(habit.longestStreak, newStreak);
    // Add completion entry
    const completionEntry = {
        date: input.date,
        completed: input.completed,
        skipped: input.skipped,
        completedAt: input.completed ? now : null,
        note: input.note || null,
    };
    // Update habit
    const updateData = {
        currentStreak: newStreak,
        longestStreak,
        updatedAt: now,
    };
    if (existingEntry) {
        // Replace existing entry
        const newHistory = habit.completionHistory.map((h) => h.date === input.date ? completionEntry : h);
        updateData.completionHistory = newHistory;
    }
    else {
        updateData.completionHistory = firestore_1.FieldValue.arrayUnion(completionEntry);
    }
    if (input.completed) {
        updateData.totalCompletions = firestore_1.FieldValue.increment(1);
        updateData.lastCompletedDate = input.date;
    }
    if (input.skipped) {
        updateData.totalSkips = firestore_1.FieldValue.increment(1);
    }
    await habitRef.update(updateData);
    // Update user stats and daily_stats
    if (xpEarned > 0) {
        const batch = db.batch();
        batch.update(db.collection(collections_constants_1.Collections.USERS).doc(uid), {
            'stats.totalHabitsCompleted': firestore_1.FieldValue.increment(1),
            'stats.totalXp': firestore_1.FieldValue.increment(xpEarned),
            updatedAt: now,
        });
        const dailyRef = db
            .collection(collections_constants_1.Collections.USERS)
            .doc(uid)
            .collection(collections_constants_1.Collections.DAILY_STATS)
            .doc(input.date);
        batch.set(dailyRef, {
            [`habits.${input.habitId}`]: {
                completed: true,
                completedAt: now,
                skipped: false,
            },
            xpEarned: firestore_1.FieldValue.increment(xpEarned),
            updatedAt: now,
        }, { merge: true });
        await batch.commit();
    }
    return {
        newStreak,
        xpEarned,
        achievementUnlocked: null,
    };
});
// ─── Calculate Habit Streaks (Scheduled, daily midnight UTC) ───
exports.calculateHabitStreaks = functions
    .region(firebase_config_1.REGION)
    .pubsub.schedule('0 0 * * *')
    .timeZone('UTC')
    .onRun(async () => {
    const db = (0, firebase_config_1.getFirestore)();
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    // Get users who were active yesterday
    const usersSnap = await db
        .collection(collections_constants_1.Collections.USERS)
        .where('stats.lastActiveDate', '>=', yesterday)
        .where('accountStatus', '==', 'active')
        .limit(500)
        .get();
    for (const userDoc of usersSnap.docs) {
        try {
            const uid = userDoc.id;
            const habitsSnap = await db
                .collection(collections_constants_1.Collections.USERS)
                .doc(uid)
                .collection(collections_constants_1.Collections.HABITS)
                .where('status', '==', 'active')
                .get();
            const batch = db.batch();
            for (const habitDoc of habitsSnap.docs) {
                const habit = habitDoc.data();
                const yesterdayEntry = habit.completionHistory.find((h) => h.date === yesterday);
                // If not completed and not skipped yesterday, reset streak
                if (!yesterdayEntry || (!yesterdayEntry.completed && !yesterdayEntry.skipped)) {
                    if (habit.currentStreak > 0) {
                        batch.update(habitDoc.ref, {
                            currentStreak: 0,
                            updatedAt: firestore_1.Timestamp.now(),
                        });
                    }
                }
            }
            await batch.commit();
        }
        catch (err) {
            console.error(`Streak calculation failed for user ${userDoc.id}:`, err);
        }
    }
    console.log(`Habit streaks calculated for ${usersSnap.size} users`);
});
//# sourceMappingURL=habits.service.js.map
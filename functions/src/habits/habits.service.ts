import * as functions from 'firebase-functions';
import { Timestamp, FieldValue } from 'firebase-admin/firestore';
import { getFirestore, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { createHabitSchema, trackHabitSchema } from '../shared/validators/common.validators';
import { TierLimits } from '../shared/constants/feature.flags';
import { HabitDocument, SubscriptionTier } from '../shared/types/firestore.types';

// ─── Create Habit (Callable) ───
export const createHabit = functions
  .region(REGION)
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();

    const parsed = createHabitSchema.safeParse(data);
    if (!parsed.success) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid habit data',
        { errors: parsed.error.errors });
    }

    const input = parsed.data;
    const now = Timestamp.now();

    // Check subscription limits
    const userSnap = await db.collection(Collections.USERS).doc(uid).get();
    const tier = (userSnap.data()?.subscription?.tier || 'free') as SubscriptionTier;
    const limits = TierLimits[tier];

    const existingHabits = await db.collection(Collections.USERS).doc(uid)
      .collection(Collections.HABITS).where('status', '==', 'active').get();

    if (existingHabits.size >= limits.habits) {
      throw new functions.https.HttpsError('resource-exhausted',
        `Habit limit (${limits.habits}) for ${tier} plan. Upgrade to create more habits.`);
    }

    // Validate stackedWith exists
    if (input.stackedWith) {
      const stackedRef = await db.collection(Collections.USERS).doc(uid)
        .collection(Collections.HABITS).doc(input.stackedWith).get();
      if (!stackedRef.exists) {
        throw new functions.https.HttpsError('not-found', 'Stacked habit not found');
      }
    }

    const habitRef = db.collection(Collections.USERS).doc(uid)
      .collection(Collections.HABITS).doc();

    const habit: HabitDocument = {
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
export const trackHabit = functions
  .region(REGION)
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();

    const parsed = trackHabitSchema.safeParse(data);
    if (!parsed.success) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid tracking data',
        { errors: parsed.error.errors });
    }

    const input = parsed.data;
    const now = Timestamp.now();

    // Validate date within last 7 days
    const inputDate = new Date(input.date);
    const sevenDaysAgo = new Date(Date.now() - 7 * 86400000);
    if (inputDate < sevenDaysAgo) {
      throw new functions.https.HttpsError('invalid-argument', 'Cannot backdate more than 7 days');
    }

    const habitRef = db.collection(Collections.USERS).doc(uid)
      .collection(Collections.HABITS).doc(input.habitId);
    const habitSnap = await habitRef.get();
    if (!habitSnap.exists) {
      throw new functions.https.HttpsError('not-found', 'Habit not found');
    }

    const habit = habitSnap.data() as HabitDocument;

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
      } else if (habit.lastCompletedDate === yesterdayStr) {
        newStreak = habit.currentStreak + 1;
      } else {
        newStreak = 1; // New streak
      }

      xpEarned = habit.xpPerCompletion;
    } else if (input.skipped) {
      // Count skips this week
      const weekStart = new Date(inputDate);
      weekStart.setDate(weekStart.getDate() - weekStart.getDay());
      const weekStartStr = weekStart.toISOString().split('T')[0];
      const weekSkips = habit.completionHistory.filter(
        (h) => h.date >= weekStartStr && h.date <= input.date && h.skipped,
      ).length;

      if (weekSkips < 2) {
        // Skip continues streak
        newStreak = habit.currentStreak;
      } else {
        newStreak = 0;
      }
    } else {
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
    const updateData: Record<string, unknown> = {
      currentStreak: newStreak,
      longestStreak,
      updatedAt: now,
    };

    if (existingEntry) {
      // Replace existing entry
      const newHistory = habit.completionHistory.map((h) =>
        h.date === input.date ? completionEntry : h,
      );
      updateData.completionHistory = newHistory;
    } else {
      updateData.completionHistory = FieldValue.arrayUnion(completionEntry);
    }

    if (input.completed) {
      updateData.totalCompletions = FieldValue.increment(1);
      updateData.lastCompletedDate = input.date;
    }
    if (input.skipped) {
      updateData.totalSkips = FieldValue.increment(1);
    }

    await habitRef.update(updateData);

    // Update user stats and daily_stats
    if (xpEarned > 0) {
      const batch = db.batch();
      batch.update(db.collection(Collections.USERS).doc(uid), {
        'stats.totalHabitsCompleted': FieldValue.increment(1),
        'stats.totalXp': FieldValue.increment(xpEarned),
        updatedAt: now,
      });

      const dailyRef = db.collection(Collections.USERS).doc(uid)
        .collection(Collections.DAILY_STATS).doc(input.date);
      batch.set(dailyRef, {
        [`habits.${input.habitId}`]: {
          completed: true,
          completedAt: now,
          skipped: false,
        },
        xpEarned: FieldValue.increment(xpEarned),
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
export const calculateHabitStreaks = functions
  .region(REGION)
  .pubsub.schedule('0 0 * * *')
  .timeZone('UTC')
  .onRun(async () => {
    const db = getFirestore();
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];

    // Get users who were active yesterday
    const usersSnap = await db.collection(Collections.USERS)
      .where('stats.lastActiveDate', '>=', yesterday)
      .where('accountStatus', '==', 'active')
      .limit(500)
      .get();

    for (const userDoc of usersSnap.docs) {
      try {
        const uid = userDoc.id;
        const habitsSnap = await db.collection(Collections.USERS).doc(uid)
          .collection(Collections.HABITS).where('status', '==', 'active').get();

        const batch = db.batch();

        for (const habitDoc of habitsSnap.docs) {
          const habit = habitDoc.data() as HabitDocument;
          const yesterdayEntry = habit.completionHistory.find((h) => h.date === yesterday);

          // If not completed and not skipped yesterday, reset streak
          if (!yesterdayEntry || (!yesterdayEntry.completed && !yesterdayEntry.skipped)) {
            if (habit.currentStreak > 0) {
              batch.update(habitDoc.ref, {
                currentStreak: 0,
                updatedAt: Timestamp.now(),
              });
            }
          }
        }

        await batch.commit();
      } catch (err) {
        console.error(`Streak calculation failed for user ${userDoc.id}:`, err);
      }
    }

    console.log(`Habit streaks calculated for ${usersSnap.size} users`);
  });

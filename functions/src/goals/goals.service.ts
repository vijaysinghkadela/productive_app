import * as functions from 'firebase-functions';
import { Timestamp, FieldValue } from 'firebase-admin/firestore';
import { getFirestore, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { setGoalSchema } from '../shared/validators/common.validators';
import { TierLimits } from '../shared/constants/feature.flags';
import { GoalDocument, SubscriptionTier } from '../shared/types/firestore.types';

// ─── Set Goal (Callable) ───
export const setGoal = functions
  .region(REGION)
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();

    const parsed = setGoalSchema.safeParse(data);
    if (!parsed.success) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid goal data',
        { errors: parsed.error.errors });
    }

    const input = parsed.data;
    const now = Timestamp.now();

    // Check subscription limits
    const userSnap = await db.collection(Collections.USERS).doc(uid).get();
    const tier = (userSnap.data()?.subscription?.tier || 'free') as SubscriptionTier;
    const limits = TierLimits[tier];

    const existingGoals = await db.collection(Collections.USERS).doc(uid)
      .collection(Collections.GOALS).where('status', '==', 'active').get();

    if (existingGoals.size >= limits.goals) {
      throw new functions.https.HttpsError('resource-exhausted',
        `Goal limit (${limits.goals}) exceeded for ${tier} plan. Upgrade to create more goals.`);
    }

    // Validate app_limit requires appId
    if (input.type === 'app_limit' && !input.appId) {
      throw new functions.https.HttpsError('invalid-argument',
        'App limit goals require an appId');
    }

    const goalRef = db.collection(Collections.USERS).doc(uid)
      .collection(Collections.GOALS).doc();

    const goal: GoalDocument = {
      goalId: goalRef.id,
      userId: uid,
      type: input.type,
      name: input.name,
      appId: input.appId || null,
      category: input.category || null,
      targetValue: input.targetValue,
      unit: input.unit,
      frequency: input.frequency,
      currentStreak: 0,
      longestStreak: 0,
      totalCompletions: 0,
      history: [],
      status: 'active',
      color: input.color,
      icon: input.icon,
      reminderEnabled: input.reminderEnabled,
      reminderTime: input.reminderTime || null,
      aiSuggested: false,
      difficulty: input.difficulty,
      createdAt: now,
      updatedAt: now,
    };

    await goalRef.set(goal);

    return { goalId: goalRef.id };
  });

// ─── Evaluate Goals at Day End (Scheduled) ───
export const evaluateGoalsAtDayEnd = functions
  .region(REGION)
  .pubsub.schedule('55 23 * * *')
  .timeZone('UTC')
  .onRun(async () => {
    const db = getFirestore();
    const today = new Date().toISOString().split('T')[0];

    // Get users active today (last active = today)
    const usersSnap = await db.collection(Collections.USERS)
      .where('stats.lastActiveDate', '==', today)
      .where('accountStatus', '==', 'active')
      .limit(500)
      .get();

    for (const userDoc of usersSnap.docs) {
      try {
        const uid = userDoc.id;

        // Get active goals
        const goalsSnap = await db.collection(Collections.USERS).doc(uid)
          .collection(Collections.GOALS).where('status', '==', 'active').get();

        // Get today's stats
        const statsSnap = await db.collection(Collections.USERS).doc(uid)
          .collection(Collections.DAILY_STATS).doc(today).get();

        if (!statsSnap.exists) continue;
        const stats = statsSnap.data()!;

        const batch = db.batch();
        let xpEarned = 0;
        let goalsMetCount = 0;

        for (const goalDoc of goalsSnap.docs) {
          const goal = goalDoc.data() as GoalDocument;
          let actualValue = 0;
          let met = false;

          // Calculate actual value based on goal type
          switch (goal.type) {
            case 'app_limit':
              if (goal.appId && stats.appUsage?.[goal.appId]) {
                actualValue = stats.appUsage[goal.appId].totalMinutes;
                met = actualValue <= goal.targetValue; // Under limit = met
              } else {
                met = true; // No usage = goal met
              }
              break;
            case 'focus_target':
              actualValue = stats.focusSessions?.totalMinutes || 0;
              met = actualValue >= goal.targetValue;
              break;
            case 'social_free_days':
              actualValue = stats.socialMediaMinutes === 0 ? 1 : 0;
              met = stats.socialMediaMinutes === 0;
              break;
            default:
              continue;
          }

          if (met) {
            goalsMetCount++;
            xpEarned += 50;
            // Update streak
            batch.update(goalDoc.ref, {
              currentStreak: FieldValue.increment(1),
              totalCompletions: FieldValue.increment(1),
              updatedAt: Timestamp.now(),
            });
          } else {
            // Reset streak
            batch.update(goalDoc.ref, {
              currentStreak: 0,
              updatedAt: Timestamp.now(),
            });
          }

          // Add to history
          const historyEntry = {
            date: today,
            targetValue: goal.targetValue,
            actualValue: Math.round(actualValue),
            met,
            xpEarned: met ? 50 : 0,
          };
          batch.update(goalDoc.ref, {
            history: FieldValue.arrayUnion(historyEntry),
          });
        }

        // Update user stats
        if (xpEarned > 0) {
          batch.update(db.collection(Collections.USERS).doc(uid), {
            'stats.totalGoalsMet': FieldValue.increment(goalsMetCount),
            'stats.totalXp': FieldValue.increment(xpEarned),
            updatedAt: Timestamp.now(),
          });
        }

        await batch.commit();
      } catch (err) {
        console.error(`Goal evaluation failed for user ${userDoc.id}:`, err);
      }
    }

    console.log(`Goals evaluated for ${usersSnap.size} users`);
  });

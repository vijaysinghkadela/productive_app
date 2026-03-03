import * as functions from 'firebase-functions';
import { Timestamp, FieldValue } from 'firebase-admin/firestore';
import { getFirestore, getAuth, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { SessionDocument } from '../shared/types/firestore.types';
import { endSessionSchema, createSessionSchema } from '../shared/validators/common.validators';
import { calculateSessionXp, checkLevelUp } from '../shared/utils/score.calculator';

import { v4 as uuidv4 } from 'uuid';

// ─── Create Session (Callable) ───
export const createSession = functions.region(REGION).https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const uid = context.auth.uid;
  const db = getFirestore();

  const parsed = createSessionSchema.safeParse(data);
  if (!parsed.success) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid session data', {
      errors: parsed.error.errors,
    });
  }

  const input = parsed.data;
  const now = Timestamp.now();
  const sessionId = uuidv4();

  const session: SessionDocument = {
    sessionId,
    userId: uid,
    type: input.type,
    mode: input.mode,
    plannedDurationMinutes: input.plannedDurationMinutes,
    actualDurationMinutes: 0,
    phases: [
      {
        phaseNumber: 1,
        type: 'work',
        plannedMinutes: input.plannedDurationMinutes,
        actualMinutes: 0,
        startedAt: now,
        endedAt: null,
        completed: false,
      },
    ],
    status: 'active',
    distractionCount: 0,
    distractionEvents: [],
    focusNote: null,
    ambientSound: input.ambientSound || null,
    xpEarned: 0,
    scoreImpact: 0,
    appsBlockedDuring: [],
    pauseEvents: [],
    completionRate: 0,
    focusModeId: input.focusModeId || null,
    deviceId: input.deviceId,
    startedAt: now,
    endedAt: null,
    createdAt: now,
    updatedAt: now,
  };

  await db
    .collection(Collections.USERS)
    .doc(uid)
    .collection(Collections.SESSIONS)
    .doc(sessionId)
    .set(session);

  return { sessionId, startedAt: now.toDate().toISOString() };
});

// ─── Complete Session (Callable) ───
export const completeSession = functions.region(REGION).https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const uid = context.auth.uid;
  const db = getFirestore();

  const parsed = endSessionSchema.safeParse(data);
  if (!parsed.success) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid session data', {
      errors: parsed.error.errors,
    });
  }

  const input = parsed.data;
  const now = Timestamp.now();
  const today = new Date().toISOString().split('T')[0];

  // Fetch session
  const sessionRef = db
    .collection(Collections.USERS)
    .doc(uid)
    .collection(Collections.SESSIONS)
    .doc(input.sessionId);
  const sessionSnap = await sessionRef.get();
  if (!sessionSnap.exists) {
    throw new functions.https.HttpsError('not-found', 'Session not found');
  }
  const session = sessionSnap.data() as SessionDocument;
  if (session.status !== 'active' && session.status !== 'paused') {
    throw new functions.https.HttpsError('failed-precondition', 'Session already ended');
  }

  // Calculate XP
  const completionRate =
    input.status === 'completed'
      ? Math.min(100, (input.actualDurationMinutes / session.plannedDurationMinutes) * 100)
      : (input.actualDurationMinutes / session.plannedDurationMinutes) * 100;

  const xpEarned =
    input.status === 'completed'
      ? calculateSessionXp(input.actualDurationMinutes, completionRate, input.distractionCount)
      : 0;

  const scoreImpact = input.status === 'completed' ? 8 : -5;

  // Update session
  await sessionRef.update({
    actualDurationMinutes: input.actualDurationMinutes,
    distractionCount: input.distractionCount,
    status: input.status,
    focusNote: input.focusNote || null,
    completionRate: Math.round(completionRate),
    xpEarned,
    scoreImpact,
    endedAt: now,
    updatedAt: now,
    ...(input.phases && {
      phases: input.phases.map((p) => ({
        ...p,
        startedAt: now, // placeholder since client doesn't provide full timestamps
        endedAt: now,
      })),
    }),
  });

  // Update user stats atomically
  const userRef = db.collection(Collections.USERS).doc(uid);
  const userSnap = await userRef.get();
  const previousXp = userSnap.data()?.stats?.totalXp || 0;
  const newTotalXp = previousXp + xpEarned;
  const levelResult = checkLevelUp(previousXp, newTotalXp);

  const statsUpdate: Record<string, unknown> = {
    'stats.totalFocusMinutes': FieldValue.increment(input.actualDurationMinutes),
    'stats.totalXp': FieldValue.increment(xpEarned),
    updatedAt: now,
  };

  if (input.status === 'completed') {
    statsUpdate['stats.totalSessionsCompleted'] = FieldValue.increment(1);
  }

  if (levelResult.leveledUp) {
    statsUpdate['stats.level'] = levelResult.newLevel;
    // Update custom claims with new level
    try {
      const currentClaims = (await getAuth().getUser(uid)).customClaims || {};
      await getAuth().setCustomUserClaims(uid, {
        ...currentClaims,
        level: levelResult.newLevel,
      });
    } catch (err) {
      console.error('Failed to update level claims:', err);
    }
  }

  await userRef.update(statsUpdate);

  // Update daily_stats
  const dailyRef = db
    .collection(Collections.USERS)
    .doc(uid)
    .collection(Collections.DAILY_STATS)
    .doc(today);

  const dailyUpdate: Record<string, unknown> = {
    updatedAt: now,
  };

  if (input.status === 'completed') {
    dailyUpdate['focusSessions.completed'] = FieldValue.increment(1);
    dailyUpdate['focusSessions.totalMinutes'] = FieldValue.increment(input.actualDurationMinutes);
  } else {
    dailyUpdate['focusSessions.abandoned'] = FieldValue.increment(1);
  }

  dailyUpdate['xpEarned'] = FieldValue.increment(xpEarned);

  await dailyRef.set(dailyUpdate, { merge: true });

  return {
    xpEarned,
    scoreImpact,
    newTotalXp,
    leveledUp: levelResult.leveledUp,
    newLevel: levelResult.newLevel,
    xpToNextLevel: levelResult.xpToNextLevel,
    achievements: [], // Placeholder — filled by achievement engine
  };
});

// ─── Get Session Analytics (Callable) ───
export const getSessionAnalytics = functions.region(REGION).https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const uid = context.auth.uid;
  const db = getFirestore();

  const { startDate, endDate, groupBy = 'day' } = data;
  if (!startDate || !endDate) {
    throw new functions.https.HttpsError('invalid-argument', 'startDate and endDate required');
  }

  // Query sessions in date range (max 90 days)
  const start = new Date(startDate);
  const end = new Date(endDate);
  const daysDiff = (end.getTime() - start.getTime()) / (24 * 60 * 60 * 1000);
  if (daysDiff > 90) {
    throw new functions.https.HttpsError('invalid-argument', 'Max 90 days range');
  }

  const sessionsSnap = await db
    .collection(Collections.USERS)
    .doc(uid)
    .collection(Collections.SESSIONS)
    .where('startedAt', '>=', Timestamp.fromDate(start))
    .where('startedAt', '<=', Timestamp.fromDate(end))
    .orderBy('startedAt', 'desc')
    .limit(500)
    .get();

  const sessions = sessionsSnap.docs.map((d) => d.data() as SessionDocument);

  // Aggregate
  const totalMinutes = sessions.reduce((sum, s) => sum + s.actualDurationMinutes, 0);
  const completedSessions = sessions.filter((s) => s.status === 'completed');
  const avgLength = completedSessions.length > 0 ? totalMinutes / completedSessions.length : 0;
  const completionRate =
    sessions.length > 0 ? (completedSessions.length / sessions.length) * 100 : 0;

  // Type breakdown
  const typeBreakdown: Record<string, { count: number; totalMinutes: number }> = {};
  for (const session of sessions) {
    if (!typeBreakdown[session.type]) {
      typeBreakdown[session.type] = { count: 0, totalMinutes: 0 };
    }
    typeBreakdown[session.type].count++;
    typeBreakdown[session.type].totalMinutes += session.actualDurationMinutes;
  }

  // Hourly distribution
  const hourlyDistribution = new Array(24).fill(0);
  for (const session of sessions) {
    const hour = session.startedAt.toDate().getHours();
    hourlyDistribution[hour]++;
  }

  return {
    totalMinutes: Math.round(totalMinutes),
    totalSessions: sessions.length,
    completedSessions: completedSessions.length,
    averageLength: Math.round(avgLength),
    completionRate: Math.round(completionRate),
    typeBreakdown,
    hourlyDistribution,
    totalXp: sessions.reduce((sum, s) => sum + s.xpEarned, 0),
  };
});

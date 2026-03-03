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
exports.getSessionAnalytics = exports.completeSession = exports.createSession = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const common_validators_1 = require("../shared/validators/common.validators");
const score_calculator_1 = require("../shared/utils/score.calculator");
const uuid_1 = require("uuid");
// ─── Create Session (Callable) ───
exports.createSession = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const parsed = common_validators_1.createSessionSchema.safeParse(data);
    if (!parsed.success) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid session data', {
            errors: parsed.error.errors,
        });
    }
    const input = parsed.data;
    const now = firestore_1.Timestamp.now();
    const sessionId = (0, uuid_1.v4)();
    const session = {
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
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.SESSIONS)
        .doc(sessionId)
        .set(session);
    return { sessionId, startedAt: now.toDate().toISOString() };
});
// ─── Complete Session (Callable) ───
exports.completeSession = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const parsed = common_validators_1.endSessionSchema.safeParse(data);
    if (!parsed.success) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid session data', {
            errors: parsed.error.errors,
        });
    }
    const input = parsed.data;
    const now = firestore_1.Timestamp.now();
    const today = new Date().toISOString().split('T')[0];
    // Fetch session
    const sessionRef = db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.SESSIONS)
        .doc(input.sessionId);
    const sessionSnap = await sessionRef.get();
    if (!sessionSnap.exists) {
        throw new functions.https.HttpsError('not-found', 'Session not found');
    }
    const session = sessionSnap.data();
    if (session.status !== 'active' && session.status !== 'paused') {
        throw new functions.https.HttpsError('failed-precondition', 'Session already ended');
    }
    // Calculate XP
    const completionRate = input.status === 'completed'
        ? Math.min(100, (input.actualDurationMinutes / session.plannedDurationMinutes) * 100)
        : (input.actualDurationMinutes / session.plannedDurationMinutes) * 100;
    const xpEarned = input.status === 'completed'
        ? (0, score_calculator_1.calculateSessionXp)(input.actualDurationMinutes, completionRate, input.distractionCount)
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
    const userRef = db.collection(collections_constants_1.Collections.USERS).doc(uid);
    const userSnap = await userRef.get();
    const previousXp = userSnap.data()?.stats?.totalXp || 0;
    const newTotalXp = previousXp + xpEarned;
    const levelResult = (0, score_calculator_1.checkLevelUp)(previousXp, newTotalXp);
    const statsUpdate = {
        'stats.totalFocusMinutes': firestore_1.FieldValue.increment(input.actualDurationMinutes),
        'stats.totalXp': firestore_1.FieldValue.increment(xpEarned),
        updatedAt: now,
    };
    if (input.status === 'completed') {
        statsUpdate['stats.totalSessionsCompleted'] = firestore_1.FieldValue.increment(1);
    }
    if (levelResult.leveledUp) {
        statsUpdate['stats.level'] = levelResult.newLevel;
        // Update custom claims with new level
        try {
            const currentClaims = (await (0, firebase_config_1.getAuth)().getUser(uid)).customClaims || {};
            await (0, firebase_config_1.getAuth)().setCustomUserClaims(uid, {
                ...currentClaims,
                level: levelResult.newLevel,
            });
        }
        catch (err) {
            console.error('Failed to update level claims:', err);
        }
    }
    await userRef.update(statsUpdate);
    // Update daily_stats
    const dailyRef = db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.DAILY_STATS)
        .doc(today);
    const dailyUpdate = {
        updatedAt: now,
    };
    if (input.status === 'completed') {
        dailyUpdate['focusSessions.completed'] = firestore_1.FieldValue.increment(1);
        dailyUpdate['focusSessions.totalMinutes'] = firestore_1.FieldValue.increment(input.actualDurationMinutes);
    }
    else {
        dailyUpdate['focusSessions.abandoned'] = firestore_1.FieldValue.increment(1);
    }
    dailyUpdate['xpEarned'] = firestore_1.FieldValue.increment(xpEarned);
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
exports.getSessionAnalytics = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { startDate, endDate } = data;
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
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.SESSIONS)
        .where('startedAt', '>=', firestore_1.Timestamp.fromDate(start))
        .where('startedAt', '<=', firestore_1.Timestamp.fromDate(end))
        .orderBy('startedAt', 'desc')
        .limit(500)
        .get();
    const sessions = sessionsSnap.docs.map((d) => d.data());
    // Aggregate
    const totalMinutes = sessions.reduce((sum, s) => sum + s.actualDurationMinutes, 0);
    const completedSessions = sessions.filter((s) => s.status === 'completed');
    const avgLength = completedSessions.length > 0 ? totalMinutes / completedSessions.length : 0;
    const completionRate = sessions.length > 0 ? (completedSessions.length / sessions.length) * 100 : 0;
    // Type breakdown
    const typeBreakdown = {};
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
//# sourceMappingURL=sessions.service.js.map
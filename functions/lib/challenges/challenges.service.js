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
exports.updateChallengeProgress = exports.getChallengeDetails = exports.withdrawChallenge = exports.joinChallenge = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const achievements_engine_1 = require("../achievements/achievements.engine");
// ─── Join Challenge (Callable) ───
exports.joinChallenge = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    const { challengeId } = data;
    if (!challengeId)
        throw new functions.https.HttpsError('invalid-argument', 'challengeId required');
    // Check subscription
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const tier = (userSnap.data()?.subscription?.tier || 'free');
    if (!['pro', 'elite', 'lifetime'].includes(tier)) {
        throw new functions.https.HttpsError('permission-denied', 'Challenges require Pro or Elite subscription');
    }
    // Validate challenge exists and is accepting participants
    const challengeRef = db.collection(collections_constants_1.Collections.CHALLENGES).doc(challengeId);
    const challengeSnap = await challengeRef.get();
    if (!challengeSnap.exists)
        throw new functions.https.HttpsError('not-found', 'Challenge not found');
    const challenge = challengeSnap.data();
    if (challenge.status !== 'active' && challenge.status !== 'upcoming') {
        throw new functions.https.HttpsError('failed-precondition', 'Challenge is not accepting participants');
    }
    // Check if already joined
    const participantRef = challengeRef.collection(collections_constants_1.Collections.PARTICIPANTS).doc(uid);
    const existingSnap = await participantRef.get();
    if (existingSnap.exists) {
        throw new functions.https.HttpsError('already-exists', 'Already joined this challenge');
    }
    // Create participant record
    const progress = {};
    for (const rule of challenge.rules) {
        progress[rule.ruleId] = {
            currentValue: 0,
            targetValue: rule.targetValue,
            percentage: 0,
            dailyHistory: [],
        };
    }
    const participant = {
        challengeId,
        userId: uid,
        status: 'active',
        progress,
        rank: 0,
        score: 0,
        completionPercentage: 0,
        joinedAt: now,
        completedAt: null,
        xpEarned: 0,
        updatedAt: now,
    };
    await participantRef.set(participant);
    // Increment participant count
    await challengeRef.update({
        participantCount: firestore_1.FieldValue.increment(1),
        updatedAt: now,
    });
    return { joined: true, challengeId };
});
// ─── Withdraw from Challenge (Callable) ───
exports.withdrawChallenge = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { challengeId } = data;
    if (!challengeId)
        throw new functions.https.HttpsError('invalid-argument', 'challengeId required');
    const participantRef = db
        .collection(collections_constants_1.Collections.CHALLENGES)
        .doc(challengeId)
        .collection(collections_constants_1.Collections.PARTICIPANTS)
        .doc(uid);
    const snap = await participantRef.get();
    if (!snap.exists)
        throw new functions.https.HttpsError('not-found', 'Not a participant');
    if (snap.data()?.status !== 'active') {
        throw new functions.https.HttpsError('failed-precondition', 'Cannot withdraw from completed/failed challenge');
    }
    await participantRef.update({
        status: 'withdrew',
        updatedAt: firestore_1.Timestamp.now(),
    });
    await db
        .collection(collections_constants_1.Collections.CHALLENGES)
        .doc(challengeId)
        .update({
        participantCount: firestore_1.FieldValue.increment(-1),
        updatedAt: firestore_1.Timestamp.now(),
    });
    return { withdrew: true };
});
// ─── Get Challenge Details with User Progress (Callable) ───
exports.getChallengeDetails = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { challengeId } = data;
    if (!challengeId)
        throw new functions.https.HttpsError('invalid-argument', 'challengeId required');
    const challengeSnap = await db.collection(collections_constants_1.Collections.CHALLENGES).doc(challengeId).get();
    if (!challengeSnap.exists)
        throw new functions.https.HttpsError('not-found', 'Challenge not found');
    // Get user's participation
    const participantSnap = await db
        .collection(collections_constants_1.Collections.CHALLENGES)
        .doc(challengeId)
        .collection(collections_constants_1.Collections.PARTICIPANTS)
        .doc(uid)
        .get();
    // Get top 10 participants
    const topParticipantsSnap = await db
        .collection(collections_constants_1.Collections.CHALLENGES)
        .doc(challengeId)
        .collection(collections_constants_1.Collections.PARTICIPANTS)
        .orderBy('score', 'desc')
        .limit(10)
        .get();
    const topParticipants = topParticipantsSnap.docs.map((d, idx) => ({
        userId: d.data().userId,
        score: d.data().score,
        completionPercentage: d.data().completionPercentage,
        rank: idx + 1,
    }));
    return {
        challenge: challengeSnap.data(),
        userParticipation: participantSnap.exists ? participantSnap.data() : null,
        topParticipants,
    };
});
// ─── Update Challenge Progress (Scheduled, runs daily midnight UTC) ───
exports.updateChallengeProgress = functions
    .region(firebase_config_1.REGION)
    .runWith({ timeoutSeconds: 540, memory: '1GB' })
    .pubsub.schedule('5 0 * * *')
    .timeZone('UTC')
    .onRun(async () => {
    const db = (0, firebase_config_1.getFirestore)();
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    const now = firestore_1.Timestamp.now();
    // Get active challenges
    const challengesSnap = await db
        .collection(collections_constants_1.Collections.CHALLENGES)
        .where('status', '==', 'active')
        .get();
    for (const challengeDoc of challengesSnap.docs) {
        const challenge = challengeDoc.data();
        // Check if challenge has ended
        if (challenge.endDate.toDate() < new Date()) {
            await challengeDoc.ref.update({ status: 'completed', updatedAt: now });
            // Finalize all participants
            const participantsSnap = await challengeDoc.ref
                .collection(collections_constants_1.Collections.PARTICIPANTS)
                .where('status', '==', 'active')
                .get();
            const batch = db.batch();
            for (const pDoc of participantsSnap.docs) {
                const p = pDoc.data();
                const completed = p.completionPercentage >= 100;
                batch.update(pDoc.ref, {
                    status: completed ? 'completed' : 'failed',
                    completedAt: completed ? now : null,
                    xpEarned: completed
                        ? challenge.xpReward
                        : Math.floor(((challenge.xpReward * p.completionPercentage) / 100) * 0.5),
                    updatedAt: now,
                });
                // Grant XP
                if (completed || p.completionPercentage > 0) {
                    const xp = completed
                        ? challenge.xpReward
                        : Math.floor(((challenge.xpReward * p.completionPercentage) / 100) * 0.5);
                    batch.update(db.collection(collections_constants_1.Collections.USERS).doc(p.userId), {
                        'stats.totalXp': firestore_1.FieldValue.increment(xp),
                        updatedAt: now,
                    });
                }
                // Check achievement
                if (completed) {
                    await (0, achievements_engine_1.checkAndUnlockAchievements)(p.userId, 'challenge_completed', {
                        challengesCompleted: (await db.collection(collections_constants_1.Collections.CHALLENGES).where('status', '==', 'completed').get()).size, // approximate
                    });
                }
            }
            await batch.commit();
            await challengeDoc.ref.update({
                completionCount: participantsSnap.docs.filter((d) => d.data().completionPercentage >= 100)
                    .length,
                updatedAt: now,
            });
            continue;
        }
        // Update daily progress for active participants
        const participantsSnap = await challengeDoc.ref
            .collection(collections_constants_1.Collections.PARTICIPANTS)
            .where('status', '==', 'active')
            .get();
        for (const pDoc of participantsSnap.docs) {
            const participant = pDoc.data();
            try {
                // Get yesterday's daily stats
                const statsSnap = await db
                    .collection(collections_constants_1.Collections.USERS)
                    .doc(participant.userId)
                    .collection(collections_constants_1.Collections.DAILY_STATS)
                    .doc(yesterday)
                    .get();
                if (!statsSnap.exists)
                    continue;
                const stats = statsSnap.data();
                const updatedProgress = { ...participant.progress };
                let totalPercentage = 0;
                let ruleCount = 0;
                for (const rule of challenge.rules) {
                    const rp = updatedProgress[rule.ruleId];
                    if (!rp)
                        continue;
                    // Resolve metric value from daily stats
                    let dailyValue = 0;
                    switch (rule.metricType) {
                        case 'focus_minutes':
                            dailyValue = stats.focusSessions?.totalMinutes || 0;
                            break;
                        case 'social_media_minutes':
                            dailyValue = stats.socialMediaMinutes || 0;
                            break;
                        case 'sessions_completed':
                            dailyValue = stats.focusSessions?.completed || 0;
                            break;
                        case 'screen_time_minutes':
                            dailyValue = stats.totalScreenTimeMinutes || 0;
                            break;
                        case 'productivity_score':
                            dailyValue = stats.productivityScore?.final || 0;
                            break;
                        default:
                            dailyValue = 0;
                    }
                    // Check daily rule
                    let dailyMet = false;
                    switch (rule.comparison) {
                        case 'gte':
                            dailyMet = dailyValue >= rule.targetValue;
                            break;
                        case 'lte':
                            dailyMet = dailyValue <= rule.targetValue;
                            break;
                        case 'eq':
                            dailyMet = dailyValue === rule.targetValue;
                            break;
                    }
                    // Track daily history
                    rp.dailyHistory.push({ date: yesterday, value: dailyValue, met: dailyMet });
                    // Update cumulative progress
                    if (rule.daily) {
                        const metDays = rp.dailyHistory.filter((d) => d.met).length;
                        rp.currentValue = metDays;
                        rp.percentage = Math.min(100, Math.round((metDays / challenge.durationDays) * 100));
                    }
                    else {
                        rp.currentValue += dailyValue;
                        rp.percentage = Math.min(100, Math.round((rp.currentValue / rp.targetValue) * 100));
                    }
                    totalPercentage += rp.percentage;
                    ruleCount++;
                }
                const overallPercentage = ruleCount > 0 ? Math.round(totalPercentage / ruleCount) : 0;
                const score = Math.round(overallPercentage * 10); // 0-1000
                await pDoc.ref.update({
                    progress: updatedProgress,
                    completionPercentage: overallPercentage,
                    score,
                    updatedAt: now,
                });
            }
            catch (err) {
                console.error(`Challenge progress update failed for ${participant.userId}:`, err);
            }
        }
        // Re-rank participants by score
        const rankedSnap = await challengeDoc.ref
            .collection(collections_constants_1.Collections.PARTICIPANTS)
            .where('status', '==', 'active')
            .orderBy('score', 'desc')
            .get();
        const rankBatch = db.batch();
        rankedSnap.docs.forEach((d, idx) => {
            rankBatch.update(d.ref, { rank: idx + 1 });
        });
        await rankBatch.commit();
    }
    console.log(`Challenge progress updated for ${challengesSnap.size} active challenges`);
});
//# sourceMappingURL=challenges.service.js.map
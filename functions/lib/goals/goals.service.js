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
exports.evaluateGoalsAtDayEnd = exports.setGoal = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const common_validators_1 = require("../shared/validators/common.validators");
const feature_flags_1 = require("../shared/constants/feature.flags");
// ─── Set Goal (Callable) ───
exports.setGoal = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const parsed = common_validators_1.setGoalSchema.safeParse(data);
    if (!parsed.success) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid goal data', {
            errors: parsed.error.errors,
        });
    }
    const input = parsed.data;
    const now = firestore_1.Timestamp.now();
    // Check subscription limits
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const tier = (userSnap.data()?.subscription?.tier || 'free');
    const limits = feature_flags_1.TierLimits[tier];
    const existingGoals = await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.GOALS)
        .where('status', '==', 'active')
        .get();
    if (existingGoals.size >= limits.goals) {
        throw new functions.https.HttpsError('resource-exhausted', `Goal limit (${limits.goals}) exceeded for ${tier} plan. Upgrade to create more goals.`);
    }
    // Validate app_limit requires appId
    if (input.type === 'app_limit' && !input.appId) {
        throw new functions.https.HttpsError('invalid-argument', 'App limit goals require an appId');
    }
    const goalRef = db.collection(collections_constants_1.Collections.USERS).doc(uid).collection(collections_constants_1.Collections.GOALS).doc();
    const goal = {
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
exports.evaluateGoalsAtDayEnd = functions
    .region(firebase_config_1.REGION)
    .pubsub.schedule('55 23 * * *')
    .timeZone('UTC')
    .onRun(async () => {
    const db = (0, firebase_config_1.getFirestore)();
    const today = new Date().toISOString().split('T')[0];
    // Get users active today (last active = today)
    const usersSnap = await db
        .collection(collections_constants_1.Collections.USERS)
        .where('stats.lastActiveDate', '==', today)
        .where('accountStatus', '==', 'active')
        .limit(500)
        .get();
    for (const userDoc of usersSnap.docs) {
        try {
            const uid = userDoc.id;
            // Get active goals
            const goalsSnap = await db
                .collection(collections_constants_1.Collections.USERS)
                .doc(uid)
                .collection(collections_constants_1.Collections.GOALS)
                .where('status', '==', 'active')
                .get();
            // Get today's stats
            const statsSnap = await db
                .collection(collections_constants_1.Collections.USERS)
                .doc(uid)
                .collection(collections_constants_1.Collections.DAILY_STATS)
                .doc(today)
                .get();
            if (!statsSnap.exists)
                continue;
            const stats = statsSnap.data();
            const batch = db.batch();
            let xpEarned = 0;
            let goalsMetCount = 0;
            for (const goalDoc of goalsSnap.docs) {
                const goal = goalDoc.data();
                let actualValue = 0;
                let met = false;
                // Calculate actual value based on goal type
                switch (goal.type) {
                    case 'app_limit':
                        if (goal.appId && stats.appUsage?.[goal.appId]) {
                            actualValue = stats.appUsage[goal.appId].totalMinutes;
                            met = actualValue <= goal.targetValue; // Under limit = met
                        }
                        else {
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
                        currentStreak: firestore_1.FieldValue.increment(1),
                        totalCompletions: firestore_1.FieldValue.increment(1),
                        updatedAt: firestore_1.Timestamp.now(),
                    });
                }
                else {
                    // Reset streak
                    batch.update(goalDoc.ref, {
                        currentStreak: 0,
                        updatedAt: firestore_1.Timestamp.now(),
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
                    history: firestore_1.FieldValue.arrayUnion(historyEntry),
                });
            }
            // Update user stats
            if (xpEarned > 0) {
                batch.update(db.collection(collections_constants_1.Collections.USERS).doc(uid), {
                    'stats.totalGoalsMet': firestore_1.FieldValue.increment(goalsMetCount),
                    'stats.totalXp': firestore_1.FieldValue.increment(xpEarned),
                    updatedAt: firestore_1.Timestamp.now(),
                });
            }
            await batch.commit();
        }
        catch (err) {
            console.error(`Goal evaluation failed for user ${userDoc.id}:`, err);
        }
    }
    console.log(`Goals evaluated for ${usersSnap.size} users`);
});
//# sourceMappingURL=goals.service.js.map
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
exports.processReferralRewards = exports.processReferral = exports.createReferralLink = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const notifications_service_1 = require("../notifications/notifications.service");
const achievements_engine_1 = require("../achievements/achievements.engine");
// ─── Create Referral Link (Callable) ───
exports.createReferralLink = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    // Check if user already has a referral code
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const existingCode = userSnap.data()?.referralCode;
    if (existingCode) {
        return {
            referralCode: existingCode,
            deepLink: `https://focusguardpro.app/join?ref=${existingCode}`,
        };
    }
    // Generate new code
    const code = generateReferralCode();
    const referralRef = db.collection(collections_constants_1.Collections.REFERRALS).doc(code);
    const referral = {
        referralCode: code,
        ownerId: uid,
        uses: 0,
        maxUses: null,
        referredUsers: [],
        rewardType: 'free_month_basic',
        status: 'active',
        createdAt: firestore_1.Timestamp.now(),
    };
    await referralRef.set(referral);
    await db.collection(collections_constants_1.Collections.USERS).doc(uid).update({
        referralCode: code,
    });
    return {
        referralCode: code,
        deepLink: `https://focusguardpro.app/join?ref=${code}`,
    };
});
// ─── Process Referral (Callable — called during new user signup) ───
exports.processReferral = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    const { referralCode } = data;
    if (!referralCode || referralCode.length < 6) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid referral code');
    }
    // Check user hasn't already used a referral
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    if (userSnap.data()?.referredBy) {
        throw new functions.https.HttpsError('already-exists', 'Already used a referral code');
    }
    // Validate referral code
    const referralRef = db.collection(collections_constants_1.Collections.REFERRALS).doc(referralCode);
    const referralSnap = await referralRef.get();
    if (!referralSnap.exists) {
        throw new functions.https.HttpsError('not-found', 'Referral code not found');
    }
    const referral = referralSnap.data();
    if (referral.status !== 'active') {
        throw new functions.https.HttpsError('failed-precondition', 'Referral code expired');
    }
    if (referral.ownerId === uid) {
        throw new functions.https.HttpsError('invalid-argument', 'Cannot use your own referral code');
    }
    if (referral.maxUses && referral.uses >= referral.maxUses) {
        throw new functions.https.HttpsError('resource-exhausted', 'Referral code has reached maximum uses');
    }
    // Check referrer account is active
    const referrerSnap = await db.collection(collections_constants_1.Collections.USERS).doc(referral.ownerId).get();
    if (!referrerSnap.exists || referrerSnap.data()?.accountStatus !== 'active') {
        throw new functions.https.HttpsError('failed-precondition', 'Referrer account not active');
    }
    // Process referral in transaction
    await db.runTransaction(async (transaction) => {
        // Add referred user
        const referredUser = {
            userId: uid,
            joinedAt: now,
            rewardGranted: false,
            rewardGrantedAt: null,
        };
        transaction.update(referralRef, {
            uses: firestore_1.FieldValue.increment(1),
            referredUsers: firestore_1.FieldValue.arrayUnion(referredUser),
        });
        // Mark referee as referred
        transaction.update(db.collection(collections_constants_1.Collections.USERS).doc(uid), {
            referredBy: referral.ownerId,
            updatedAt: now,
        });
        // Update referrer stats
        transaction.update(db.collection(collections_constants_1.Collections.USERS).doc(referral.ownerId), {
            'stats.referralCount': firestore_1.FieldValue.increment(1),
            updatedAt: now,
        });
    });
    // Check referral milestones & grant rewards
    const updatedReferral = (await referralRef.get()).data();
    const totalReferrals = updatedReferral.uses;
    if (totalReferrals >= 3 && totalReferrals < 10) {
        // Grant 1 month Basic free to referrer
        await (0, notifications_service_1.sendNotification)({
            userId: referral.ownerId,
            type: 'referral',
            title: '🎁 Referral Reward!',
            body: `You've referred ${totalReferrals} friends! You earned 1 month of Basic free!`,
            data: { reward: 'free_month_basic', referrals: totalReferrals.toString() },
        });
    }
    else if (totalReferrals >= 10) {
        // Grant 1 month Elite free to referrer
        await (0, notifications_service_1.sendNotification)({
            userId: referral.ownerId,
            type: 'referral',
            title: '👑 Elite Referral Reward!',
            body: `${totalReferrals} referrals! You earned 1 month of Elite free!`,
            data: { reward: 'free_month_elite', referrals: totalReferrals.toString() },
        });
    }
    // Notify referrer
    const refereeName = userSnap.data()?.displayName || 'Someone';
    await (0, notifications_service_1.sendNotification)({
        userId: referral.ownerId,
        type: 'referral',
        title: '📨 New Referral!',
        body: `${refereeName} joined FocusGuard using your referral code!`,
    });
    // Check referral achievements
    await (0, achievements_engine_1.checkAndUnlockAchievements)(referral.ownerId, 'referral_completed', {
        referralCount: totalReferrals,
    });
    // Grant referee 14-day extended trial (store as metadata)
    await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .update({
        'subscription.trialEndsAt': firestore_1.Timestamp.fromMillis(Date.now() + 14 * 86400000),
        updatedAt: now,
    });
    return {
        processed: true,
        referrerRewardTier: totalReferrals >= 10 ? 'elite' : totalReferrals >= 3 ? 'basic' : null,
        trialExtended: true,
    };
});
// ─── Check Pending Referral Rewards (Scheduled, monthly 1st) ───
exports.processReferralRewards = functions
    .region(firebase_config_1.REGION)
    .pubsub.schedule('0 6 1 * *')
    .timeZone('UTC')
    .onRun(async () => {
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    // Find referrals with unrewarded milestones
    const referralsSnap = await db
        .collection(collections_constants_1.Collections.REFERRALS)
        .where('status', '==', 'active')
        .where('uses', '>=', 3)
        .get();
    let processed = 0;
    for (const refDoc of referralsSnap.docs) {
        const referral = refDoc.data();
        const unrewarded = referral.referredUsers.filter((r) => !r.rewardGranted);
        if (unrewarded.length === 0)
            continue;
        // Mark all as rewarded
        const updatedUsers = referral.referredUsers.map((r) => ({
            ...r,
            rewardGranted: true,
            rewardGrantedAt: r.rewardGranted ? r.rewardGrantedAt : now,
        }));
        await refDoc.ref.update({
            referredUsers: updatedUsers,
            updatedAt: now,
        });
        processed++;
    }
    console.log(`Processed ${processed} pending referral rewards`);
});
function generateReferralCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No I, O, 0, 1 for readability
    let code = '';
    for (let i = 0; i < 6; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
}
//# sourceMappingURL=referrals.service.js.map
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
exports.updateAccountabilityStats = exports.createAccountabilityGroup = exports.sendNudge = exports.acceptPartner = exports.invitePartner = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const notifications_service_1 = require("../notifications/notifications.service");
// ─── Invite Accountability Partner (Callable) ───
exports.invitePartner = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    const { partnerUsername, inviteCode } = data;
    if (!partnerUsername && !inviteCode) {
        throw new functions.https.HttpsError('invalid-argument', 'partnerUsername or inviteCode required');
    }
    // Check subscription
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const tier = userSnap.data()?.subscription?.tier || 'free';
    if (!['pro', 'elite', 'lifetime'].includes(tier)) {
        throw new functions.https.HttpsError('permission-denied', 'Accountability requires Pro or Elite subscription');
    }
    // Check existing active pairs
    const existingPairs = await db
        .collection(collections_constants_1.Collections.ACCOUNTABILITY_PAIRS)
        .where('userIds', 'array-contains', uid)
        .where('status', 'in', ['pending', 'active'])
        .get();
    const maxPartners = tier === 'elite' || tier === 'lifetime' ? 5 : 1;
    if (existingPairs.size >= maxPartners) {
        throw new functions.https.HttpsError('resource-exhausted', `Maximum ${maxPartners} accountability partner(s) for ${tier} plan`);
    }
    // Find partner
    let partnerId = null;
    if (partnerUsername) {
        const partnerSnap = await db
            .collection(collections_constants_1.Collections.USERS)
            .where('username', '==', partnerUsername.toLowerCase())
            .where('accountStatus', '==', 'active')
            .limit(1)
            .get();
        if (partnerSnap.empty)
            throw new functions.https.HttpsError('not-found', 'User not found');
        partnerId = partnerSnap.docs[0].id;
    }
    if (partnerId === uid) {
        throw new functions.https.HttpsError('invalid-argument', 'Cannot partner with yourself');
    }
    // Check if pair already exists
    if (partnerId) {
        const existingPair = existingPairs.docs.find((d) => {
            const pair = d.data();
            return pair.userIds.includes(partnerId);
        });
        if (existingPair) {
            throw new functions.https.HttpsError('already-exists', 'Already paired with this user');
        }
    }
    // Generate invite code
    const code = generateInviteCode();
    const pairRef = db.collection(collections_constants_1.Collections.ACCOUNTABILITY_PAIRS).doc();
    const pair = {
        pairId: pairRef.id,
        userIds: partnerId ? [uid, partnerId] : [uid, ''],
        initiatorId: uid,
        status: partnerId ? 'pending' : 'pending',
        sharedSettings: {
            showScore: true,
            showStreak: true,
            showFocusTime: true,
            showAppsBlocked: false,
            allowNudges: true,
            allowCheer: true,
            strictModeAlerts: false,
        },
        stats: {
            daysPartner: 0,
            cheersExchanged: 0,
            nudgesSent: 0,
            jointGoals: 0,
            messagesExchanged: 0,
        },
        messages: [],
        inviteCode: code,
        createdAt: now,
        updatedAt: now,
    };
    await pairRef.set(pair);
    // Notify partner if found
    if (partnerId) {
        await (0, notifications_service_1.sendNotification)({
            userId: partnerId,
            type: 'partner_activity',
            title: '🤝 Accountability Partner Request',
            body: `${userSnap.data()?.displayName || 'Someone'} wants to be your accountability partner!`,
            data: { action: 'accept_partner', pairId: pairRef.id },
        });
    }
    return { pairId: pairRef.id, inviteCode: code };
});
// ─── Accept Partner Request (Callable) ───
exports.acceptPartner = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { pairId, inviteCode } = data;
    let pairRef;
    let pairSnap;
    if (pairId) {
        pairRef = db.collection(collections_constants_1.Collections.ACCOUNTABILITY_PAIRS).doc(pairId);
        pairSnap = await pairRef.get();
    }
    else if (inviteCode) {
        const snaps = await db
            .collection(collections_constants_1.Collections.ACCOUNTABILITY_PAIRS)
            .where('inviteCode', '==', inviteCode)
            .where('status', '==', 'pending')
            .limit(1)
            .get();
        if (snaps.empty)
            throw new functions.https.HttpsError('not-found', 'Invalid invite code');
        pairRef = snaps.docs[0].ref;
        pairSnap = snaps.docs[0];
    }
    else {
        throw new functions.https.HttpsError('invalid-argument', 'pairId or inviteCode required');
    }
    if (!pairSnap.exists)
        throw new functions.https.HttpsError('not-found', 'Pair not found');
    const pair = pairSnap.data();
    if (pair.status !== 'pending') {
        throw new functions.https.HttpsError('failed-precondition', 'Pair is not pending');
    }
    if (pair.initiatorId === uid) {
        throw new functions.https.HttpsError('invalid-argument', 'Cannot accept your own request');
    }
    // Update pair
    const updatedUserIds = pair.userIds[1] === '' ? [pair.userIds[0], uid] : pair.userIds;
    await pairRef.update({
        userIds: updatedUserIds,
        status: 'active',
        updatedAt: firestore_1.Timestamp.now(),
    });
    // Update both users' partner count
    const batch = db.batch();
    for (const userId of updatedUserIds) {
        batch.update(db.collection(collections_constants_1.Collections.USERS).doc(userId), {
            'stats.accountabilityPartnersCount': firestore_1.FieldValue.increment(1),
            updatedAt: firestore_1.Timestamp.now(),
        });
    }
    await batch.commit();
    // Notify initiator
    await (0, notifications_service_1.sendNotification)({
        userId: pair.initiatorId,
        type: 'partner_activity',
        title: '🎉 Partner Accepted!',
        body: 'Your accountability partner request was accepted!',
        data: { pairId: pairRef.id },
    });
    // Check achievement
    await (0, achievements_engine_1.checkAndUnlockAchievements)(uid, 'accountability_started', { partnerDays: 1 });
    return { accepted: true };
});
// ─── Send Nudge (Callable) ───
exports.sendNudge = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { pairId, type, message } = data;
    if (!pairId)
        throw new functions.https.HttpsError('invalid-argument', 'pairId required');
    const pairRef = db.collection(collections_constants_1.Collections.ACCOUNTABILITY_PAIRS).doc(pairId);
    const pairSnap = await pairRef.get();
    if (!pairSnap.exists)
        throw new functions.https.HttpsError('not-found', 'Pair not found');
    const pair = pairSnap.data();
    if (!pair.userIds.includes(uid)) {
        throw new functions.https.HttpsError('permission-denied', 'Not a member of this pair');
    }
    if (pair.status !== 'active') {
        throw new functions.https.HttpsError('failed-precondition', 'Pair is not active');
    }
    const partnerId = pair.userIds.find((id) => id !== uid);
    const nudgeType = type === 'cheer' ? 'cheer' : 'nudge';
    // Add message
    const msg = {
        messageId: `${Date.now()}_${uid.slice(0, 6)}`,
        senderId: uid,
        text: message ||
            (nudgeType === 'cheer' ? '🎉 Your partner is cheering you on!' : '💪 Time to focus!'),
        type: nudgeType,
        createdAt: firestore_1.Timestamp.now(),
    };
    await pairRef.update({
        messages: firestore_1.FieldValue.arrayUnion(msg),
        [`stats.${nudgeType === 'cheer' ? 'cheersExchanged' : 'nudgesSent'}`]: firestore_1.FieldValue.increment(1),
        'stats.messagesExchanged': firestore_1.FieldValue.increment(1),
        updatedAt: firestore_1.Timestamp.now(),
    });
    // Notify partner
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const userName = userSnap.data()?.displayName || 'Partner';
    const tmpl = nudgeType === 'cheer'
        ? { title: `🎉 ${userName} cheered you on!`, body: msg.text }
        : { title: `💪 ${userName} sent a nudge`, body: msg.text };
    await (0, notifications_service_1.sendNotification)({
        userId: partnerId,
        type: 'partner_activity',
        title: tmpl.title,
        body: tmpl.body,
        data: { pairId, type: nudgeType },
    });
    return { sent: true };
});
// ─── Create Accountability Group (Callable) ───
exports.createAccountabilityGroup = functions
    .region(firebase_config_1.REGION)
    .https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    const { name, description } = data;
    if (!name)
        throw new functions.https.HttpsError('invalid-argument', 'name required');
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const tier = userSnap.data()?.subscription?.tier || 'free';
    if (!['elite', 'lifetime'].includes(tier)) {
        throw new functions.https.HttpsError('permission-denied', 'Groups require Elite subscription');
    }
    const groupRef = db.collection(collections_constants_1.Collections.ACCOUNTABILITY_GROUPS).doc();
    const group = {
        groupId: groupRef.id,
        name,
        description: description || '',
        memberIds: [uid],
        adminId: uid,
        inviteCode: generateInviteCode(),
        status: 'active',
        sharedSettings: {
            showScore: true,
            showStreak: true,
            showFocusTime: true,
        },
        stats: {
            totalFocusMinutes: 0,
            totalSessionsCompleted: 0,
        },
        createdAt: now,
        updatedAt: now,
    };
    await groupRef.set(group);
    return { groupId: groupRef.id, inviteCode: group.inviteCode };
});
// ─── Update Accountability Stats (Scheduled, daily midnight) ───
exports.updateAccountabilityStats = functions
    .region(firebase_config_1.REGION)
    .pubsub.schedule('5 0 * * *')
    .timeZone('UTC')
    .onRun(async () => {
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    // Update active pairs
    const pairsSnap = await db
        .collection(collections_constants_1.Collections.ACCOUNTABILITY_PAIRS)
        .where('status', '==', 'active')
        .get();
    let updated = 0;
    for (const pairDoc of pairsSnap.docs) {
        await pairDoc.ref.update({
            'stats.daysPartner': firestore_1.FieldValue.increment(1),
            updatedAt: now,
        });
        updated++;
    }
    console.log(`Updated ${updated} accountability pairs`);
});
function generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 8; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
}
// Re-export for use in achievements
const achievements_engine_1 = require("../achievements/achievements.engine");
//# sourceMappingURL=accountability.service.js.map
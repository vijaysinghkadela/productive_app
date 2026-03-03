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
exports.checkEntitlements = exports.revenuecatWebhook = void 0;
const functions = __importStar(require("firebase-functions"));
const crypto = __importStar(require("crypto"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const PRODUCT_TO_TIER = {
    focusguard_basic_monthly: 'basic',
    focusguard_basic_yearly: 'basic',
    focusguard_pro_monthly: 'pro',
    focusguard_pro_yearly: 'pro',
    focusguard_elite_monthly: 'elite',
    focusguard_elite_yearly: 'elite',
    focusguard_lifetime: 'lifetime',
};
// ─── RevenueCat Webhook Handler ───
exports.revenuecatWebhook = functions
    .region(firebase_config_1.REGION)
    .runWith({ secrets: ['revenuecat-webhook-secret'] })
    .https.onRequest(async (req, res) => {
    // Only accept POST
    if (req.method !== 'POST') {
        res.status(405).send('Method not allowed');
        return;
    }
    // Verify webhook signature
    try {
        const secret = await (0, firebase_config_1.getSecret)('revenuecat-webhook-secret');
        const signature = req.headers['x-revenuecat-signature'];
        if (signature) {
            const expectedSig = crypto
                .createHmac('sha256', secret)
                .update(JSON.stringify(req.body))
                .digest('hex');
            if (signature !== expectedSig) {
                console.error('Invalid webhook signature');
                res.status(401).send('Invalid signature');
                return;
            }
        }
    }
    catch (err) {
        console.error('Signature verification failed:', err);
    }
    const payload = req.body;
    const event = payload.event;
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    // Idempotency check
    const eventRef = db.collection(collections_constants_1.Collections.WEBHOOK_EVENTS).doc(event.id);
    const eventSnap = await eventRef.get();
    if (eventSnap.exists) {
        console.log(`Duplicate webhook event: ${event.id}`);
        res.status(200).send('OK');
        return;
    }
    // Mark event as processed
    await eventRef.set({ eventId: event.id, type: event.type, processedAt: now });
    const userId = event.app_user_id;
    const userRef = db.collection(collections_constants_1.Collections.USERS).doc(userId);
    const userSnap = await userRef.get();
    if (!userSnap.exists) {
        console.error(`User not found for webhook: ${userId}`);
        res.status(200).send('OK'); // Return 200 to prevent retries
        return;
    }
    const newTier = PRODUCT_TO_TIER[event.product_id] || 'free';
    try {
        switch (event.type) {
            case 'INITIAL_PURCHASE': {
                await userRef.update({
                    'subscription.tier': newTier,
                    'subscription.status': event.period_type === 'TRIAL' ? 'trial' : 'active',
                    'subscription.currentPeriodStart': firestore_1.Timestamp.fromMillis(event.purchased_at_ms),
                    'subscription.currentPeriodEnd': event.expiration_at_ms
                        ? firestore_1.Timestamp.fromMillis(event.expiration_at_ms)
                        : null,
                    'subscription.cancelAtPeriodEnd': false,
                    'subscription.trialEndsAt': event.period_type === 'TRIAL' && event.expiration_at_ms
                        ? firestore_1.Timestamp.fromMillis(event.expiration_at_ms)
                        : null,
                    'subscription.entitlements': event.entitlement_ids,
                    updatedAt: now,
                });
                // Update custom claims
                const claims = (await (0, firebase_config_1.getAuth)().getUser(userId)).customClaims || {};
                await (0, firebase_config_1.getAuth)().setCustomUserClaims(userId, { ...claims, tier: newTier });
                // Welcome notification
                const notifRef = db
                    .collection(collections_constants_1.Collections.USERS)
                    .doc(userId)
                    .collection(collections_constants_1.Collections.NOTIFICATIONS)
                    .doc();
                await notifRef.set({
                    notificationId: notifRef.id,
                    userId,
                    type: 'system',
                    title: `Welcome to FocusGuard ${newTier.charAt(0).toUpperCase() + newTier.slice(1)}! 🎉`,
                    body: 'Unlock your full productivity potential with premium features.',
                    data: { action: 'navigate', destination: '/settings' },
                    read: false,
                    readAt: null,
                    actionTaken: null,
                    fcmMessageId: null,
                    deliveredAt: null,
                    createdAt: now,
                });
                break;
            }
            case 'RENEWAL': {
                await userRef.update({
                    'subscription.status': 'active',
                    'subscription.currentPeriodStart': firestore_1.Timestamp.fromMillis(event.purchased_at_ms),
                    'subscription.currentPeriodEnd': event.expiration_at_ms
                        ? firestore_1.Timestamp.fromMillis(event.expiration_at_ms)
                        : null,
                    'subscription.cancelAtPeriodEnd': false,
                    updatedAt: now,
                });
                break;
            }
            case 'CANCELLATION': {
                await userRef.update({
                    'subscription.cancelAtPeriodEnd': true,
                    updatedAt: now,
                });
                const notifRef = db
                    .collection(collections_constants_1.Collections.USERS)
                    .doc(userId)
                    .collection(collections_constants_1.Collections.NOTIFICATIONS)
                    .doc();
                await notifRef.set({
                    notificationId: notifRef.id,
                    userId,
                    type: 'system',
                    title: 'Subscription cancelled',
                    body: 'Your premium features will remain active until the end of your billing period.',
                    data: { action: 'navigate', destination: '/subscription' },
                    read: false,
                    readAt: null,
                    actionTaken: null,
                    fcmMessageId: null,
                    deliveredAt: null,
                    createdAt: now,
                });
                break;
            }
            case 'BILLING_ISSUE': {
                await userRef.update({
                    'subscription.status': 'grace_period',
                    updatedAt: now,
                });
                break;
            }
            case 'EXPIRATION': {
                await userRef.update({
                    'subscription.tier': 'free',
                    'subscription.status': 'expired',
                    'subscription.entitlements': [],
                    updatedAt: now,
                });
                const claims = (await (0, firebase_config_1.getAuth)().getUser(userId)).customClaims || {};
                await (0, firebase_config_1.getAuth)().setCustomUserClaims(userId, { ...claims, tier: 'free' });
                break;
            }
            case 'UNCANCELLATION': {
                await userRef.update({
                    'subscription.cancelAtPeriodEnd': false,
                    updatedAt: now,
                });
                break;
            }
            case 'PRODUCT_CHANGE': {
                await userRef.update({
                    'subscription.tier': newTier,
                    'subscription.status': 'active',
                    'subscription.entitlements': event.entitlement_ids,
                    updatedAt: now,
                });
                const claims = (await (0, firebase_config_1.getAuth)().getUser(userId)).customClaims || {};
                await (0, firebase_config_1.getAuth)().setCustomUserClaims(userId, { ...claims, tier: newTier });
                break;
            }
            default:
                console.log(`Unhandled webhook event type: ${event.type}`);
        }
    }
    catch (error) {
        console.error(`Error processing webhook ${event.type} for ${userId}:`, error);
    }
    // Always return 200 to prevent retries
    res.status(200).send('OK');
});
// ─── Check Entitlements (Callable) ───
exports.checkEntitlements = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { featureName } = data;
    if (!featureName) {
        throw new functions.https.HttpsError('invalid-argument', 'featureName required');
    }
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const tier = (userSnap.data()?.subscription?.tier || 'free');
    // Feature gates
    const featureGates = {
        basic_tracking: ['free', 'basic', 'pro', 'elite', 'lifetime'],
        full_analytics: ['pro', 'elite', 'lifetime'],
        ai_coaching: ['pro', 'elite', 'lifetime'],
        unlimited_blocks: ['pro', 'elite', 'lifetime'],
        achievements: ['pro', 'elite', 'lifetime'],
        leaderboard: ['pro', 'elite', 'lifetime'],
        challenges: ['pro', 'elite', 'lifetime'],
        focus_modes: ['pro', 'elite', 'lifetime'],
        focus_spaces: ['pro', 'elite', 'lifetime'],
        export_reports: ['pro', 'elite', 'lifetime'],
        accountability_partner: ['pro', 'elite', 'lifetime'],
        bedtime_mode: ['pro', 'elite', 'lifetime'],
        strict_mode_biometric: ['elite', 'lifetime'],
        ai_unlimited: ['elite', 'lifetime'],
        custom_overlay: ['elite', 'lifetime'],
        priority_support: ['elite', 'lifetime'],
    };
    const allowedTiers = featureGates[featureName] || ['pro', 'elite', 'lifetime'];
    const hasAccess = allowedTiers.includes(tier);
    return {
        hasAccess,
        tier,
        reason: hasAccess ? 'Feature is available' : `Requires ${allowedTiers[0]} or higher`,
        upgradeRequired: !hasAccess,
    };
});
//# sourceMappingURL=subscriptions.service.js.map
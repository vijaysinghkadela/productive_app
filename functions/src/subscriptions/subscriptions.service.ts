import * as functions from 'firebase-functions';
import * as crypto from 'crypto';
import { Timestamp } from 'firebase-admin/firestore';
import { getFirestore, getAuth, getSecret, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { RevenueCatWebhookEvent } from '../shared/types/common.types';
import { SubscriptionTier } from '../shared/types/firestore.types';

const PRODUCT_TO_TIER: Record<string, SubscriptionTier> = {
  focusguard_basic_monthly: 'basic',
  focusguard_basic_yearly: 'basic',
  focusguard_pro_monthly: 'pro',
  focusguard_pro_yearly: 'pro',
  focusguard_elite_monthly: 'elite',
  focusguard_elite_yearly: 'elite',
  focusguard_lifetime: 'lifetime',
};

// ─── RevenueCat Webhook Handler ───
export const revenuecatWebhook = functions
  .region(REGION)
  .runWith({ secrets: ['revenuecat-webhook-secret'] })
  .https.onRequest(async (req, res) => {
    // Only accept POST
    if (req.method !== 'POST') {
      res.status(405).send('Method not allowed');
      return;
    }

    // Verify webhook signature
    try {
      const secret = await getSecret('revenuecat-webhook-secret');
      const signature = req.headers['x-revenuecat-signature'] as string;
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
    } catch (err) {
      console.error('Signature verification failed:', err);
    }

    const payload = req.body as RevenueCatWebhookEvent;
    const event = payload.event;
    const db = getFirestore();
    const now = Timestamp.now();

    // Idempotency check
    const eventRef = db.collection(Collections.WEBHOOK_EVENTS).doc(event.id);
    const eventSnap = await eventRef.get();
    if (eventSnap.exists) {
      console.log(`Duplicate webhook event: ${event.id}`);
      res.status(200).send('OK');
      return;
    }

    // Mark event as processed
    await eventRef.set({ eventId: event.id, type: event.type, processedAt: now });

    const userId = event.app_user_id;
    const userRef = db.collection(Collections.USERS).doc(userId);
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
            'subscription.currentPeriodStart': Timestamp.fromMillis(event.purchased_at_ms),
            'subscription.currentPeriodEnd': event.expiration_at_ms
              ? Timestamp.fromMillis(event.expiration_at_ms)
              : null,
            'subscription.cancelAtPeriodEnd': false,
            'subscription.trialEndsAt':
              event.period_type === 'TRIAL' && event.expiration_at_ms
                ? Timestamp.fromMillis(event.expiration_at_ms)
                : null,
            'subscription.entitlements': event.entitlement_ids,
            updatedAt: now,
          });

          // Update custom claims
          const claims = (await getAuth().getUser(userId)).customClaims || {};
          await getAuth().setCustomUserClaims(userId, { ...claims, tier: newTier });

          // Welcome notification
          const notifRef = db
            .collection(Collections.USERS)
            .doc(userId)
            .collection(Collections.NOTIFICATIONS)
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
            'subscription.currentPeriodStart': Timestamp.fromMillis(event.purchased_at_ms),
            'subscription.currentPeriodEnd': event.expiration_at_ms
              ? Timestamp.fromMillis(event.expiration_at_ms)
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
            .collection(Collections.USERS)
            .doc(userId)
            .collection(Collections.NOTIFICATIONS)
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

          const claims = (await getAuth().getUser(userId)).customClaims || {};
          await getAuth().setCustomUserClaims(userId, { ...claims, tier: 'free' });
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

          const claims = (await getAuth().getUser(userId)).customClaims || {};
          await getAuth().setCustomUserClaims(userId, { ...claims, tier: newTier });
          break;
        }

        default:
          console.log(`Unhandled webhook event type: ${event.type}`);
      }
    } catch (error) {
      console.error(`Error processing webhook ${event.type} for ${userId}:`, error);
    }

    // Always return 200 to prevent retries
    res.status(200).send('OK');
  });

// ─── Check Entitlements (Callable) ───
export const checkEntitlements = functions.region(REGION).https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const uid = context.auth.uid;
  const db = getFirestore();

  const { featureName } = data;
  if (!featureName) {
    throw new functions.https.HttpsError('invalid-argument', 'featureName required');
  }

  const userSnap = await db.collection(Collections.USERS).doc(uid).get();
  const tier = (userSnap.data()?.subscription?.tier || 'free') as SubscriptionTier;

  // Feature gates
  const featureGates: Record<string, SubscriptionTier[]> = {
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

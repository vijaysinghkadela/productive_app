import * as functions from 'firebase-functions';

import { Timestamp } from 'firebase-admin/firestore';
import { getFirestore, getSecret, REGION } from '../shared/config/firebase.config';

// ─── Stripe Webhook Handler (backup payment processor) ───
export const stripeWebhook = functions.region(REGION).https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('Method not allowed');
    return;
  }

  const db = getFirestore();
  const now = Timestamp.now();

  // Verify Stripe signature
  try {
    const endpointSecret = await getSecret('stripe-webhook-secret');
    const signature = req.headers['stripe-signature'] as string;
    if (!signature) {
      res.status(400).send('Missing signature');
      return;
    }

    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const stripe = require('stripe');
    const event = stripe.webhooks.constructEvent(
      req.rawBody || JSON.stringify(req.body),
      signature,
      endpointSecret,
    );

    // Idempotency check
    const eventRef = db.collection('webhook_events').doc(event.id);
    const eventSnap = await eventRef.get();
    if (eventSnap.exists) {
      console.log(`Duplicate Stripe event: ${event.id}`);
      res.status(200).send('OK');
      return;
    }
    await eventRef.set({ eventId: event.id, type: event.type, processedAt: now });

    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object;
        const userId = session.client_reference_id;
        if (!userId) break;

        await db.collection('users').doc(userId).update({
          'subscription.status': 'active',
          'subscription.stripeCustomerId': session.customer,
          updatedAt: now,
        });
        break;
      }

      case 'customer.subscription.updated': {
        const subscription = event.data.object;
        const customerId = subscription.customer;

        const userSnap = await db
          .collection('users')
          .where('subscription.stripeCustomerId', '==', customerId)
          .limit(1)
          .get();

        if (!userSnap.empty) {
          const status =
            subscription.status === 'active'
              ? 'active'
              : subscription.status === 'past_due'
                ? 'grace_period'
                : subscription.status === 'canceled'
                  ? 'cancelled'
                  : 'expired';

          await userSnap.docs[0].ref.update({
            'subscription.status': status,
            'subscription.cancelAtPeriodEnd': subscription.cancel_at_period_end,
            updatedAt: now,
          });
        }
        break;
      }

      case 'invoice.payment_failed': {
        const invoice = event.data.object;
        const customerId = invoice.customer;

        const userSnap = await db
          .collection('users')
          .where('subscription.stripeCustomerId', '==', customerId)
          .limit(1)
          .get();

        if (!userSnap.empty) {
          await userSnap.docs[0].ref.update({
            'subscription.status': 'grace_period',
            updatedAt: now,
          });
        }
        break;
      }

      default:
        console.log(`Unhandled Stripe event type: ${event.type}`);
    }

    res.status(200).send('OK');
  } catch (err) {
    console.error('Stripe webhook error:', err);
    res.status(400).send('Webhook error');
  }
});

// ─── SendGrid Webhook Handler (email event tracking) ───
export const sendgridWebhook = functions.region(REGION).https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('Method not allowed');
    return;
  }

  const db = getFirestore();

  try {
    const events = Array.isArray(req.body) ? req.body : [req.body];

    for (const event of events) {
      const { email, event: eventType, sg_message_id, timestamp } = event;

      // Track email delivery events
      switch (eventType) {
        case 'delivered':
        case 'open':
        case 'click':
        case 'bounce':
        case 'dropped':
        case 'spamreport':
        case 'unsubscribe': {
          await db.collection('email_events').add({
            email,
            eventType,
            messageId: sg_message_id,
            timestamp: Timestamp.fromMillis((timestamp || Math.floor(Date.now() / 1000)) * 1000),
            processedAt: Timestamp.now(),
          });

          // Handle bounces and spam reports
          if (eventType === 'bounce' || eventType === 'spamreport' || eventType === 'unsubscribe') {
            const userSnap = await db
              .collection('users')
              .where('email', '==', email)
              .limit(1)
              .get();

            if (!userSnap.empty) {
              await userSnap.docs[0].ref.update({
                'settings.notifications.emailEnabled': false,
                [`emailSuppressions.${eventType}`]: Timestamp.now(),
                updatedAt: Timestamp.now(),
              });
            }
          }
          break;
        }
        default:
          break;
      }
    }

    res.status(200).send('OK');
  } catch (err) {
    console.error('SendGrid webhook error:', err);
    res.status(200).send('OK'); // Always return 200 to prevent retries
  }
});

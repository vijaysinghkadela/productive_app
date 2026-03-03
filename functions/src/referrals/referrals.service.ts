import * as functions from 'firebase-functions';
import { Timestamp, FieldValue } from 'firebase-admin/firestore';
import { getFirestore, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { ReferralDocument, SubscriptionTier } from '../shared/types/firestore.types';
import { sendNotification } from '../notifications/notifications.service';
import { checkAndUnlockAchievements } from '../achievements/achievements.engine';

// ─── Create Referral Link (Callable) ───
export const createReferralLink = functions
  .region(REGION)
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();

    // Check if user already has a referral code
    const userSnap = await db.collection(Collections.USERS).doc(uid).get();
    const existingCode = userSnap.data()?.referralCode;

    if (existingCode) {
      return {
        referralCode: existingCode,
        deepLink: `https://focusguardpro.app/join?ref=${existingCode}`,
      };
    }

    // Generate new code
    const code = generateReferralCode();
    const referralRef = db.collection(Collections.REFERRALS).doc(code);

    const referral: ReferralDocument = {
      referralCode: code,
      ownerId: uid,
      uses: 0,
      maxUses: null,
      referredUsers: [],
      rewardType: 'free_month_basic',
      status: 'active',
      createdAt: Timestamp.now(),
    };

    await referralRef.set(referral);
    await db.collection(Collections.USERS).doc(uid).update({
      referralCode: code,
    });

    return {
      referralCode: code,
      deepLink: `https://focusguardpro.app/join?ref=${code}`,
    };
  });

// ─── Process Referral (Callable — called during new user signup) ───
export const processReferral = functions
  .region(REGION)
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();
    const now = Timestamp.now();

    const { referralCode } = data;
    if (!referralCode || referralCode.length < 6) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid referral code');
    }

    // Check user hasn't already used a referral
    const userSnap = await db.collection(Collections.USERS).doc(uid).get();
    if (userSnap.data()?.referredBy) {
      throw new functions.https.HttpsError('already-exists', 'Already used a referral code');
    }

    // Validate referral code
    const referralRef = db.collection(Collections.REFERRALS).doc(referralCode);
    const referralSnap = await referralRef.get();

    if (!referralSnap.exists) {
      throw new functions.https.HttpsError('not-found', 'Referral code not found');
    }

    const referral = referralSnap.data() as ReferralDocument;

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
    const referrerSnap = await db.collection(Collections.USERS).doc(referral.ownerId).get();
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
        uses: FieldValue.increment(1),
        referredUsers: FieldValue.arrayUnion(referredUser),
      });

      // Mark referee as referred
      transaction.update(db.collection(Collections.USERS).doc(uid), {
        referredBy: referral.ownerId,
        updatedAt: now,
      });

      // Update referrer stats
      transaction.update(db.collection(Collections.USERS).doc(referral.ownerId), {
        'stats.referralCount': FieldValue.increment(1),
        updatedAt: now,
      });
    });

    // Check referral milestones & grant rewards
    const updatedReferral = (await referralRef.get()).data() as ReferralDocument;
    const totalReferrals = updatedReferral.uses;

    if (totalReferrals >= 3 && totalReferrals < 10) {
      // Grant 1 month Basic free to referrer
      await sendNotification({
        userId: referral.ownerId,
        type: 'referral',
        title: '🎁 Referral Reward!',
        body: `You've referred ${totalReferrals} friends! You earned 1 month of Basic free!`,
        data: { reward: 'free_month_basic', referrals: totalReferrals.toString() },
      });
    } else if (totalReferrals >= 10) {
      // Grant 1 month Elite free to referrer
      await sendNotification({
        userId: referral.ownerId,
        type: 'referral',
        title: '👑 Elite Referral Reward!',
        body: `${totalReferrals} referrals! You earned 1 month of Elite free!`,
        data: { reward: 'free_month_elite', referrals: totalReferrals.toString() },
      });
    }

    // Notify referrer
    const refereeName = userSnap.data()?.displayName || 'Someone';
    await sendNotification({
      userId: referral.ownerId,
      type: 'referral',
      title: '📨 New Referral!',
      body: `${refereeName} joined FocusGuard using your referral code!`,
    });

    // Check referral achievements
    await checkAndUnlockAchievements(referral.ownerId, 'referral_completed', {
      referralCount: totalReferrals,
    });

    // Grant referee 14-day extended trial (store as metadata)
    await db.collection(Collections.USERS).doc(uid).update({
      'subscription.trialEndsAt': Timestamp.fromMillis(Date.now() + 14 * 86400000),
      updatedAt: now,
    });

    return {
      processed: true,
      referrerRewardTier: totalReferrals >= 10 ? 'elite' : totalReferrals >= 3 ? 'basic' : null,
      trialExtended: true,
    };
  });

// ─── Check Pending Referral Rewards (Scheduled, monthly 1st) ───
export const processReferralRewards = functions
  .region(REGION)
  .pubsub.schedule('0 6 1 * *')
  .timeZone('UTC')
  .onRun(async () => {
    const db = getFirestore();
    const now = Timestamp.now();

    // Find referrals with unrewarded milestones
    const referralsSnap = await db.collection(Collections.REFERRALS)
      .where('status', '==', 'active')
      .where('uses', '>=', 3)
      .get();

    let processed = 0;
    for (const refDoc of referralsSnap.docs) {
      const referral = refDoc.data() as ReferralDocument;
      const unrewarded = referral.referredUsers.filter((r) => !r.rewardGranted);

      if (unrewarded.length === 0) continue;

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

function generateReferralCode(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No I, O, 0, 1 for readability
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

import * as functions from 'firebase-functions';
import { Timestamp } from 'firebase-admin/firestore';
import { getFirestore, getSecret, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import * as crypto from 'crypto';
import { authenticator } from 'otplib';

// ─── Generate TOTP Secret (Callable) ───
export const generateTOTPSecret = functions.region(REGION).https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const uid = context.auth.uid;
  const db = getFirestore();

  // Check if MFA already enabled
  const mfaDoc = await db
    .collection(Collections.USERS)
    .doc(uid)
    .collection('mfa')
    .doc('totp')
    .get();

  if (mfaDoc.exists && mfaDoc.data()?.verified) {
    throw new functions.https.HttpsError('already-exists', 'TOTP already configured');
  }

  // Generate secret
  const secret = authenticator.generateSecret(20);

  // Get user email for QR code
  const userSnap = await db.collection(Collections.USERS).doc(uid).get();
  const email = userSnap.data()?.email || 'user@focusguard.app';

  // Generate otpauth URI
  const otpauthUrl = authenticator.keyuri(email, 'FocusGuard Pro', secret);

  // Store secret (not yet verified)
  await db.collection(Collections.USERS).doc(uid).collection('mfa').doc('totp').set({
    secret,
    verified: false,
    createdAt: Timestamp.now(),
  });

  return {
    secret,
    otpauthUrl,
    qrCodeData: otpauthUrl,
  };
});

// ─── Verify TOTP Token (Callable) ───
export const verifyTOTPToken = functions.region(REGION).https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const uid = context.auth.uid;
  const db = getFirestore();

  const { token, isSetup } = data;
  if (!token || !/^\d{6}$/.test(token)) {
    throw new functions.https.HttpsError('invalid-argument', 'Token must be a 6-digit number');
  }

  const mfaDoc = await db
    .collection(Collections.USERS)
    .doc(uid)
    .collection('mfa')
    .doc('totp')
    .get();

  if (!mfaDoc.exists) {
    throw new functions.https.HttpsError(
      'not-found',
      'TOTP not configured. Please generate a secret first.',
    );
  }

  const mfaData = mfaDoc.data()!;
  const secret = mfaData.secret;

  // Verify with time window (±1 step = 30 seconds)
  const isValid = authenticator.verify({ token, secret });

  if (!isValid) {
    // Track failed attempts
    await db
      .collection(Collections.USERS)
      .doc(uid)
      .collection('mfa')
      .doc('totp')
      .update({
        failedAttempts: (mfaData.failedAttempts || 0) + 1,
        lastFailedAt: Timestamp.now(),
      });

    throw new functions.https.HttpsError('invalid-argument', 'Invalid TOTP code');
  }

  if (isSetup) {
    // First-time verification — mark TOTP as verified and generate backup codes
    const backupCodes = generateBackupCodes();
    const hashedCodes = await hashBackupCodes(backupCodes);

    await db.collection(Collections.USERS).doc(uid).collection('mfa').doc('totp').update({
      verified: true,
      failedAttempts: 0,
      verifiedAt: Timestamp.now(),
    });

    await db.collection(Collections.USERS).doc(uid).collection('mfa').doc('backup_codes').set({
      codes: hashedCodes,
      usedCount: 0,
      generatedAt: Timestamp.now(),
    });

    // Update user document
    await db.collection(Collections.USERS).doc(uid).update({
      'settings.mfaEnabled': true,
      updatedAt: Timestamp.now(),
    });

    return {
      verified: true,
      backupCodes, // Show once to user
      message: 'TOTP MFA enabled successfully. Save your backup codes!',
    };
  }

  // Regular verification
  await db.collection(Collections.USERS).doc(uid).collection('mfa').doc('totp').update({
    failedAttempts: 0,
    lastVerifiedAt: Timestamp.now(),
  });

  return { verified: true };
});

// ─── Send SMS MFA Code (Callable) ───
export const sendSMSCode = functions.region(REGION).https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const uid = context.auth.uid;
  const db = getFirestore();

  const { phoneNumber } = data;
  if (!phoneNumber || !/^\+[1-9]\d{6,14}$/.test(phoneNumber)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid phone number format (E.164)');
  }

  // Generate 6-digit code
  const code = String(Math.floor(100000 + Math.random() * 900000));
  const codeHash = crypto.createHash('sha256').update(code).digest('hex');
  const expiresAt = Timestamp.fromMillis(Date.now() + 10 * 60 * 1000); // 10 minutes

  // Rate limit: max 3 SMS per hour
  const smsDoc = await db.collection(Collections.USERS).doc(uid).collection('mfa').doc('sms').get();

  if (smsDoc.exists) {
    const smsData = smsDoc.data()!;
    const lastSentAt = smsData.lastSentAt?.toDate();
    if (lastSentAt && Date.now() - lastSentAt.getTime() < 60000) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Please wait 60 seconds between SMS requests',
      );
    }
    if (smsData.hourlyCount >= 3) {
      const hourAgo = Date.now() - 3600000;
      if (smsData.hourCountStartedAt?.toDate()?.getTime() > hourAgo) {
        throw new functions.https.HttpsError('resource-exhausted', 'Maximum 3 SMS per hour');
      }
    }
  }

  // Store hashed code
  await db
    .collection(Collections.USERS)
    .doc(uid)
    .collection('mfa')
    .doc('sms')
    .set(
      {
        codeHash,
        phoneNumber,
        expiresAt,
        attempts: 0,
        maxAttempts: 5,
        lastSentAt: Timestamp.now(),
        hourlyCount: (smsDoc.exists ? smsDoc.data()!.hourlyCount || 0 : 0) + 1,
        hourCountStartedAt:
          smsDoc.exists && smsDoc.data()!.hourCountStartedAt
            ? smsDoc.data()!.hourCountStartedAt
            : Timestamp.now(),
      },
      { merge: true },
    );

  // Send via Twilio
  try {
    const accountSid = await getSecret('twilio-account-sid');
    const authToken = await getSecret('twilio-auth-token');
    const fromNumber = process.env.TWILIO_PHONE_NUMBER || '+15005550006';

    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const twilio = require('twilio');
    const client = twilio(accountSid, authToken);

    await client.messages.create({
      body: `Your FocusGuard verification code is: ${code}. Expires in 10 minutes.`,
      from: fromNumber,
      to: phoneNumber,
    });
  } catch (err) {
    console.error('Twilio SMS send failed:', err);
    throw new functions.https.HttpsError('internal', 'Failed to send SMS. Please try again.');
  }

  return { sent: true, expiresInSeconds: 600 };
});

// ─── Verify SMS Code (Callable) ───
export const verifySMSCode = functions.region(REGION).https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const uid = context.auth.uid;
  const db = getFirestore();

  const { code } = data;
  if (!code || !/^\d{6}$/.test(code)) {
    throw new functions.https.HttpsError('invalid-argument', 'Code must be 6 digits');
  }

  const smsDoc = await db.collection(Collections.USERS).doc(uid).collection('mfa').doc('sms').get();

  if (!smsDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'No pending SMS verification');
  }

  const smsData = smsDoc.data()!;

  // Check expiration
  if (smsData.expiresAt.toDate() < new Date()) {
    throw new functions.https.HttpsError(
      'deadline-exceeded',
      'Code expired. Please request a new one.',
    );
  }

  // Check max attempts
  if (smsData.attempts >= smsData.maxAttempts) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Too many attempts. Request a new code.',
    );
  }

  // Verify code
  const codeHash = crypto.createHash('sha256').update(code).digest('hex');
  if (codeHash !== smsData.codeHash) {
    await smsDoc.ref.update({ attempts: (smsData.attempts || 0) + 1 });
    throw new functions.https.HttpsError('invalid-argument', 'Invalid code');
  }

  // Mark as verified — delete SMS doc to prevent replay
  await smsDoc.ref.delete();

  return { verified: true };
});

// ─── Verify Backup Code (Callable) ───
export const verifyBackupCode = functions.region(REGION).https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const uid = context.auth.uid;
  const db = getFirestore();

  const { code } = data;
  if (!code || code.length !== 10) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid backup code format');
  }

  const backupDoc = await db
    .collection(Collections.USERS)
    .doc(uid)
    .collection('mfa')
    .doc('backup_codes')
    .get();

  if (!backupDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'No backup codes configured');
  }

  const backupData = backupDoc.data()!;
  const codeHash = crypto.createHash('sha256').update(code).digest('hex');

  const matchIndex = backupData.codes.findIndex(
    (c: { hash: string; used: boolean }) => c.hash === codeHash && !c.used,
  );

  if (matchIndex === -1) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid or already used backup code');
  }

  // Mark as used
  const updatedCodes = [...backupData.codes];
  updatedCodes[matchIndex] = { ...updatedCodes[matchIndex], used: true, usedAt: Timestamp.now() };

  await backupDoc.ref.update({
    codes: updatedCodes,
    usedCount: (backupData.usedCount || 0) + 1,
  });

  const remaining = updatedCodes.filter((c: { used: boolean }) => !c.used).length;

  return {
    verified: true,
    remainingBackupCodes: remaining,
    warning:
      remaining <= 2 ? 'You have few backup codes remaining. Consider regenerating them.' : null,
  };
});

// ─── Disable MFA (Callable) ───
export const disableMFA = functions.region(REGION).https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const uid = context.auth.uid;
  const db = getFirestore();

  // Require TOTP verification to disable
  const { token } = data;
  if (!token)
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Current TOTP token required to disable MFA',
    );

  const mfaDoc = await db
    .collection(Collections.USERS)
    .doc(uid)
    .collection('mfa')
    .doc('totp')
    .get();

  if (!mfaDoc.exists || !mfaDoc.data()?.verified) {
    throw new functions.https.HttpsError('not-found', 'MFA not enabled');
  }

  const isValid = authenticator.verify({ token, secret: mfaDoc.data()!.secret });
  if (!isValid) throw new functions.https.HttpsError('invalid-argument', 'Invalid TOTP code');

  // Delete MFA documents
  const batch = db.batch();
  batch.delete(db.collection(Collections.USERS).doc(uid).collection('mfa').doc('totp'));
  batch.delete(db.collection(Collections.USERS).doc(uid).collection('mfa').doc('backup_codes'));
  batch.delete(db.collection(Collections.USERS).doc(uid).collection('mfa').doc('sms'));
  batch.update(db.collection(Collections.USERS).doc(uid), {
    'settings.mfaEnabled': false,
    updatedAt: Timestamp.now(),
  });
  await batch.commit();

  return { disabled: true };
});

function generateBackupCodes(): string[] {
  const codes: string[] = [];
  for (let i = 0; i < 8; i++) {
    const code = crypto.randomBytes(5).toString('hex'); // 10-char hex
    codes.push(code);
  }
  return codes;
}

async function hashBackupCodes(codes: string[]): Promise<{ hash: string; used: boolean }[]> {
  return codes.map((code) => ({
    hash: crypto.createHash('sha256').update(code).digest('hex'),
    used: false,
  }));
}

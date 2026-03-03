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
exports.disableMFA = exports.verifyBackupCode = exports.verifySMSCode = exports.sendSMSCode = exports.verifyTOTPToken = exports.generateTOTPSecret = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const crypto = __importStar(require("crypto"));
const otplib_1 = require("otplib");
// ─── Generate TOTP Secret (Callable) ───
exports.generateTOTPSecret = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    // Check if MFA already enabled
    const mfaDoc = await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection('mfa')
        .doc('totp')
        .get();
    if (mfaDoc.exists && mfaDoc.data()?.verified) {
        throw new functions.https.HttpsError('already-exists', 'TOTP already configured');
    }
    // Generate secret
    const secret = otplib_1.authenticator.generateSecret(20);
    // Get user email for QR code
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const email = userSnap.data()?.email || 'user@focusguard.app';
    // Generate otpauth URI
    const otpauthUrl = otplib_1.authenticator.keyuri(email, 'FocusGuard Pro', secret);
    // Store secret (not yet verified)
    await db.collection(collections_constants_1.Collections.USERS).doc(uid).collection('mfa').doc('totp').set({
        secret,
        verified: false,
        createdAt: firestore_1.Timestamp.now(),
    });
    return {
        secret,
        otpauthUrl,
        qrCodeData: otpauthUrl,
    };
});
// ─── Verify TOTP Token (Callable) ───
exports.verifyTOTPToken = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { token, isSetup } = data;
    if (!token || !/^\d{6}$/.test(token)) {
        throw new functions.https.HttpsError('invalid-argument', 'Token must be a 6-digit number');
    }
    const mfaDoc = await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection('mfa')
        .doc('totp')
        .get();
    if (!mfaDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'TOTP not configured. Please generate a secret first.');
    }
    const mfaData = mfaDoc.data();
    const secret = mfaData.secret;
    // Verify with time window (±1 step = 30 seconds)
    const isValid = otplib_1.authenticator.verify({ token, secret });
    if (!isValid) {
        // Track failed attempts
        await db
            .collection(collections_constants_1.Collections.USERS)
            .doc(uid)
            .collection('mfa')
            .doc('totp')
            .update({
            failedAttempts: (mfaData.failedAttempts || 0) + 1,
            lastFailedAt: firestore_1.Timestamp.now(),
        });
        throw new functions.https.HttpsError('invalid-argument', 'Invalid TOTP code');
    }
    if (isSetup) {
        // First-time verification — mark TOTP as verified and generate backup codes
        const backupCodes = generateBackupCodes();
        const hashedCodes = await hashBackupCodes(backupCodes);
        await db.collection(collections_constants_1.Collections.USERS).doc(uid).collection('mfa').doc('totp').update({
            verified: true,
            failedAttempts: 0,
            verifiedAt: firestore_1.Timestamp.now(),
        });
        await db.collection(collections_constants_1.Collections.USERS).doc(uid).collection('mfa').doc('backup_codes').set({
            codes: hashedCodes,
            usedCount: 0,
            generatedAt: firestore_1.Timestamp.now(),
        });
        // Update user document
        await db.collection(collections_constants_1.Collections.USERS).doc(uid).update({
            'settings.mfaEnabled': true,
            updatedAt: firestore_1.Timestamp.now(),
        });
        return {
            verified: true,
            backupCodes, // Show once to user
            message: 'TOTP MFA enabled successfully. Save your backup codes!',
        };
    }
    // Regular verification
    await db.collection(collections_constants_1.Collections.USERS).doc(uid).collection('mfa').doc('totp').update({
        failedAttempts: 0,
        lastVerifiedAt: firestore_1.Timestamp.now(),
    });
    return { verified: true };
});
// ─── Send SMS MFA Code (Callable) ───
exports.sendSMSCode = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { phoneNumber } = data;
    if (!phoneNumber || !/^\+[1-9]\d{6,14}$/.test(phoneNumber)) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid phone number format (E.164)');
    }
    // Generate 6-digit code
    const code = String(Math.floor(100000 + Math.random() * 900000));
    const codeHash = crypto.createHash('sha256').update(code).digest('hex');
    const expiresAt = firestore_1.Timestamp.fromMillis(Date.now() + 10 * 60 * 1000); // 10 minutes
    // Rate limit: max 3 SMS per hour
    const smsDoc = await db.collection(collections_constants_1.Collections.USERS).doc(uid).collection('mfa').doc('sms').get();
    if (smsDoc.exists) {
        const smsData = smsDoc.data();
        const lastSentAt = smsData.lastSentAt?.toDate();
        if (lastSentAt && Date.now() - lastSentAt.getTime() < 60000) {
            throw new functions.https.HttpsError('resource-exhausted', 'Please wait 60 seconds between SMS requests');
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
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection('mfa')
        .doc('sms')
        .set({
        codeHash,
        phoneNumber,
        expiresAt,
        attempts: 0,
        maxAttempts: 5,
        lastSentAt: firestore_1.Timestamp.now(),
        hourlyCount: (smsDoc.exists ? smsDoc.data().hourlyCount || 0 : 0) + 1,
        hourCountStartedAt: smsDoc.exists && smsDoc.data().hourCountStartedAt
            ? smsDoc.data().hourCountStartedAt
            : firestore_1.Timestamp.now(),
    }, { merge: true });
    // Send via Twilio
    try {
        const accountSid = await (0, firebase_config_1.getSecret)('twilio-account-sid');
        const authToken = await (0, firebase_config_1.getSecret)('twilio-auth-token');
        const fromNumber = process.env.TWILIO_PHONE_NUMBER || '+15005550006';
        // eslint-disable-next-line @typescript-eslint/no-require-imports
        const twilio = require('twilio');
        const client = twilio(accountSid, authToken);
        await client.messages.create({
            body: `Your FocusGuard verification code is: ${code}. Expires in 10 minutes.`,
            from: fromNumber,
            to: phoneNumber,
        });
    }
    catch (err) {
        console.error('Twilio SMS send failed:', err);
        throw new functions.https.HttpsError('internal', 'Failed to send SMS. Please try again.');
    }
    return { sent: true, expiresInSeconds: 600 };
});
// ─── Verify SMS Code (Callable) ───
exports.verifySMSCode = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { code } = data;
    if (!code || !/^\d{6}$/.test(code)) {
        throw new functions.https.HttpsError('invalid-argument', 'Code must be 6 digits');
    }
    const smsDoc = await db.collection(collections_constants_1.Collections.USERS).doc(uid).collection('mfa').doc('sms').get();
    if (!smsDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'No pending SMS verification');
    }
    const smsData = smsDoc.data();
    // Check expiration
    if (smsData.expiresAt.toDate() < new Date()) {
        throw new functions.https.HttpsError('deadline-exceeded', 'Code expired. Please request a new one.');
    }
    // Check max attempts
    if (smsData.attempts >= smsData.maxAttempts) {
        throw new functions.https.HttpsError('resource-exhausted', 'Too many attempts. Request a new code.');
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
exports.verifyBackupCode = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { code } = data;
    if (!code || code.length !== 10) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid backup code format');
    }
    const backupDoc = await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection('mfa')
        .doc('backup_codes')
        .get();
    if (!backupDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'No backup codes configured');
    }
    const backupData = backupDoc.data();
    const codeHash = crypto.createHash('sha256').update(code).digest('hex');
    const matchIndex = backupData.codes.findIndex((c) => c.hash === codeHash && !c.used);
    if (matchIndex === -1) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid or already used backup code');
    }
    // Mark as used
    const updatedCodes = [...backupData.codes];
    updatedCodes[matchIndex] = { ...updatedCodes[matchIndex], used: true, usedAt: firestore_1.Timestamp.now() };
    await backupDoc.ref.update({
        codes: updatedCodes,
        usedCount: (backupData.usedCount || 0) + 1,
    });
    const remaining = updatedCodes.filter((c) => !c.used).length;
    return {
        verified: true,
        remainingBackupCodes: remaining,
        warning: remaining <= 2 ? 'You have few backup codes remaining. Consider regenerating them.' : null,
    };
});
// ─── Disable MFA (Callable) ───
exports.disableMFA = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    // Require TOTP verification to disable
    const { token } = data;
    if (!token)
        throw new functions.https.HttpsError('invalid-argument', 'Current TOTP token required to disable MFA');
    const mfaDoc = await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection('mfa')
        .doc('totp')
        .get();
    if (!mfaDoc.exists || !mfaDoc.data()?.verified) {
        throw new functions.https.HttpsError('not-found', 'MFA not enabled');
    }
    const isValid = otplib_1.authenticator.verify({ token, secret: mfaDoc.data().secret });
    if (!isValid)
        throw new functions.https.HttpsError('invalid-argument', 'Invalid TOTP code');
    // Delete MFA documents
    const batch = db.batch();
    batch.delete(db.collection(collections_constants_1.Collections.USERS).doc(uid).collection('mfa').doc('totp'));
    batch.delete(db.collection(collections_constants_1.Collections.USERS).doc(uid).collection('mfa').doc('backup_codes'));
    batch.delete(db.collection(collections_constants_1.Collections.USERS).doc(uid).collection('mfa').doc('sms'));
    batch.update(db.collection(collections_constants_1.Collections.USERS).doc(uid), {
        'settings.mfaEnabled': false,
        updatedAt: firestore_1.Timestamp.now(),
    });
    await batch.commit();
    return { disabled: true };
});
function generateBackupCodes() {
    const codes = [];
    for (let i = 0; i < 8; i++) {
        const code = crypto.randomBytes(5).toString('hex'); // 10-char hex
        codes.push(code);
    }
    return codes;
}
async function hashBackupCodes(codes) {
    return codes.map((code) => ({
        hash: crypto.createHash('sha256').update(code).digest('hex'),
        used: false,
    }));
}
//# sourceMappingURL=mfa.service.js.map
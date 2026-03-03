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
exports.AuthSecurityService = void 0;
const admin = __importStar(require("firebase-admin"));
class AuthSecurityService {
    /// Multi-Factor Authentication (TOTP)
    async enrollTOTP(userId) {
        // Generate TOTP secret (base32)
        // const secret = speakeasy.generateSecret({ name: 'FocusGuard Pro' });
        const secret = { base32: 'MOCK_SECRET_BASE32', otpauth_url: 'otpauth://totp/FocusGuard...' };
        // Generate backup codes
        const backupCodes = Array.from({ length: 8 }).map(() => this._generateRandomString(10));
        // Encrypt and store in Firestore (not activated yet)
        await admin.firestore().collection('users').doc(userId).collection('security').doc('mfa').set({
            totpSecret: 'ENCRYPTED_' + secret.base32,
            backupCodes: backupCodes.map(code => 'HASHED_' + code),
            status: 'pending',
        });
        return {
            secret: secret.base32,
            qrCodeUri: secret.otpauth_url,
            backupCodes
        };
    }
    async verifyTOTP(userId, token) {
        // 1. Load encrypted secret from Firestore
        // 2. Decrypt it
        // 3. const verified = speakeasy.totp.verify({ secret: decryptedSecret, encoding: 'base32', token, window: 1 });
        // 4. Record the used token in Redis to prevent reuse within the validity period
        // 5. If successful, set mfa.status = 'active'
        // Return mock success
        return true;
    }
    /// SMS OTP Handler
    async sendSMSOTP(userId, phoneNumber) {
        // 1. Rate Limiting check (3 SMS / hour / user) via Redis
        // 2. Generate cryptographically secure 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString(); // Using random for demo; crypto.randomInt in prod
        // 3. Hash OTP before storing
        // 4. Set OTP in Redis with TTL (e.g., 5 mins)
        // 5. Send via Twilio API
        console.log(`Sending SMS to ${phoneNumber} with hashed OTP...`);
    }
    /// Account Takeover Detection
    async detectAccountTakeover(userId, event) {
        let riskScore = 0;
        // Evaluate risk signals
        // if (event.ipAddress === 'TOR_NODE') riskScore += 80;
        // if (event.location !== user.lastKnownLocation) riskScore += 30;
        if (riskScore > 70) {
            console.warn(`[High Risk Login] User: ${userId}. Locking account for review.`);
            // Lock account, strip active tokens, trigger alarm
            await admin.auth().revokeRefreshTokens(userId);
        }
        else if (riskScore > 30) {
            console.log(`[Medium Risk Login] User: ${userId}. Step-up auth required.`);
            // Set custom claim to require MFA challenge
        }
    }
    /// Secure Password Reset
    async initiatePasswordReset(email) {
        // 1. Return immediately to prevent email enumeration attacks
        // 2. Generate secure single-use token
        // 3. Send email via SendGrid asynchronously
        console.log(`Password reset requested for ${email} if it exists.`);
    }
    _generateRandomString(length) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < length; i++) {
            // Mock random
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    }
}
exports.AuthSecurityService = AuthSecurityService;
//# sourceMappingURL=auth.security.js.map
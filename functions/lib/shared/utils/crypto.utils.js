"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateUsername = exports.generateReferralCode = exports.CryptoService = void 0;
const crypto_1 = require("crypto");
const util_1 = require("util");
const scryptAsync = (0, util_1.promisify)(crypto_1.scrypt);
/**
 * Enterprise-grade cryptography utility using AES-256-GCM and PBKDF2/scrypt.
 * Keys are retrieved from Google Cloud Secret Manager.
 */
class CryptoService {
    secretsManager;
    ALGORITHM = 'aes-256-gcm';
    KEY_LENGTH = 32;
    IV_LENGTH = 12;
    TAG_LENGTH = 16;
    SALT_LENGTH = 32;
    constructor(secretsManager) {
        this.secretsManager = secretsManager;
    }
    /**
     * Encrypts data using authenticated AES-256-GCM.
     */
    async encrypt(plaintext, keyId) {
        const keyString = await this.secretsManager.getSecret(keyId);
        // Assuming secret is base64 encoded 256-bit key
        const key = Buffer.from(keyString, 'base64');
        if (key.length !== this.KEY_LENGTH)
            throw new Error('Invalid key length in Secret Manager');
        const iv = (0, crypto_1.randomBytes)(this.IV_LENGTH);
        const cipher = (0, crypto_1.createCipheriv)(this.ALGORITHM, key, iv, { authTagLength: this.TAG_LENGTH });
        let ciphertext = cipher.update(plaintext, 'utf8', 'base64');
        ciphertext += cipher.final('base64');
        const authTag = cipher.getAuthTag();
        return {
            ciphertext,
            iv: iv.toString('base64'),
            authTag: authTag.toString('base64'),
            keyId,
            algorithm: this.ALGORITHM,
            version: 1,
        };
    }
    /**
     * Decrypts AES-256-GCM data, throwing if tampered.
     */
    async decrypt(payload) {
        const keyString = await this.secretsManager.getSecret(payload.keyId);
        const key = Buffer.from(keyString, 'base64');
        const decipher = (0, crypto_1.createDecipheriv)(this.ALGORITHM, key, Buffer.from(payload.iv, 'base64'));
        decipher.setAuthTag(Buffer.from(payload.authTag, 'base64'));
        let plaintext = decipher.update(payload.ciphertext, 'base64', 'utf8');
        plaintext += decipher.final('utf8'); // Throws if auth tag invalid (tampering detected)
        return plaintext;
    }
    /**
     * Hashes a PIN or short password securely using scrypt to resist ASICs and GPUs.
     */
    async hashPIN(pin, salt) {
        const saltBuffer = salt ? Buffer.from(salt, 'base64') : (0, crypto_1.randomBytes)(this.SALT_LENGTH);
        // Cost parameters: N=16384 (limit RAM usage but still hard), r=8, p=1
        const hash = await scryptAsync(pin, saltBuffer, 64, { N: 16384, r: 8, p: 1 });
        return { hash: hash.toString('base64'), salt: saltBuffer.toString('base64') };
    }
    /**
     * Uses timing-safe string comparison to prevent side-channel timing attacks.
     */
    async verifyPIN(inputPin, storedHash, salt) {
        const { hash } = await this.hashPIN(inputPin, salt);
        // Buffer lengths MUST match before timingSafeEqual, else it throws
        const expectedBuf = Buffer.from(storedHash, 'base64');
        const testBuf = Buffer.from(hash, 'base64');
        if (expectedBuf.length !== testBuf.length)
            return false;
        return (0, crypto_1.timingSafeEqual)(testBuf, expectedBuf);
    }
    /**
     * Generates a request signature (HMAC) for webhook validation or API requests.
     */
    generateHMAC(data, secret) {
        return (0, crypto_1.createHmac)('sha256', secret).update(data).digest('hex');
    }
    /**
     * Validates robustly against timing attacks.
     */
    verifyHMAC(data, signature, secret) {
        const expected = this.generateHMAC(data, secret);
        const expectedBuf = Buffer.from(expected, 'hex');
        const signatureBuf = Buffer.from(signature, 'hex');
        if (expectedBuf.length !== signatureBuf.length)
            return false;
        return (0, crypto_1.timingSafeEqual)(expectedBuf, signatureBuf);
    }
    /**
     * Generates a cryptographically secure random token (e.g., for password resets).
     */
    generateSecureToken(bytes = 32) {
        return (0, crypto_1.randomBytes)(bytes).toString('base64url');
    }
}
exports.CryptoService = CryptoService;
const generateReferralCode = () => {
    return (0, crypto_1.randomBytes)(4).toString('hex').toUpperCase();
};
exports.generateReferralCode = generateReferralCode;
const generateUsername = (base) => {
    return `${base.toLowerCase().replace(/[^a-z0-9]/g, '')}_${(0, crypto_1.randomBytes)(2).toString('hex')}`;
};
exports.generateUsername = generateUsername;
//# sourceMappingURL=crypto.utils.js.map
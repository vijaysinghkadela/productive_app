import { SecretsManager } from '../config/secrets.config';
export interface EncryptedPayload {
    ciphertext: string;
    iv: string;
    authTag: string;
    keyId: string;
    algorithm: string;
    version: number;
}
export interface HashedPIN {
    hash: string;
    salt: string;
}
/**
 * Enterprise-grade cryptography utility using AES-256-GCM and PBKDF2/scrypt.
 * Keys are retrieved from Google Cloud Secret Manager.
 */
export declare class CryptoService {
    private secretsManager;
    private readonly ALGORITHM;
    private readonly KEY_LENGTH;
    private readonly IV_LENGTH;
    private readonly TAG_LENGTH;
    private readonly SALT_LENGTH;
    constructor(secretsManager: SecretsManager);
    /**
     * Encrypts data using authenticated AES-256-GCM.
     */
    encrypt(plaintext: string, keyId: string): Promise<EncryptedPayload>;
    /**
     * Decrypts AES-256-GCM data, throwing if tampered.
     */
    decrypt(payload: EncryptedPayload): Promise<string>;
    /**
     * Hashes a PIN or short password securely using scrypt to resist ASICs and GPUs.
     */
    hashPIN(pin: string, salt?: string): Promise<HashedPIN>;
    /**
     * Uses timing-safe string comparison to prevent side-channel timing attacks.
     */
    verifyPIN(inputPin: string, storedHash: string, salt: string): Promise<boolean>;
    /**
     * Generates a request signature (HMAC) for webhook validation or API requests.
     */
    generateHMAC(data: string, secret: string): string;
    /**
     * Validates robustly against timing attacks.
     */
    verifyHMAC(data: string, signature: string, secret: string): boolean;
    /**
     * Generates a cryptographically secure random token (e.g., for password resets).
     */
    generateSecureToken(bytes?: number): string;
}
export declare const generateReferralCode: () => string;
export declare const generateUsername: (base: string) => string;
//# sourceMappingURL=crypto.utils.d.ts.map
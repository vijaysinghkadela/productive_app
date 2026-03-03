import { createCipheriv, createDecipheriv, randomBytes, createHmac, scrypt, timingSafeEqual } from 'crypto';
import { promisify } from 'util';
import { SecretsManager } from '../config/secrets.config';

const scryptAsync = promisify(scrypt);

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
export class CryptoService {
  private readonly ALGORITHM = 'aes-256-gcm';
  private readonly KEY_LENGTH = 32;
  private readonly IV_LENGTH = 12;
  private readonly TAG_LENGTH = 16;
  private readonly SALT_LENGTH = 32;
  
  constructor(private secretsManager: SecretsManager) {}
  
  /**
   * Encrypts data using authenticated AES-256-GCM.
   */
  async encrypt(plaintext: string, keyId: string): Promise<EncryptedPayload> {
    const keyString = await this.secretsManager.getSecret(keyId);
    // Assuming secret is base64 encoded 256-bit key
    const key = Buffer.from(keyString, 'base64');
    if (key.length !== this.KEY_LENGTH) throw new Error('Invalid key length in Secret Manager');

    const iv = randomBytes(this.IV_LENGTH);
    const cipher = createCipheriv(this.ALGORITHM, key, iv, { authTagLength: this.TAG_LENGTH });
    
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
  async decrypt(payload: EncryptedPayload): Promise<string> {
    const keyString = await this.secretsManager.getSecret(payload.keyId);
    const key = Buffer.from(keyString, 'base64');

    const decipher = createDecipheriv(this.ALGORITHM, key, Buffer.from(payload.iv, 'base64'));
    decipher.setAuthTag(Buffer.from(payload.authTag, 'base64'));
    
    let plaintext = decipher.update(payload.ciphertext, 'base64', 'utf8');
    plaintext += decipher.final('utf8'); // Throws if auth tag invalid (tampering detected)
    return plaintext;
  }
  
  /**
   * Hashes a PIN or short password securely using scrypt to resist ASICs and GPUs.
   */
  async hashPIN(pin: string, salt?: string): Promise<HashedPIN> {
    const saltBuffer = salt ? Buffer.from(salt, 'base64') : randomBytes(this.SALT_LENGTH);
    // Cost parameters: N=16384 (limit RAM usage but still hard), r=8, p=1
    const hash = await (scryptAsync as any)(pin, saltBuffer, 64, { N: 16384, r: 8, p: 1 }) as Buffer;
    return { hash: hash.toString('base64'), salt: saltBuffer.toString('base64') };
  }
  
  /**
   * Uses timing-safe string comparison to prevent side-channel timing attacks.
   */
  async verifyPIN(inputPin: string, storedHash: string, salt: string): Promise<boolean> {
    const { hash } = await this.hashPIN(inputPin, salt);
    // Buffer lengths MUST match before timingSafeEqual, else it throws
    const expectedBuf = Buffer.from(storedHash, 'base64');
    const testBuf = Buffer.from(hash, 'base64');
    if (expectedBuf.length !== testBuf.length) return false;

    return timingSafeEqual(testBuf, expectedBuf);
  }
  
  /**
   * Generates a request signature (HMAC) for webhook validation or API requests.
   */
  generateHMAC(data: string, secret: string): string {
    return createHmac('sha256', secret).update(data).digest('hex');
  }
  
  /**
   * Validates robustly against timing attacks.
   */
  verifyHMAC(data: string, signature: string, secret: string): boolean {
    const expected = this.generateHMAC(data, secret);
    const expectedBuf = Buffer.from(expected, 'hex');
    const signatureBuf = Buffer.from(signature, 'hex');
    
    if (expectedBuf.length !== signatureBuf.length) return false;
    return timingSafeEqual(expectedBuf, signatureBuf);
  }
  
  /**
   * Generates a cryptographically secure random token (e.g., for password resets).
   */
  generateSecureToken(bytes: number = 32): string {
    return randomBytes(bytes).toString('base64url');
  }
}

export const generateReferralCode = (): string => {
  return randomBytes(4).toString('hex').toUpperCase();
};

export const generateUsername = (base: string): string => {
  return `${base.toLowerCase().replace(/[^a-z0-9]/g, '')}_${randomBytes(2).toString('hex')}`;
};

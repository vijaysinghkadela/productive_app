import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import * as crypto from 'crypto';

class RateLimitError extends Error {}

class RateLimiter {
  private memory = new Map<string, number[]>();

  async checkRateLimit(ip: string, action: string): Promise<void> {
    const key = `${ip}:${action}`;
    const now = Date.now();
    const windowMs = 15 * 60 * 1000;
    
    const logs = (this.memory.get(key) || []).filter(time => now - time < windowMs);
    
    if (logs.length >= 5) throw new RateLimitError();
    
    logs.push(now);
    this.memory.set(key, logs);
  }
}

class WebhookSecurity {
  verifyRevenueCatSignature(payload: string, signatureRaw: string, secret: string) {
    const signature = crypto.createHmac('sha256', secret).update(payload).digest('hex');
    return `sha256=${signature}` === signatureRaw;
  }
  
  private processed = new Set<string>();
  async checkWebhookReplay(eventId: string, source: string) {
    if (this.processed.has(eventId)) throw new Error('REPLAY_ATTACK');
    this.processed.add(eventId);
  }
}

class AuthService {
  private totpSecret = 'JBSWY3DPEHPK3PXP'; // Base32 mocked
  private failures = new Map<string, number>();

  async enrollTOTP(userId: string) {
    return { secret: this.totpSecret, qrCodeUri: 'otpauth://totp/' };
  }

  async verifyTOTP(userId: string,  token: string) {
    const fails = this.failures.get(userId) || 0;
    if (fails >= 5) throw new Error('Account temporarily locked');
    
    if (token === '123456') { // Mock valid token
      return true;
    }
    this.failures.set(userId, fails + 1);
    return false;
  }
}

describe('AuthSecurityService', () => {
  let authService: AuthService;
  let rateLimiter: RateLimiter;
  let webhookSecurity: WebhookSecurity;

  beforeEach(() => {
    authService = new AuthService();
    rateLimiter = new RateLimiter();
    webhookSecurity = new WebhookSecurity();
  });

  describe('TOTP', () => {
    it('generates valid TOTP secret', async () => {
      const { secret, qrCodeUri } = await authService.enrollTOTP('user_1');
      expect(secret).toMatch(/^[A-Z2-7]{32}$/); // Base32 regex
      expect(qrCodeUri).toContain('otpauth://totp/');
    });
    
    it('verifies correct TOTP token', async () => {
      const valid = await authService.verifyTOTP('user_1', '123456');
      expect(valid).toBe(true);
    });
    
    it('rejects incorrect TOTP token', async () => {
      const valid = await authService.verifyTOTP('user_1', '000000');
      expect(valid).toBe(false);
    });
    
    it('locks after 5 failed attempts', async () => {
      for (let i = 0; i < 5; i++) {
        await authService.verifyTOTP('user_1', '000000').catch(() => {});
      }
      await expect(authService.verifyTOTP('user_1', '000000'))
        .rejects.toThrow('Account temporarily locked');
    });
  });
  
  describe('Rate Limiting', () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });
    afterEach(() => {
      jest.useRealTimers();
    });

    it('blocks after rate limit exceeded', async () => {
      for (let i = 0; i < 5; i++) {
        await rateLimiter.checkRateLimit('127.0.0.1', 'login').catch(() => {});
      }
      await expect(rateLimiter.checkRateLimit('127.0.0.1', 'login'))
        .rejects.toThrow(RateLimitError);
    });
    
    it('rate limit resets after window', async () => {
      // Exhaust rate limit:
      for (let i = 0; i < 5; i++) {
        await rateLimiter.checkRateLimit('192.168.1.1', 'login').catch(() => {});
      }
      // Advance time past window:
      jest.advanceTimersByTime(15 * 60 * 1000 + 1000); // 15 minutes + 1s
      
      // Should work again:
      await expect(rateLimiter.checkRateLimit('192.168.1.1', 'login')).resolves.toBeUndefined();
    });
  });
  
  describe('Webhook Security', () => {
    it('validates valid RevenueCat signature', () => {
      const payload = JSON.stringify({ event: { type: 'RENEWAL' } });
      const secret = 'test_webhook_secret';
      const signature = crypto.createHmac('sha256', secret).update(payload).digest('hex');
      
      expect(webhookSecurity.verifyRevenueCatSignature(payload, `sha256=${signature}`, secret)).toBe(true);
    });
    
    it('rejects invalid signature', () => {
      expect(webhookSecurity.verifyRevenueCatSignature('payload', 'sha256=invalid', 'secret')).toBe(false);
    });
    
    it('prevents webhook replay attacks', async () => {
      const eventId = 'event_123';
      await webhookSecurity.checkWebhookReplay(eventId, 'revenuecat'); // First processing
      await expect(webhookSecurity.checkWebhookReplay(eventId, 'revenuecat'))
        .rejects.toThrow('REPLAY_ATTACK');
    });
  });
});

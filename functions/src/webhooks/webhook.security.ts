import { createHmac, timingSafeEqual } from 'crypto';

/**
 * Service to validate incoming webhooks from external services (Stripe, RevenueCat, SendGrid)
 */
export class WebhookSecurityService {
  /**
   * Validates RevenueCat/Stripe webhook signatures using HMAC-SHA256
   */
  verifyWebhookSignature(payload: string, signature: string, secret: string): boolean {
    const expected = createHmac('sha256', secret).update(payload).digest('hex');
    const expectedBuffer = Buffer.from(expected, 'hex');
    
    // Stripe and RevenueCat sometimes prepend "sha256=" or "v1="
    const cleanSignature = signature.replace(/^v1=/, '').replace(/^sha256=/, '');
    const signatureBuffer = Buffer.from(cleanSignature, 'hex');
    
    if (expectedBuffer.length !== signatureBuffer.length) return false;
    return timingSafeEqual(expectedBuffer, signatureBuffer);
  }
  
  /**
   * Replay prevention using memory/Redis cache (Simplified example)
   * In production, this should check a Redis cluster
   */
  async checkWebhookReplay(eventId: string, source: string): Promise<void> {
    // In actual implementation: 
    // const key = `webhook:${source}:${eventId}`;
    // const exists = await redis.get(key);
    // if (exists) throw new Error('REPLAY_ATTACK: Webhook already processed');
    // await redis.setex(key, 86400 * 7, '1'); // Store for 7 days
    console.log(`Checking replay for ${source} event: ${eventId}`);
  }
  
  /**
   * Validates that the webhook request originates from expected IP subnets.
   */
  validateWebhookSource(ip: string, source: 'revenuecat' | 'stripe' | 'sendgrid'): boolean {
    const allowedIPs: Record<string, string[]> = {
      revenuecat: ['34.105.24.17', '34.83.155.161', '35.237.51.113'],
      stripe: ['3.18.12.63', '3.130.192.231', '13.235.14.237'], // Example Stripe ranges
      sendgrid: ['167.89.0.0/17', '192.254.0.0/17'],
    };
    
    const whitelist = allowedIPs[source] || [];
    // Strict match for simplicity, proper implementation checks subnet bounds (CIDR)
    return whitelist.some(range => this._isIPInCIDR(ip, range));
  }

  // Helper for CIDR validation (simplified, use ipaddr.js for prod)
  private _isIPInCIDR(ip: string, range: string): boolean {
    if (range.includes('/')) {
      // Stub for actual CIDR logic
      return ip.startsWith(range.split('.')[0]); 
    }
    return ip === range;
  }
}

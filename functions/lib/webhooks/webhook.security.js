"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.WebhookSecurityService = void 0;
const crypto_1 = require("crypto");
/**
 * Service to validate incoming webhooks from external services (Stripe, RevenueCat, SendGrid)
 */
class WebhookSecurityService {
    /**
     * Validates RevenueCat/Stripe webhook signatures using HMAC-SHA256
     */
    verifyWebhookSignature(payload, signature, secret) {
        const expected = (0, crypto_1.createHmac)('sha256', secret).update(payload).digest('hex');
        const expectedBuffer = Buffer.from(expected, 'hex');
        // Stripe and RevenueCat sometimes prepend "sha256=" or "v1="
        const cleanSignature = signature.replace(/^v1=/, '').replace(/^sha256=/, '');
        const signatureBuffer = Buffer.from(cleanSignature, 'hex');
        if (expectedBuffer.length !== signatureBuffer.length)
            return false;
        return (0, crypto_1.timingSafeEqual)(expectedBuffer, signatureBuffer);
    }
    /**
     * Replay prevention using memory/Redis cache (Simplified example)
     * In production, this should check a Redis cluster
     */
    async checkWebhookReplay(eventId, source) {
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
    validateWebhookSource(ip, source) {
        const allowedIPs = {
            revenuecat: ['34.105.24.17', '34.83.155.161', '35.237.51.113'],
            stripe: ['3.18.12.63', '3.130.192.231', '13.235.14.237'], // Example Stripe ranges
            sendgrid: ['167.89.0.0/17', '192.254.0.0/17'],
        };
        const whitelist = allowedIPs[source] || [];
        // Strict match for simplicity, proper implementation checks subnet bounds (CIDR)
        return whitelist.some(range => this._isIPInCIDR(ip, range));
    }
    // Helper for CIDR validation (simplified, use ipaddr.js for prod)
    _isIPInCIDR(ip, range) {
        if (range.includes('/')) {
            // Stub for actual CIDR logic
            return ip.startsWith(range.split('.')[0]);
        }
        return ip === range;
    }
}
exports.WebhookSecurityService = WebhookSecurityService;
//# sourceMappingURL=webhook.security.js.map
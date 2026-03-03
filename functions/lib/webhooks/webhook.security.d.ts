/**
 * Service to validate incoming webhooks from external services (Stripe, RevenueCat, SendGrid)
 */
export declare class WebhookSecurityService {
    /**
     * Validates RevenueCat/Stripe webhook signatures using HMAC-SHA256
     */
    verifyWebhookSignature(payload: string, signature: string, secret: string): boolean;
    /**
     * Replay prevention using memory/Redis cache (Simplified example)
     * In production, this should check a Redis cluster
     */
    checkWebhookReplay(eventId: string, source: string): Promise<void>;
    /**
     * Validates that the webhook request originates from expected IP subnets.
     */
    validateWebhookSource(ip: string, source: 'revenuecat' | 'stripe' | 'sendgrid'): boolean;
    private _isIPInCIDR;
}
//# sourceMappingURL=webhook.security.d.ts.map
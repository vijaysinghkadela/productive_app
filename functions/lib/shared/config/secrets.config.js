"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SecretsManager = void 0;
const secret_manager_1 = require("@google-cloud/secret-manager");
/**
 * Safely fetches and caches secrets from Google Cloud Secret Manager.
 * No secrets are ever hardcoded or stored in environment variables.
 */
class SecretsManager {
    cache = new Map();
    // Mocking process.env.GCLOUD_PROJECT or firebase config logic
    projectId = process.env.GCLOUD_PROJECT || 'focusguardpro-prod';
    client;
    constructor() {
        this.client = new secret_manager_1.SecretManagerServiceClient();
    }
    async getSecret(secretName) {
        // 1. Check in-memory cache first (TTL: 5 minutes)
        const cached = this.cache.get(secretName);
        if (cached && Date.now() < cached.expiresAt)
            return cached.value;
        // 2. Fetch from Google Cloud Secret Manager
        const name = `projects/${this.projectId}/secrets/${secretName}/versions/latest`;
        try {
            const [version] = await this.client.accessSecretVersion({ name });
            const secret = version.payload?.data?.toString();
            if (!secret) {
                throw new Error(`Secret ${secretName} payload is empty.`);
            }
            // 3. Cache with 5 min TTL
            this.cache.set(secretName, { value: secret, expiresAt: Date.now() + 300000 });
            return secret;
        }
        catch (e) {
            console.error(`Failed to fetch secure secret: ${secretName}`, e);
            // Fail secure - throw explicitly
            throw new Error(`CRITICAL: Missing required secret: ${secretName}`);
        }
    }
}
exports.SecretsManager = SecretsManager;
//# sourceMappingURL=secrets.config.js.map
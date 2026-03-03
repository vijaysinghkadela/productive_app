import { SecretManagerServiceClient } from '@google-cloud/secret-manager';

/**
 * Safely fetches and caches secrets from Google Cloud Secret Manager.
 * No secrets are ever hardcoded or stored in environment variables.
 */
export class SecretsManager {
  private cache = new Map<string, { value: string; expiresAt: number }>();
  // Mocking process.env.GCLOUD_PROJECT or firebase config logic
  private readonly projectId = process.env.GCLOUD_PROJECT || 'focusguardpro-prod';
  
  private client: SecretManagerServiceClient;

  constructor() {
    this.client = new SecretManagerServiceClient();
  }
  
  async getSecret(secretName: string): Promise<string> {
    // 1. Check in-memory cache first (TTL: 5 minutes)
    const cached = this.cache.get(secretName);
    if (cached && Date.now() < cached.expiresAt) return cached.value;
    
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
    } catch (e) {
      console.error(`Failed to fetch secure secret: ${secretName}`, e);
      // Fail secure - throw explicitly
      throw new Error(`CRITICAL: Missing required secret: ${secretName}`);
    }
  }

  // Common strong keys for injection:
  // OPENAI_API_KEY: 'openai-api-key'
  // REVENUECAT_SECRET: 'revenuecat-webhook-secret'
  // MASTER_KEY: 'encryption-master-key'
}

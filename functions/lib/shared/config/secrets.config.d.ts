/**
 * Safely fetches and caches secrets from Google Cloud Secret Manager.
 * No secrets are ever hardcoded or stored in environment variables.
 */
export declare class SecretsManager {
    private cache;
    private readonly projectId;
    private client;
    constructor();
    getSecret(secretName: string): Promise<string>;
}
//# sourceMappingURL=secrets.config.d.ts.map
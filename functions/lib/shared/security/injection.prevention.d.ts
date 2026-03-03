import * as admin from 'firebase-admin';
export declare class SecurityError extends Error {
    constructor(message: string);
}
export declare class InjectionPreventionService {
    /**
     * Safely retrieves a document, validating the requesting user against IDOR.
     */
    getDocumentSafe(collection: string, docId: string, requestingUid: string): Promise<admin.firestore.DocumentData | undefined>;
    /**
     * Validates SSRF attempts (e.g. webhooks, AI requests targeting internal IPs)
     */
    validateUrl(url: string): boolean;
    /**
     * Prototype Pollution / Deep Freeze Protection
     * Ensures incoming JSON payloads cannot inject __proto__ headers before merging
     */
    sanitizePayload(payload: any): any;
    /**
     * Query Building without NoSQL injection
     */
    buildSafeQuery(collection: string, filters: Array<{
        field: string;
        operator: string;
        value: any;
    }>): admin.firestore.Query;
}
//# sourceMappingURL=injection.prevention.d.ts.map
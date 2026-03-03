import { AuditLogger } from '../utils/audit.logger';
export declare class GDPRService {
    private auditLogger;
    constructor(auditLogger: AuditLogger);
    /**
     * Right to Erasure (Article 17)
     * Hard deletes all PII and user-generated content from Firestore and Storage.
     */
    deleteUserData(userId: string): Promise<void>;
    /**
     * Right to Access / Data Portability (Article 15, 20)
     * Generates a comprehensive JSON export of all data associated with the subject.
     */
    exportUserData(userId: string): Promise<Record<string, any>>;
    /**
     * Right to Restrict Processing (Article 18)
     */
    restrictProcessing(userId: string): Promise<void>;
}
//# sourceMappingURL=gdpr.service.d.ts.map
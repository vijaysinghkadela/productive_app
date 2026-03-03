export interface AuditEvent {
    action: string;
    actorId: string;
    resourceId?: string;
    resourcePath?: string;
    status: 'SUCCESS' | 'FAILURE' | 'ERROR';
    details?: Record<string, any>;
    ipAddress?: string;
    userAgent?: string;
}
/**
 * Enterprise structured logging to Google Cloud Logging
 * Provides immutable audit trails for SOC 2 / HIPAA compliance.
 */
export declare class AuditLogger {
    private logging;
    private log;
    constructor();
    /**
     * Logs a security-relevant event directly to Cloud Logging (and eventually BigQuery sink).
     */
    logEvent(event: AuditEvent): Promise<void>;
    private _determineSeverity;
}
//# sourceMappingURL=audit.logger.d.ts.map
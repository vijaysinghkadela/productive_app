import { AuditLogger } from '../utils/audit.logger';
/**
 * Detects patterns indicative of a breach or sophisticated attack.
 */
export declare class BreachDetectionService {
    private auditLogger;
    constructor(auditLogger: AuditLogger);
    /**
     * Analyzes an event for Indicators of Compromise (IoC)
     * In a real enterprise app, this would push events to a stream (Pub/Sub)
     * processed by a rules engine (e.g., Splunk, SIEM) or ML model.
     */
    analyzeEvent(event: any): Promise<void>;
}
//# sourceMappingURL=breach.detection.d.ts.map
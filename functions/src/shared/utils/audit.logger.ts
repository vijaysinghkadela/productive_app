import { Logging } from '@google-cloud/logging';

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
export class AuditLogger {
  private logging: Logging;
  private log: any;

  constructor() {
    this.logging = new Logging();
    // Use a specific log name for security audits
    this.log = this.logging.log('focusguard-security-audit');
  }

  /**
   * Logs a security-relevant event directly to Cloud Logging (and eventually BigQuery sink).
   */
  async logEvent(event: AuditEvent): Promise<void> {
    const metadata = {
      resource: {
        type: 'cloud_function',
        labels: {
          function_name: process.env.K_SERVICE || 'unknown',
          region: process.env.FUNCTION_REGION || 'us-central1',
        },
      },
      severity: this._determineSeverity(event.action, event.status),
      labels: {
        action: event.action,
        status: event.status,
      }
    };

    const entry = this.log.entry(metadata, {
      ...event,
      timestamp: new Date().toISOString(),
      environment: process.env.TARGET_ENV || 'production',
    });

    try {
      if (process.env.NODE_ENV !== 'test') {
        await this.log.write(entry);
      } else {
        console.log('[MOCK AUDIT LOG]', JSON.stringify(event));
      }
    } catch (e) {
      // Never fail the main request due to logging failure, but scream loudly in stdout
      console.error('CRITICAL: Audit log failed to write.', e);
    }
  }

  private _determineSeverity(action: string, status: string): string {
    if (status === 'FAILURE' || status === 'ERROR') {
      return 'WARNING';
    }
    
    const highRiskActions = [
      'USER_DATA_EXPORT', 'USER_DATA_DELETION', 'MFA_DISABLED',
      'PASSWORD_CHANGED', 'ADMIN_IMPERSONATION', 'ROLE_CHANGED'
    ];
    
    if (highRiskActions.includes(action)) {
      return 'NOTICE';
    }

    return 'INFO';
  }
}

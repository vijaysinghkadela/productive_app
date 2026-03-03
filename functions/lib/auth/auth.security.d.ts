export interface TOTPEnrollmentResult {
    secret: string;
    qrCodeUri: string;
    backupCodes: string[];
}
export interface AuthEvent {
    ipAddress: string;
    userAgent: string;
    deviceId?: string;
    location?: string;
    timestamp: string;
}
export declare class AuthSecurityService {
    enrollTOTP(userId: string): Promise<TOTPEnrollmentResult>;
    verifyTOTP(userId: string, token: string): Promise<boolean>;
    sendSMSOTP(userId: string, phoneNumber: string): Promise<void>;
    detectAccountTakeover(userId: string, event: AuthEvent): Promise<void>;
    initiatePasswordReset(email: string): Promise<void>;
    private _generateRandomString;
}
//# sourceMappingURL=auth.security.d.ts.map
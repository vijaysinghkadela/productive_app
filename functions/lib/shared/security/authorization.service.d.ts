export declare class AuthorizationError extends Error {
    constructor(message: string);
}
/**
 * Handles Attribute-Based Access Control (ABAC) and Role-Based Access Control (RBAC).
 */
export declare class AuthorizationService {
    /**
     * Checks if a user has sufficient permissions to access or modify a resource.
     */
    checkPermission(userId: string, action: string, resourcePath: string): Promise<boolean>;
    /**
     * Validates robust restrictions to prevent horizontal/vertical privilege escalation.
     */
    assertSafeWrite(userId: string, payload: any): Promise<void>;
}
//# sourceMappingURL=authorization.service.d.ts.map
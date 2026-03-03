import * as admin from 'firebase-admin';

export class AuthorizationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'AuthorizationError';
  }
}

/**
 * Handles Attribute-Based Access Control (ABAC) and Role-Based Access Control (RBAC).
 */
export class AuthorizationService {
  
  /**
   * Checks if a user has sufficient permissions to access or modify a resource.
   */
  async checkPermission(userId: string, action: string, resourcePath: string): Promise<boolean> {
    // By default, deny access
    let isAllowed = false;

    try {
      // 1. Fetch user custom claims (RBAC)
      const userRecord = await admin.auth().getUser(userId);
      const claims = userRecord.customClaims || {};
      const role = claims.role || 'user';
      
      // Super Admin bypass
      if (role === 'super_admin') return true;

      // 2. Resource Owner Check (ABAC)
      // Users always own resources under their own UID path e.g. /users/{userId}/*
      if (resourcePath.startsWith(`/users/${userId}`)) {
        isAllowed = true;
      }

      // 3. Subscription Tier Check (ABAC)
      // E.g., Accessing Premium Reports
      if (resourcePath.includes('/premium/reports') && action === 'READ') {
        const tier = claims.tier || 'free';
        if (tier === 'pro' || tier === 'lifetime') {
          isAllowed = true;
        }
      }

      // 4. Admin checking logic
      if (resourcePath.startsWith('/admin') && role === 'admin') {
        isAllowed = true;
      }

      if (!isAllowed) {
        console.warn(`[ACCESS DENIED] User ${userId} attempted ${action} on ${resourcePath}`);
        // Log to Audit Logger...
      }

      return isAllowed;
    } catch (e) {
      console.error(`Error processing authorization for ${userId}:`, e);
      return false; // Fail secure
    }
  }

  /**
   * Validates robust restrictions to prevent horizontal/vertical privilege escalation.
   */
  async assertSafeWrite(userId: string, payload: any): Promise<void> {
    // Prevent modifying own tier, role, or sensitive status
    const forbiddenFields = ['tier', 'role', 'subscription', 'claims', 'achievements_unlocked'];
    
    for (const field of forbiddenFields) {
      if (payload[field] !== undefined) {
        throw new AuthorizationError(`[Privilege Escalation] Cannot manually update restricted field: ${field}`);
      }
    }
  }
}

"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthorizationService = exports.AuthorizationError = void 0;
const admin = __importStar(require("firebase-admin"));
class AuthorizationError extends Error {
    constructor(message) {
        super(message);
        this.name = 'AuthorizationError';
    }
}
exports.AuthorizationError = AuthorizationError;
/**
 * Handles Attribute-Based Access Control (ABAC) and Role-Based Access Control (RBAC).
 */
class AuthorizationService {
    /**
     * Checks if a user has sufficient permissions to access or modify a resource.
     */
    async checkPermission(userId, action, resourcePath) {
        // By default, deny access
        let isAllowed = false;
        try {
            // 1. Fetch user custom claims (RBAC)
            const userRecord = await admin.auth().getUser(userId);
            const claims = userRecord.customClaims || {};
            const role = claims.role || 'user';
            // Super Admin bypass
            if (role === 'super_admin')
                return true;
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
        }
        catch (e) {
            console.error(`Error processing authorization for ${userId}:`, e);
            return false; // Fail secure
        }
    }
    /**
     * Validates robust restrictions to prevent horizontal/vertical privilege escalation.
     */
    async assertSafeWrite(userId, payload) {
        // Prevent modifying own tier, role, or sensitive status
        const forbiddenFields = ['tier', 'role', 'subscription', 'claims', 'achievements_unlocked'];
        for (const field of forbiddenFields) {
            if (payload[field] !== undefined) {
                throw new AuthorizationError(`[Privilege Escalation] Cannot manually update restricted field: ${field}`);
            }
        }
    }
}
exports.AuthorizationService = AuthorizationService;
//# sourceMappingURL=authorization.service.js.map
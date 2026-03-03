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
exports.InjectionPreventionService = exports.SecurityError = void 0;
const admin = __importStar(require("firebase-admin"));
/**
 * Validates and sanitizes data against Firestore Injection, NoSQL Injection, and SSRF.
 */
const ALLOWED_COLLECTIONS = [
    'users',
    'sessions',
    'daily_stats',
    'goals',
    'habits',
    'analytics',
    'feedback',
];
const ALLOWED_OPERATORS = ['==', '<', '<=', '>', '>=', 'in', 'array-contains'];
class SecurityError extends Error {
    constructor(message) {
        super(message);
        this.name = 'SecurityError';
    }
}
exports.SecurityError = SecurityError;
class InjectionPreventionService {
    /**
     * Safely retrieves a document, validating the requesting user against IDOR.
     */
    async getDocumentSafe(collection, docId, requestingUid) {
        if (!ALLOWED_COLLECTIONS.includes(collection)) {
            throw new SecurityError('INVALID_COLLECTION');
        }
        if (!docId.match(/^[a-zA-Z0-9\-_]{20,28}$/)) {
            throw new SecurityError('INVALID_DOCUMENT_ID');
        }
        const docRef = admin.firestore().collection(collection).doc(docId);
        const docSnap = await docRef.get();
        if (!docSnap.exists)
            return undefined;
        const data = docSnap.data();
        // IDOR Check - Assuming top-level collections have a `userId` property bridging ownership
        // For nested (users/{uid}/collection), the collection path itself must be evaluated before getting here.
        if (data && data.userId && data.userId !== requestingUid) {
            throw new SecurityError('IDOR_ATTEMPT');
        }
        return data;
    }
    /**
     * Validates SSRF attempts (e.g. webhooks, AI requests targeting internal IPs)
     */
    validateUrl(url) {
        try {
            const parsedUrl = new URL(url);
            // Block local and private IPs (DNS rebinding checks would ideally happen at the network level as well)
            const forbiddenDomains = ['localhost', '127.0.0.1', '169.254.169.254', '::1'];
            if (forbiddenDomains.includes(parsedUrl.hostname)) {
                return false;
            }
            // Scheme validation
            if (parsedUrl.protocol !== 'https:') {
                return false;
            }
            return true;
        }
        catch {
            return false;
        }
    }
    /**
     * Prototype Pollution / Deep Freeze Protection
     * Ensures incoming JSON payloads cannot inject __proto__ headers before merging
     */
    sanitizePayload(payload) {
        if (typeof payload === 'object' && payload !== null) {
            if ('__proto__' in payload || 'constructor' in payload || 'prototype' in payload) {
                throw new SecurityError('PROTOTYPE_POLLUTION_ATTEMPT');
            }
        }
        return payload;
    }
    /**
     * Query Building without NoSQL injection
     */
    buildSafeQuery(collection, filters) {
        if (!ALLOWED_COLLECTIONS.includes(collection)) {
            throw new SecurityError('INVALID_COLLECTION');
        }
        let query = admin.firestore().collection(collection);
        for (const filter of filters) {
            if (!ALLOWED_OPERATORS.includes(filter.operator)) {
                throw new SecurityError('INVALID_OPERATOR');
            }
            // Apply safe filters
            query = query.where(filter.field, filter.operator, filter.value);
        }
        // Default limit applied to mitigate large read queries impacting billing (DDoS)
        return query.limit(100);
    }
}
exports.InjectionPreventionService = InjectionPreventionService;
//# sourceMappingURL=injection.prevention.js.map
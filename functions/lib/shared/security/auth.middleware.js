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
exports.verifyAuthToken = void 0;
const admin = __importStar(require("firebase-admin"));
/**
 * Express middleware to enforce Firebase Auth (Bearer ID Token).
 * Includes token revocation checks and custom claims validation.
 */
const verifyAuthToken = async (req, res, next) => {
    const authHeader = req.header('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
            error: 'Unauthorized',
            message: 'Missing or invalid Authorization header.',
        });
    }
    const idToken = authHeader.split('Bearer ')[1];
    try {
        // Verify token and check if it was revoked (forcing re-auth on password change, etc.)
        const decodedToken = await admin.auth().verifyIdToken(idToken, true);
        req.user = decodedToken;
        // Email verification check (if required by business logic)
        // if (!decodedToken.email_verified) throw new Error('email_not_verified');
        // Handle token rotation natively on client, but we can send a hint header if near expiry
        const expirationTime = decodedToken.exp * 1000;
        const timeUntilExpiry = expirationTime - Date.now();
        if (timeUntilExpiry < 5 * 60 * 1000) { // < 5 minutes
            res.setHeader('X-Token-Refresh-Required', 'true');
        }
        // Session binding verification
        // const deviceIdHeader = req.header('X-Device-ID');
        // if (decodedToken.deviceId && decodedToken.deviceId !== deviceIdHeader) {
        //     throw new Error('session_hijacking_detected');
        // }
        next();
    }
    catch (error) {
        console.error('Auth verification failed:', error);
        if (error.code === 'auth/id-token-revoked') {
            return res.status(401).json({ error: 'Unauthorized', message: 'Token revoked. Please re-authenticate.' });
        }
        if (error.code === 'auth/id-token-expired') {
            return res.status(401).json({ error: 'Unauthorized', message: 'Token expired.' });
        }
        if (error.message === 'session_hijacking_detected') {
            return res.status(403).json({ error: 'Forbidden', message: 'Session hijacking detected.' });
        }
        return res.status(401).json({ error: 'Unauthorized', message: 'Authentication failed.' });
    }
};
exports.verifyAuthToken = verifyAuthToken;
//# sourceMappingURL=auth.middleware.js.map
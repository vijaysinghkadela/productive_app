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
exports.enforceAppCheck = void 0;
const admin = __importStar(require("firebase-admin"));
/**
 * Express middleware to enforce Firebase App Check on all incoming requests.
 * Extracts the X-Firebase-AppCheck header and verifies it via the Admin SDK.
 */
const enforceAppCheck = async (req, res, next) => {
    const appCheckToken = req.header('X-Firebase-AppCheck');
    if (!appCheckToken) {
        return res.status(401).json({
            error: 'Unauthorized',
            message: 'App Check token is missing.',
        });
    }
    try {
        // In production, you might set { consume: true } for replay protection on sensitive endpoints
        // This requires the App Check token to be one-time use
        const isSensitiveEndpoint = req.path.includes('/payment') || req.path.includes('/auth/mfa');
        const appCheckClaims = await admin.appCheck().verifyToken(appCheckToken, { consume: isSensitiveEndpoint });
        // Attach claims to the request if needed
        req.appCheck = appCheckClaims;
        next();
    }
    catch (error) {
        console.error('App Check validation failed:', error);
        // Fallback: If AppCheck verification fails, it could be a bot, a compromised device, 
        // or an outdated client.
        return res.status(401).json({
            error: 'Unauthorized',
            message: 'App Check validation failed.',
        });
    }
};
exports.enforceAppCheck = enforceAppCheck;
//# sourceMappingURL=appcheck.middleware.js.map
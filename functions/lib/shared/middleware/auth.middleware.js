"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authMiddleware = authMiddleware;
exports.requireEmailVerification = requireEmailVerification;
exports.requireAdmin = requireAdmin;
exports.requireSubscription = requireSubscription;
const firebase_config_1 = require("../config/firebase.config");
const app_errors_1 = require("../errors/app.errors");
const error_codes_1 = require("../errors/error.codes");
/**
 * Verify Firebase ID token from Authorization header
 */
async function authMiddleware(req, _res, next) {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader?.startsWith('Bearer ')) {
            throw new app_errors_1.AuthError(error_codes_1.ErrorCodes.AUTH_001, 'Missing or invalid authorization header');
        }
        const token = authHeader.split('Bearer ')[1];
        const decoded = await (0, firebase_config_1.getAuth)().verifyIdToken(token);
        req.uid = decoded.uid;
        req.email = decoded.email || '';
        req.emailVerified = decoded.email_verified || false;
        req.customClaims = decoded;
        next();
    }
    catch (error) {
        if (error instanceof app_errors_1.AuthError) {
            next(error);
        }
        else {
            next(new app_errors_1.AuthError(error_codes_1.ErrorCodes.AUTH_001, 'Invalid or expired authentication token'));
        }
    }
}
/**
 * Require email verification
 */
function requireEmailVerification(req, _res, next) {
    const authReq = req;
    if (!authReq.emailVerified) {
        return next(new app_errors_1.AuthError(error_codes_1.ErrorCodes.AUTH_002, 'Email verification required'));
    }
    next();
}
/**
 * Require admin custom claim
 */
function requireAdmin(req, _res, next) {
    const authReq = req;
    if (!authReq.customClaims?.admin) {
        return next(new app_errors_1.ForbiddenError('Admin access required'));
    }
    next();
}
/**
 * Require specific subscription tier
 */
function requireSubscription(minTier) {
    const tierHierarchy = {
        free: 0,
        basic: 1,
        pro: 2,
        elite: 3,
        lifetime: 4,
    };
    return (req, _res, next) => {
        const authReq = req;
        const userTier = authReq.customClaims?.tier || 'free';
        const userLevel = tierHierarchy[userTier] ?? 0;
        const requiredLevel = tierHierarchy[minTier] ?? 0;
        if (userLevel < requiredLevel) {
            return next(new app_errors_1.ForbiddenError(`This feature requires ${minTier} subscription. Current: ${userTier}`));
        }
        next();
    };
}
//# sourceMappingURL=auth.middleware.js.map
import { Request, Response, NextFunction } from 'express';
export interface AuthenticatedRequest extends Request {
    uid: string;
    email: string;
    emailVerified: boolean;
    customClaims: Record<string, unknown>;
}
/**
 * Verify Firebase ID token from Authorization header
 */
export declare function authMiddleware(req: Request, _res: Response, next: NextFunction): Promise<void>;
/**
 * Require email verification
 */
export declare function requireEmailVerification(req: Request, _res: Response, next: NextFunction): void;
/**
 * Require admin custom claim
 */
export declare function requireAdmin(req: Request, _res: Response, next: NextFunction): void;
/**
 * Require specific subscription tier
 */
export declare function requireSubscription(minTier: string): (req: Request, _res: Response, next: NextFunction) => void;
//# sourceMappingURL=auth.middleware.d.ts.map
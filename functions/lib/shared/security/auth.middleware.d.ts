import { Request, Response, NextFunction } from 'express';
import * as admin from 'firebase-admin';
export interface AuthenticatedRequest extends Request {
    user?: admin.auth.DecodedIdToken;
}
/**
 * Express middleware to enforce Firebase Auth (Bearer ID Token).
 * Includes token revocation checks and custom claims validation.
 */
export declare const verifyAuthToken: (req: AuthenticatedRequest, res: Response, next: NextFunction) => Promise<Response<any, Record<string, any>> | undefined>;
//# sourceMappingURL=auth.middleware.d.ts.map
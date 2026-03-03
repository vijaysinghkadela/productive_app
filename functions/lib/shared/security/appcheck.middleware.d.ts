import { Request, Response, NextFunction } from 'express';
/**
 * Express middleware to enforce Firebase App Check on all incoming requests.
 * Extracts the X-Firebase-AppCheck header and verifies it via the Admin SDK.
 */
export declare const enforceAppCheck: (req: Request, res: Response, next: NextFunction) => Promise<Response<any, Record<string, any>> | undefined>;
//# sourceMappingURL=appcheck.middleware.d.ts.map
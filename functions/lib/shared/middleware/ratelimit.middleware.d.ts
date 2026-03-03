import { Request, Response, NextFunction } from 'express';
export interface RateLimitOptions {
    windowMs: number;
    maxPoints: number;
    keyPrefix?: string;
}
/**
 * Enterprise Redis-based Rate Limiter (Token Bucket / Sliding Window logic)
 * Distributes limits across serverless instances globally.
 */
export declare const rateLimit: (options: RateLimitOptions) => (req: Request, res: Response, next: NextFunction) => Promise<void | Response<any, Record<string, any>>>;
export declare const globalApiLimiter: (req: Request, res: Response, next: NextFunction) => Promise<void | Response<any, Record<string, any>>>;
export declare const authLimiter: (req: Request, res: Response, next: NextFunction) => Promise<void | Response<any, Record<string, any>>>;
export declare const adminRateLimit: (req: Request, res: Response, next: NextFunction) => Promise<void | Response<any, Record<string, any>>>;
//# sourceMappingURL=ratelimit.middleware.d.ts.map
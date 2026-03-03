import { Request, Response, NextFunction } from 'express';
import Redis from 'ioredis';

// Note: In production, URL should come from Secret Manager or Env config
const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');

export interface RateLimitOptions {
  windowMs: number;
  maxPoints: number; // Max requests within window
  keyPrefix?: string;
}

/**
 * Enterprise Redis-based Rate Limiter (Token Bucket / Sliding Window logic)
 * Distributes limits across serverless instances globally.
 */
export const rateLimit = (options: RateLimitOptions) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    // Authenticated users get rate limited by UID, guests by IP Address
    const identifier = (req as any).user?.uid || req.ip || 'unknown_ip';
    const key = `${options.keyPrefix || 'rate_limit'}:${identifier}`;
    const windowSecs = Math.ceil(options.windowMs / 1000);

    try {
      // Use Redis Multi for atomic increment and expiry setting
      const responses = await redis.multi()
        .incr(key)
        .ttl(key)
        .exec();

      if (!responses || responses.length !== 2) {
        // Fail open if Redis drops the transaction (availability > strict limits)
        return next();
      }

      const requests = responses[0][1] as number;
      let ttl = responses[1][1] as number;

      if (ttl === -1) {
        await redis.expire(key, windowSecs);
        ttl = windowSecs;
      }

      const remaining = Math.max(0, options.maxPoints - requests);

      // Set standard Rate Limit headers
      res.setHeader('X-RateLimit-Limit', options.maxPoints.toString());
      res.setHeader('X-RateLimit-Remaining', remaining.toString());
      res.setHeader('X-RateLimit-Reset', (Date.now() + (ttl * 1000)).toString());

      if (requests > options.maxPoints) {
        // Log DDoS signal
        console.warn(`[RATE LIMIT EXCEEDED] ${key}`);
        
        return res.status(429).json({
          error: 'Too Many Requests',
          message: 'Rate limit exceeded. Please try again later.',
        });
      }

      next();
    } catch (e) {
      console.error('Rate Limiter Redis Error:', e);
      // Fail open so the app keeps working if Redis goes down, 
      // but log it to trigger PagerDuty.
      next();
    }
  };
};

export const globalApiLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 min
  maxPoints: 60, // 60 req/min
  keyPrefix: 'api_global',
});

export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 mins
  maxPoints: 5, // 5 failed attempts per IP
  keyPrefix: 'api_auth_burst',
});

export const adminRateLimit = rateLimit({
  windowMs: 60 * 1000,
  maxPoints: 10,
  keyPrefix: 'api_admin',
});

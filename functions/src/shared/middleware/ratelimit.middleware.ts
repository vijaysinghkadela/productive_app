import { Request, Response, NextFunction } from 'express';
import { checkRateLimit } from '../config/redis.config';
import { RateLimitError } from '../errors/app.errors';
import { AuthenticatedRequest } from './auth.middleware';

interface RateLimitConfig {
  limit: number;
  windowSeconds: number;
  keyPrefix?: string;
}

/**
 * Rate limiting middleware using Redis sliding window
 */
export function rateLimitMiddleware(config: RateLimitConfig) {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const authReq = req as AuthenticatedRequest;
      const identifier = `${config.keyPrefix || req.path}:${authReq.uid}`;

      const result = await checkRateLimit(identifier, config.limit, config.windowSeconds);

      res.setHeader('X-RateLimit-Limit', config.limit.toString());
      res.setHeader('X-RateLimit-Remaining', result.remaining.toString());

      if (!result.allowed) {
        res.setHeader('Retry-After', result.retryAfter.toString());
        throw new RateLimitError(result.retryAfter);
      }

      next();
    } catch (error) {
      if (error instanceof RateLimitError) {
        next(error);
      } else {
        // Fail open if Redis is down
        console.error('Rate limit check failed:', error);
        next();
      }
    }
  };
}

// Pre-configured rate limiters
export const syncUsageRateLimit = rateLimitMiddleware({
  limit: 60, windowSeconds: 3600, keyPrefix: 'sync_usage',
});

export const sessionAnalyticsRateLimit = rateLimitMiddleware({
  limit: 30, windowSeconds: 3600, keyPrefix: 'session_analytics',
});

export const trackHabitRateLimit = rateLimitMiddleware({
  limit: 200, windowSeconds: 3600, keyPrefix: 'track_habit',
});

export const setGoalRateLimit = rateLimitMiddleware({
  limit: 20, windowSeconds: 3600, keyPrefix: 'set_goal',
});

export const leaderboardRateLimit = rateLimitMiddleware({
  limit: 60, windowSeconds: 60, keyPrefix: 'leaderboard',
});

export const searchUsersRateLimit = rateLimitMiddleware({
  limit: 30, windowSeconds: 60, keyPrefix: 'search_users',
});

export const adminRateLimit = rateLimitMiddleware({
  limit: 100, windowSeconds: 60, keyPrefix: 'admin',
});

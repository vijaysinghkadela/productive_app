import Redis from 'ioredis';
import { getSecret, IS_EMULATOR } from './firebase.config';

let _redis: Redis | null = null;

export async function getRedis(): Promise<Redis> {
  if (_redis) return _redis;

  if (IS_EMULATOR) {
    // Use a mock Redis for emulator
    _redis = new Redis({ host: 'localhost', port: 6379, maxRetriesPerRequest: 1 });
  } else {
    const url = await getSecret('redis-url');
    _redis = new Redis(url, {
      maxRetriesPerRequest: 3,
      retryStrategy: (times) => Math.min(times * 200, 5000),
      enableReadyCheck: true,
      connectTimeout: 10000,
    });
  }

  _redis.on('error', (err) => console.error('Redis connection error:', err));
  _redis.on('connect', () => console.log('Redis connected'));

  return _redis;
}

// Cache utilities using Redis
export async function cacheGet<T>(key: string): Promise<T | null> {
  try {
    const redis = await getRedis();
    const data = await redis.get(key);
    return data ? JSON.parse(data) : null;
  } catch {
    return null;
  }
}

export async function cacheSet(key: string, value: unknown, ttlSeconds: number): Promise<void> {
  try {
    const redis = await getRedis();
    await redis.setex(key, ttlSeconds, JSON.stringify(value));
  } catch (err) {
    console.error('Cache set error:', err);
  }
}

export async function cacheDelete(key: string): Promise<void> {
  try {
    const redis = await getRedis();
    await redis.del(key);
  } catch (err) {
    console.error('Cache delete error:', err);
  }
}

export async function cacheIncrement(key: string, ttlSeconds: number): Promise<number> {
  try {
    const redis = await getRedis();
    const count = await redis.incr(key);
    if (count === 1) await redis.expire(key, ttlSeconds);
    return count;
  } catch {
    return 0;
  }
}

// Rate limiting with sliding window
export async function checkRateLimit(
  identifier: string,
  limit: number,
  windowSeconds: number,
): Promise<{ allowed: boolean; remaining: number; retryAfter: number }> {
  try {
    const redis = await getRedis();
    const key = `rate_limit:${identifier}`;
    const now = Date.now();
    const windowStart = now - windowSeconds * 1000;

    const pipe = redis.pipeline();
    pipe.zremrangebyscore(key, 0, windowStart);
    pipe.zadd(key, now.toString(), `${now}:${Math.random()}`);
    pipe.zcard(key);
    pipe.expire(key, windowSeconds);
    const results = await pipe.exec();

    const count = (results?.[2]?.[1] as number) || 0;
    const allowed = count <= limit;
    const remaining = Math.max(0, limit - count);

    if (!allowed) {
      // Remove the just-added entry
      await redis.zremrangebyscore(key, now, now);
    }

    return {
      allowed,
      remaining,
      retryAfter: allowed ? 0 : windowSeconds,
    };
  } catch {
    // Fail open if Redis is down
    return { allowed: true, remaining: limit, retryAfter: 0 };
  }
}

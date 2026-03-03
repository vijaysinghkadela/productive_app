import Redis from 'ioredis';
export declare function getRedis(): Promise<Redis>;
export declare function cacheGet<T>(key: string): Promise<T | null>;
export declare function cacheSet(key: string, value: unknown, ttlSeconds: number): Promise<void>;
export declare function cacheDelete(key: string): Promise<void>;
export declare function cacheIncrement(key: string, ttlSeconds: number): Promise<number>;
export declare function checkRateLimit(identifier: string, limit: number, windowSeconds: number): Promise<{
    allowed: boolean;
    remaining: number;
    retryAfter: number;
}>;
//# sourceMappingURL=redis.config.d.ts.map
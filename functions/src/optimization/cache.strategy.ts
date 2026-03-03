import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');

export class CacheStrategy {
  // L1: In-memory (per function instance): hot data, <1ms access
  private memCache: Map<string, { data: any; expiry: number }> = new Map();

  // Cache-aside pattern: Traversing L1 -> L2 -> L3
  async get<T>(key: string, fetcher: () => Promise<T>, ttl: number): Promise<T> {
    const now = Date.now();
    
    // L1 check:
    const l1 = this.memCache.get(key);
    if (l1 && l1.expiry > now) return l1.data as T;
    
    // L2 check:
    try {
      const l2Raw = await redis.get(key);
      if (l2Raw) {
        const l2 = JSON.parse(l2Raw) as T;
        this.memCache.set(key, { data: l2, expiry: now + (Math.min(ttl, 60) * 1000) }); // Short L1 TTL
        return l2;
      }
    } catch (e) {
      console.error('L2 Redis Failure, falling back to L3', e);
    }
    
    // L3 fetch:
    const value = await fetcher();
    try {
      await redis.setex(key, ttl, JSON.stringify(value)); // Populate L2
    } catch {}

    this.memCache.set(key, { data: value, expiry: now + (Math.min(ttl, 60) * 1000) }); // Populate L1
    return value;
  }
  
  // Cache invalidation strategy:
  async invalidate(pattern: string): Promise<void> {
    // L1: clear matching keys from memory cache
    for (const key of this.memCache.keys()) {
      if (key.startsWith(pattern)) {
        this.memCache.delete(key);
      }
    }
    
    // L2: Redis SCAN + DEL (don't use KEYS in production — blocks):
    let cursor = '0';
    do {
      const [newCursor, keys] = await redis.scan(cursor, 'MATCH', `${pattern}*`, 'COUNT', 100);
      cursor = newCursor;
      if (keys.length > 0) {
        await redis.del(...keys);
      }
    } while (cursor !== '0');
  }
  
  // TTL strategy per data type:
  static readonly TTLs = {
    userProfile: 300,          // 5 minutes
    subscriptionStatus: 3600,  // 1 hour (critical, keep accurate)
    leaderboardTop100: 900,    // 15 minutes
    appConfig: 3600,           // 1 hour
    achievementDefinitions: 86400, // 24 hours (changes rarely)
    dailyStats: 120,           // 2 minutes (updates frequently)
    aiRateLimit: 2592000,      // 30 days (monthly counter)
    sessionData: 600,          // 10 minutes
    reportData: 86400,         // 24 hours
    socialMediaApps: 3600,     // 1 hour
  };
  
  // Cache warming on cold start:
  static async warmCache(): Promise<void> {
    // Pre-populate caches with most requested data before serving traffic:
    await Promise.all([
      // cacheAppConfig(),          // app_config documents
      // cacheAchievementDefs(),    // Achievement definitions
      // cacheGlobalLeaderboard(),  // Top 100 leaderboard
      // cacheSocialMediaApps(),    // Social app package names
    ]);
  }
}

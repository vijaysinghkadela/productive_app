"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getRedis = getRedis;
exports.cacheGet = cacheGet;
exports.cacheSet = cacheSet;
exports.cacheDelete = cacheDelete;
exports.cacheIncrement = cacheIncrement;
exports.checkRateLimit = checkRateLimit;
const ioredis_1 = __importDefault(require("ioredis"));
const firebase_config_1 = require("./firebase.config");
let _redis = null;
async function getRedis() {
    if (_redis)
        return _redis;
    if (firebase_config_1.IS_EMULATOR) {
        // Use a mock Redis for emulator
        _redis = new ioredis_1.default({ host: 'localhost', port: 6379, maxRetriesPerRequest: 1 });
    }
    else {
        const url = await (0, firebase_config_1.getSecret)('redis-url');
        _redis = new ioredis_1.default(url, {
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
async function cacheGet(key) {
    try {
        const redis = await getRedis();
        const data = await redis.get(key);
        return data ? JSON.parse(data) : null;
    }
    catch {
        return null;
    }
}
async function cacheSet(key, value, ttlSeconds) {
    try {
        const redis = await getRedis();
        await redis.setex(key, ttlSeconds, JSON.stringify(value));
    }
    catch (err) {
        console.error('Cache set error:', err);
    }
}
async function cacheDelete(key) {
    try {
        const redis = await getRedis();
        await redis.del(key);
    }
    catch (err) {
        console.error('Cache delete error:', err);
    }
}
async function cacheIncrement(key, ttlSeconds) {
    try {
        const redis = await getRedis();
        const count = await redis.incr(key);
        if (count === 1)
            await redis.expire(key, ttlSeconds);
        return count;
    }
    catch {
        return 0;
    }
}
// Rate limiting with sliding window
async function checkRateLimit(identifier, limit, windowSeconds) {
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
        const count = results?.[2]?.[1] || 0;
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
    }
    catch {
        // Fail open if Redis is down
        return { allowed: true, remaining: limit, retryAfter: 0 };
    }
}
//# sourceMappingURL=redis.config.js.map
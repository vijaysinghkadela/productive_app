"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DDosProtectionService = void 0;
const ioredis_1 = __importDefault(require("ioredis"));
const redis = new ioredis_1.default(process.env.REDIS_URL || 'redis://localhost:6379');
/**
 * Layer 7 Request pattern analysis and automated WAF blocking.
 * Integrates with Redis to maintain a dynamic IP blacklist.
 */
class DDosProtectionService {
    static BLOCKLIST_PREFIX = 'waf_blocklist';
    static SUSPICIOUS_PREFIX = 'waf_suspicious';
    /**
     * Middleware to check if an IP is currently blacklisted.
     */
    static async checkBlocklist(req, res, next) {
        const ip = req.ip || 'unknown_ip';
        const isBlocked = await redis.get(`${DDosProtectionService.BLOCKLIST_PREFIX}:${ip}`);
        if (isBlocked) {
            console.warn(`[WAF BLOCKED] Request from blacklisted IP: ${ip}`);
            // Drop connection silently or return 403
            return res.status(403).json({ error: 'Forbidden', message: 'Access denied by WAF.' });
        }
        next();
    }
    /**
     * Logs a suspicious request. If threshold reached, blocks the IP.
     */
    static async logSuspiciousActivity(ip, reason) {
        const key = `${DDosProtectionService.SUSPICIOUS_PREFIX}:${ip}`;
        // Increment suspicious score
        const score = await redis.incr(key);
        // Keep track for 15 minutes
        if (score === 1) {
            await redis.expire(key, 15 * 60);
        }
        console.warn(`[WAF SUSPICIOUS] IP: ${ip}, Reason: ${reason}, Score: ${score}`);
        // Threshold reached, block IP for 24 hours
        if (score >= 5) {
            await this.blockIp(ip, 24 * 60 * 60, `Exceeded suspicious activity threshold. Last reason: ${reason}`);
        }
    }
    static async blockIp(ip, durationSecs, reason) {
        const key = `${DDosProtectionService.BLOCKLIST_PREFIX}:${ip}`;
        await redis.setex(key, durationSecs, reason);
        console.error(`🚨 [WAF AUTOMATED BLOCK] IP: ${ip} blocked for ${durationSecs}s. Reason: ${reason}`);
        // Clear suspicious score
        await redis.del(`${DDosProtectionService.SUSPICIOUS_PREFIX}:${ip}`);
    }
}
exports.DDosProtectionService = DDosProtectionService;
//# sourceMappingURL=ddos.protection.js.map
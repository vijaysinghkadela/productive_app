import { Request, Response, NextFunction } from 'express';
/**
 * Layer 7 Request pattern analysis and automated WAF blocking.
 * Integrates with Redis to maintain a dynamic IP blacklist.
 */
export declare class DDosProtectionService {
    private static readonly BLOCKLIST_PREFIX;
    private static readonly SUSPICIOUS_PREFIX;
    /**
     * Middleware to check if an IP is currently blacklisted.
     */
    static checkBlocklist(req: Request, res: Response, next: NextFunction): Promise<Response<any, Record<string, any>> | undefined>;
    /**
     * Logs a suspicious request. If threshold reached, blocks the IP.
     */
    static logSuspiciousActivity(ip: string, reason: string): Promise<void>;
    static blockIp(ip: string, durationSecs: number, reason: string): Promise<void>;
}
//# sourceMappingURL=ddos.protection.d.ts.map
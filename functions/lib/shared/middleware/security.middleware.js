"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.configureSecurityMiddleware = void 0;
const express_1 = __importDefault(require("express"));
const helmet_1 = __importDefault(require("helmet"));
const cors_1 = __importDefault(require("cors"));
const hpp_1 = __importDefault(require("hpp"));
// @ts-ignore
const express_xss_sanitizer_1 = require("express-xss-sanitizer");
const crypto_1 = __importDefault(require("crypto"));
/**
 * Enterprise-grade security middleware for Express
 * Combines Helmet (CSP, HSTS), CORS, HPP, and XSS sanitization.
 */
const configureSecurityMiddleware = (app) => {
    // 1. Helmet Security Headers
    app.use((0, helmet_1.default)({
        contentSecurityPolicy: {
            directives: {
                defaultSrc: ["'none'"],
                scriptSrc: ["'self'"],
                styleSrc: ["'self'"],
                imgSrc: ["'self'", "data:", "https://storage.googleapis.com"],
                connectSrc: ["'self'", "https://firebaseapp.com", "https://googleapis.com"],
                frameSrc: ["'none'"],
                objectSrc: ["'none'"],
                baseUri: ["'none'"],
                formAction: ["'none'"],
                upgradeInsecureRequests: [],
            },
        },
        crossOriginEmbedderPolicy: true,
        crossOriginOpenerPolicy: { policy: 'same-origin' },
        crossOriginResourcePolicy: { policy: 'same-origin' },
        dnsPrefetchControl: { allow: false },
        frameguard: { action: 'deny' },
        hidePoweredBy: true,
        hsts: { maxAge: 63072000, includeSubDomains: true, preload: true }, // 2 Years HSTS
        ieNoOpen: true,
        noSniff: true,
        originAgentCluster: true,
        permittedCrossDomainPolicies: { permittedPolicies: 'none' },
        referrerPolicy: { policy: 'no-referrer' },
        xssFilter: true,
    }));
    // 2. Strict CORS Configuration
    const corsOptions = {
        origin: (origin, callback) => {
            const allowedOrigins = [
                'https://focusguardpro.app',
                'https://api.focusguardpro.app'
            ];
            // Allow requests with no origin (like mobile apps) or white-listed domains
            if (!origin || allowedOrigins.includes(origin)) {
                callback(null, true);
            }
            else {
                callback(new Error('CORS policy violation'));
            }
        },
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
        allowedHeaders: ['Authorization', 'Content-Type', 'X-Firebase-AppCheck', 'X-Request-ID', 'X-App-Version', 'X-Request-Signature', 'X-Request-Nonce', 'X-Request-Timestamp'],
        exposedHeaders: ['X-RateLimit-Remaining', 'X-RateLimit-Reset', 'X-Token-Refresh-Required', 'X-Response-Signature'],
        credentials: true,
        maxAge: 86400, // 24 hours preflight cache
    };
    app.use((0, cors_1.default)(corsOptions));
    // 3. Prevent HTTP Parameter Pollution
    app.use((0, hpp_1.default)());
    // 4. XSS Sanitization on request bodies
    app.use((0, express_xss_sanitizer_1.xss)());
    // 5. Strict JSON parsing with strict byte limit
    app.use(express_1.default.json({ limit: '1mb', strict: true }));
    // 6. Request Tracing
    app.use((req, res, next) => {
        req.requestId = req.headers['x-request-id'] || crypto_1.default.randomUUID();
        res.setHeader('X-Request-ID', req.requestId);
        next();
    });
    // 7. Strip sensitive server signatures
    app.use((req, res, next) => {
        res.removeHeader('Server');
        res.removeHeader('X-Powered-By');
        next();
    });
};
exports.configureSecurityMiddleware = configureSecurityMiddleware;
//# sourceMappingURL=security.middleware.js.map
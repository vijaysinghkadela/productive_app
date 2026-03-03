"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateBody = validateBody;
exports.requestLogger = requestLogger;
exports.corsConfig = corsConfig;
const zod_1 = require("zod");
const uuid_1 = require("uuid");
const app_errors_1 = require("../errors/app.errors");
/**
 * Validate request body against a Zod schema
 */
function validateBody(schema) {
    return (req, _res, next) => {
        try {
            req.body = schema.parse(req.body);
            next();
        }
        catch (error) {
            if (error instanceof zod_1.ZodError) {
                const details = error.errors.map((e) => ({
                    path: e.path.join('.'),
                    message: e.message,
                }));
                next(new app_errors_1.ValidationError('Validation failed', { errors: details }));
            }
            else {
                next(error);
            }
        }
    };
}
/**
 * Request logging middleware
 */
function requestLogger(req, res, next) {
    const requestId = (0, uuid_1.v4)();
    const start = Date.now();
    // Attach request ID
    req.headers['x-request-id'] = requestId;
    res.setHeader('X-Request-Id', requestId);
    res.on('finish', () => {
        const duration = Date.now() - start;
        console.log(JSON.stringify({
            requestId,
            method: req.method,
            path: req.path,
            statusCode: res.statusCode,
            durationMs: duration,
            userAgent: req.headers['user-agent'],
            ip: req.ip,
        }));
    });
    next();
}
/**
 * CORS configuration
 */
function corsConfig() {
    const allowedOrigins = ['https://focusguardpro.app', 'https://admin.focusguardpro.app'];
    if (process.env.FUNCTIONS_EMULATOR === 'true') {
        allowedOrigins.push('http://localhost:3000', 'http://localhost:5000');
    }
    return {
        origin: allowedOrigins,
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization', 'X-App-Check-Token'],
        credentials: true,
        maxAge: 86400,
    };
}
//# sourceMappingURL=validation.middleware.js.map
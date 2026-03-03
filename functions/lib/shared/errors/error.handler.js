"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.globalErrorHandler = globalErrorHandler;
const Sentry = __importStar(require("@sentry/node"));
const app_errors_1 = require("./app.errors");
function globalErrorHandler(err, _req, res, _next) {
    // Log all errors
    console.error('Error:', {
        name: err.name,
        message: err.message,
        stack: err.stack,
        ...(err instanceof app_errors_1.AppError && {
            code: err.code,
            statusCode: err.statusCode,
            details: err.details,
            isOperational: err.isOperational,
        }),
    });
    // Report non-operational errors to Sentry
    if (!(err instanceof app_errors_1.AppError) || !err.isOperational) {
        Sentry.captureException(err);
    }
    // Handle known Firebase errors
    if ('code' in err && typeof err.code === 'string') {
        const fbCode = err.code;
        if (fbCode === 'permission-denied' || fbCode === 'PERMISSION_DENIED') {
            const response = {
                success: false,
                error: { code: 'AUTH_001', message: 'Permission denied' },
            };
            res.status(403).json(response);
            return;
        }
        if (fbCode === 'not-found' || fbCode === 'NOT_FOUND') {
            const response = {
                success: false,
                error: { code: 'NOT_FOUND', message: 'Resource not found' },
            };
            res.status(404).json(response);
            return;
        }
    }
    if (err instanceof app_errors_1.AppError) {
        const response = {
            success: false,
            error: {
                code: err.code,
                message: err.message,
                details: err.isOperational ? err.details : undefined,
            },
        };
        res.status(err.statusCode).json(response);
        return;
    }
    // Unknown errors — never expose internals
    const internalErr = new app_errors_1.InternalError();
    const response = {
        success: false,
        error: { code: internalErr.code, message: 'An unexpected error occurred' },
    };
    res.status(500).json(response);
}
//# sourceMappingURL=error.handler.js.map
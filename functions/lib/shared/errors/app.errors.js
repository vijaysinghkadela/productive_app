"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.InternalError = exports.NotFoundError = exports.RateLimitError = exports.ValidationError = exports.SubscriptionError = exports.ForbiddenError = exports.AuthError = exports.AppError = void 0;
const error_codes_1 = require("./error.codes");
class AppError extends Error {
    code;
    statusCode;
    details;
    isOperational;
    constructor(code, message, statusCode = 500, details, isOperational = true) {
        super(message);
        this.code = code;
        this.statusCode = statusCode;
        this.details = details;
        this.isOperational = isOperational;
        Object.setPrototypeOf(this, new.target.prototype);
    }
}
exports.AppError = AppError;
class AuthError extends AppError {
    constructor(code, message, details) {
        super(code, message, 401, details);
    }
}
exports.AuthError = AuthError;
class ForbiddenError extends AppError {
    constructor(message = 'Forbidden', details) {
        super(error_codes_1.ErrorCodes.AUTH_004, message, 403, details);
    }
}
exports.ForbiddenError = ForbiddenError;
class SubscriptionError extends AppError {
    constructor(requiredTier, currentTier) {
        super(error_codes_1.ErrorCodes.AUTH_004, `This feature requires ${requiredTier} subscription. Current tier: ${currentTier}`, 403, { requiredTier, currentTier });
    }
}
exports.SubscriptionError = SubscriptionError;
class ValidationError extends AppError {
    constructor(message, details) {
        super(error_codes_1.ErrorCodes.VALIDATION_001, message, 400, details);
    }
}
exports.ValidationError = ValidationError;
class RateLimitError extends AppError {
    retryAfter;
    constructor(retryAfter = 60) {
        super(error_codes_1.ErrorCodes.RATE_001, 'Too many requests', 429, { retryAfter });
        this.retryAfter = retryAfter;
    }
}
exports.RateLimitError = RateLimitError;
class NotFoundError extends AppError {
    constructor(resource, id) {
        const msg = id ? `${resource} with ID ${id} not found` : `${resource} not found`;
        super(error_codes_1.ErrorCodes.NOT_FOUND, msg, 404, { resource, id });
    }
}
exports.NotFoundError = NotFoundError;
class InternalError extends AppError {
    constructor(message = 'Internal server error', details) {
        super(error_codes_1.ErrorCodes.INTERNAL_001, message, 500, details, false);
    }
}
exports.InternalError = InternalError;
//# sourceMappingURL=app.errors.js.map
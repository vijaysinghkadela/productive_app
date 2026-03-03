import { ErrorCode } from './error.codes';
export declare class AppError extends Error {
    readonly code: ErrorCode;
    readonly statusCode: number;
    readonly details?: Record<string, unknown>;
    readonly isOperational: boolean;
    constructor(code: ErrorCode, message: string, statusCode?: number, details?: Record<string, unknown>, isOperational?: boolean);
}
export declare class AuthError extends AppError {
    constructor(code: ErrorCode, message: string, details?: Record<string, unknown>);
}
export declare class ForbiddenError extends AppError {
    constructor(message?: string, details?: Record<string, unknown>);
}
export declare class SubscriptionError extends AppError {
    constructor(requiredTier: string, currentTier: string);
}
export declare class ValidationError extends AppError {
    constructor(message: string, details?: Record<string, unknown>);
}
export declare class RateLimitError extends AppError {
    readonly retryAfter: number;
    constructor(retryAfter?: number);
}
export declare class NotFoundError extends AppError {
    constructor(resource: string, id?: string);
}
export declare class InternalError extends AppError {
    constructor(message?: string, details?: Record<string, unknown>);
}
//# sourceMappingURL=app.errors.d.ts.map
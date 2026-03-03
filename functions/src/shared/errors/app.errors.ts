import { ErrorCode, ErrorCodes } from './error.codes';

export class AppError extends Error {
  public readonly code: ErrorCode;
  public readonly statusCode: number;
  public readonly details?: Record<string, unknown>;
  public readonly isOperational: boolean;

  constructor(
    code: ErrorCode,
    message: string,
    statusCode: number = 500,
    details?: Record<string, unknown>,
    isOperational: boolean = true,
  ) {
    super(message);
    this.code = code;
    this.statusCode = statusCode;
    this.details = details;
    this.isOperational = isOperational;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

export class AuthError extends AppError {
  constructor(code: ErrorCode, message: string, details?: Record<string, unknown>) {
    super(code, message, 401, details);
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = 'Forbidden', details?: Record<string, unknown>) {
    super(ErrorCodes.AUTH_004, message, 403, details);
  }
}

export class SubscriptionError extends AppError {
  constructor(requiredTier: string, currentTier: string) {
    super(
      ErrorCodes.AUTH_004,
      `This feature requires ${requiredTier} subscription. Current tier: ${currentTier}`,
      403,
      { requiredTier, currentTier },
    );
  }
}

export class ValidationError extends AppError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(ErrorCodes.VALIDATION_001, message, 400, details);
  }
}

export class RateLimitError extends AppError {
  public readonly retryAfter: number;

  constructor(retryAfter: number = 60) {
    super(ErrorCodes.RATE_001, 'Too many requests', 429, { retryAfter });
    this.retryAfter = retryAfter;
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id?: string) {
    const msg = id ? `${resource} with ID ${id} not found` : `${resource} not found`;
    super(ErrorCodes.NOT_FOUND, msg, 404, { resource, id });
  }
}

export class InternalError extends AppError {
  constructor(message: string = 'Internal server error', details?: Record<string, unknown>) {
    super(ErrorCodes.INTERNAL_001, message, 500, details, false);
  }
}

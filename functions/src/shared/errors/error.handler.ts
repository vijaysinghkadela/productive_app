import { Request, Response, NextFunction } from 'express';
import * as Sentry from '@sentry/node';
import { AppError, InternalError } from './app.errors';
import { ApiResponse } from '../types/common.types';

export function globalErrorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  // Log all errors
  console.error('Error:', {
    name: err.name,
    message: err.message,
    stack: err.stack,
    ...(err instanceof AppError && {
      code: err.code,
      statusCode: err.statusCode,
      details: err.details,
      isOperational: err.isOperational,
    }),
  });

  // Report non-operational errors to Sentry
  if (!(err instanceof AppError) || !err.isOperational) {
    Sentry.captureException(err);
  }

  // Handle known Firebase errors
  if ('code' in err && typeof (err as { code: string }).code === 'string') {
    const fbCode = (err as { code: string }).code;
    if (fbCode === 'permission-denied' || fbCode === 'PERMISSION_DENIED') {
      const response: ApiResponse = {
        success: false,
        error: { code: 'AUTH_001', message: 'Permission denied' },
      };
      res.status(403).json(response);
      return;
    }
    if (fbCode === 'not-found' || fbCode === 'NOT_FOUND') {
      const response: ApiResponse = {
        success: false,
        error: { code: 'NOT_FOUND', message: 'Resource not found' },
      };
      res.status(404).json(response);
      return;
    }
  }

  if (err instanceof AppError) {
    const response: ApiResponse = {
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
  const internalErr = new InternalError();
  const response: ApiResponse = {
    success: false,
    error: { code: internalErr.code, message: 'An unexpected error occurred' },
  };
  res.status(500).json(response);
}

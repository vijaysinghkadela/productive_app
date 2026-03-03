import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { v4 as uuidv4 } from 'uuid';
import { ValidationError } from '../errors/app.errors';

/**
 * Validate request body against a Zod schema
 */
export function validateBody(schema: ZodSchema) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    try {
      req.body = schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const details = error.errors.map((e) => ({
          path: e.path.join('.'),
          message: e.message,
        }));
        next(new ValidationError('Validation failed', { errors: details }));
      } else {
        next(error);
      }
    }
  };
}

/**
 * Request logging middleware
 */
export function requestLogger(req: Request, res: Response, next: NextFunction): void {
  const requestId = uuidv4();
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
export function corsConfig() {
  const allowedOrigins = [
    'https://focusguardpro.app',
    'https://admin.focusguardpro.app',
  ];

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

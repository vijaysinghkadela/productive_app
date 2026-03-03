import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import hpp from 'hpp';
// @ts-ignore
import { xss } from 'express-xss-sanitizer';
import crypto from 'crypto';

/**
 * Enterprise-grade security middleware for Express
 * Combines Helmet (CSP, HSTS), CORS, HPP, and XSS sanitization.
 */
export const configureSecurityMiddleware = (app: express.Application) => {
  // 1. Helmet Security Headers
  app.use(helmet({
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
    origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
      const allowedOrigins = [
        'https://focusguardpro.app', 
        'https://api.focusguardpro.app'
      ];
      
      // Allow requests with no origin (like mobile apps) or white-listed domains
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error('CORS policy violation'));
      }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Authorization', 'Content-Type', 'X-Firebase-AppCheck', 'X-Request-ID', 'X-App-Version', 'X-Request-Signature', 'X-Request-Nonce', 'X-Request-Timestamp'],
    exposedHeaders: ['X-RateLimit-Remaining', 'X-RateLimit-Reset', 'X-Token-Refresh-Required', 'X-Response-Signature'],
    credentials: true,
    maxAge: 86400, // 24 hours preflight cache
  };
  app.use(cors(corsOptions));

  // 3. Prevent HTTP Parameter Pollution
  app.use(hpp());

  // 4. XSS Sanitization on request bodies
  app.use(xss());

  // 5. Strict JSON parsing with strict byte limit
  app.use(express.json({ limit: '1mb', strict: true }));

  // 6. Request Tracing
  app.use((req: any, res: express.Response, next: express.NextFunction) => {
    req.requestId = req.headers['x-request-id'] || crypto.randomUUID();
    res.setHeader('X-Request-ID', req.requestId);
    next();
  });

  // 7. Strip sensitive server signatures
  app.use((req: express.Request, res: express.Response, next: express.NextFunction) => {
    res.removeHeader('Server');
    res.removeHeader('X-Powered-By');
    next();
  });
};

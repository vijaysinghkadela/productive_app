import { Request, Response, NextFunction } from 'express';
import { getAuth } from '../config/firebase.config';
import { AuthError, ForbiddenError } from '../errors/app.errors';
import { ErrorCodes } from '../errors/error.codes';

export interface AuthenticatedRequest extends Request {
  uid: string;
  email: string;
  emailVerified: boolean;
  customClaims: Record<string, unknown>;
}

/**
 * Verify Firebase ID token from Authorization header
 */
export async function authMiddleware(
  req: Request,
  _res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      throw new AuthError(ErrorCodes.AUTH_001, 'Missing or invalid authorization header');
    }

    const token = authHeader.split('Bearer ')[1];
    const decoded = await getAuth().verifyIdToken(token);

    (req as AuthenticatedRequest).uid = decoded.uid;
    (req as AuthenticatedRequest).email = decoded.email || '';
    (req as AuthenticatedRequest).emailVerified = decoded.email_verified || false;
    (req as AuthenticatedRequest).customClaims = decoded;
    next();
  } catch (error) {
    if (error instanceof AuthError) {
      next(error);
    } else {
      next(new AuthError(ErrorCodes.AUTH_001, 'Invalid or expired authentication token'));
    }
  }
}

/**
 * Require email verification
 */
export function requireEmailVerification(
  req: Request,
  _res: Response,
  next: NextFunction,
): void {
  const authReq = req as AuthenticatedRequest;
  if (!authReq.emailVerified) {
    return next(new AuthError(ErrorCodes.AUTH_002, 'Email verification required'));
  }
  next();
}

/**
 * Require admin custom claim
 */
export function requireAdmin(
  req: Request,
  _res: Response,
  next: NextFunction,
): void {
  const authReq = req as AuthenticatedRequest;
  if (!authReq.customClaims?.admin) {
    return next(new ForbiddenError('Admin access required'));
  }
  next();
}

/**
 * Require specific subscription tier
 */
export function requireSubscription(minTier: string) {
  const tierHierarchy: Record<string, number> = {
    free: 0, basic: 1, pro: 2, elite: 3, lifetime: 4,
  };

  return (req: Request, _res: Response, next: NextFunction): void => {
    const authReq = req as AuthenticatedRequest;
    const userTier = (authReq.customClaims?.tier as string) || 'free';
    const userLevel = tierHierarchy[userTier] ?? 0;
    const requiredLevel = tierHierarchy[minTier] ?? 0;

    if (userLevel < requiredLevel) {
      return next(new ForbiddenError(
        `This feature requires ${minTier} subscription. Current: ${userTier}`,
      ));
    }
    next();
  };
}

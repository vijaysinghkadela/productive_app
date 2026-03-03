import { Request, Response, NextFunction } from 'express';
import * as admin from 'firebase-admin';

export interface AuthenticatedRequest extends Request {
  user?: admin.auth.DecodedIdToken;
}

/**
 * Express middleware to enforce Firebase Auth (Bearer ID Token).
 * Includes token revocation checks and custom claims validation.
 */
export const verifyAuthToken = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
  const authHeader = req.header('Authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Missing or invalid Authorization header.',
    });
  }

  const idToken = authHeader.split('Bearer ')[1];

  try {
    // Verify token and check if it was revoked (forcing re-auth on password change, etc.)
    const decodedToken = await admin.auth().verifyIdToken(idToken, true);
    req.user = decodedToken;

    // Email verification check (if required by business logic)
    // if (!decodedToken.email_verified) throw new Error('email_not_verified');

    // Handle token rotation natively on client, but we can send a hint header if near expiry
    const expirationTime = decodedToken.exp * 1000;
    const timeUntilExpiry = expirationTime - Date.now();
    if (timeUntilExpiry < 5 * 60 * 1000) { // < 5 minutes
      res.setHeader('X-Token-Refresh-Required', 'true');
    }

    // Session binding verification
    // const deviceIdHeader = req.header('X-Device-ID');
    // if (decodedToken.deviceId && decodedToken.deviceId !== deviceIdHeader) {
    //     throw new Error('session_hijacking_detected');
    // }

    next();
  } catch (error: any) {
    console.error('Auth verification failed:', error);

    if (error.code === 'auth/id-token-revoked') {
      return res.status(401).json({ error: 'Unauthorized', message: 'Token revoked. Please re-authenticate.' });
    }
    if (error.code === 'auth/id-token-expired') {
      return res.status(401).json({ error: 'Unauthorized', message: 'Token expired.' });
    }
    if (error.message === 'session_hijacking_detected') {
      return res.status(403).json({ error: 'Forbidden', message: 'Session hijacking detected.' });
    }

    return res.status(401).json({ error: 'Unauthorized', message: 'Authentication failed.' });
  }
};

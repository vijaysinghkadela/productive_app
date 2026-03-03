import { Request, Response, NextFunction } from 'express';
import * as admin from 'firebase-admin';

/**
 * Express middleware to enforce Firebase App Check on all incoming requests.
 * Extracts the X-Firebase-AppCheck header and verifies it via the Admin SDK.
 */
export const enforceAppCheck = async (req: Request, res: Response, next: NextFunction) => {
  const appCheckToken = req.header('X-Firebase-AppCheck');

  if (!appCheckToken) {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'App Check token is missing.',
    });
  }

  try {
    // In production, you might set { consume: true } for replay protection on sensitive endpoints
    // This requires the App Check token to be one-time use
    const isSensitiveEndpoint = req.path.includes('/payment') || req.path.includes('/auth/mfa');
    
    const appCheckClaims = await admin.appCheck().verifyToken(appCheckToken, { consume: isSensitiveEndpoint });
    
    // Attach claims to the request if needed
    (req as any).appCheck = appCheckClaims;
    next();
  } catch (error) {
    console.error('App Check validation failed:', error);
    
    // Fallback: If AppCheck verification fails, it could be a bot, a compromised device, 
    // or an outdated client.
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'App Check validation failed.',
    });
  }
};

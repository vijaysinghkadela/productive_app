import * as admin from 'firebase-admin';
import { Request } from 'express';

/**
 * Validates and sanitizes data against Firestore Injection, NoSQL Injection, and SSRF.
 */

const ALLOWED_COLLECTIONS = [
  'users',
  'sessions',
  'daily_stats',
  'goals',
  'habits',
  'analytics',
  'feedback',
];

const ALLOWED_OPERATORS = ['==', '<', '<=', '>', '>=', 'in', 'array-contains'];

export class SecurityError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'SecurityError';
  }
}

export class InjectionPreventionService {

  /**
   * Safely retrieves a document, validating the requesting user against IDOR.
   */
  async getDocumentSafe(collection: string, docId: string, requestingUid: string): Promise<admin.firestore.DocumentData | undefined> {
    if (!ALLOWED_COLLECTIONS.includes(collection)) {
      throw new SecurityError('INVALID_COLLECTION');
    }

    if (!docId.match(/^[a-zA-Z0-9\-_]{20,28}$/)) {
      throw new SecurityError('INVALID_DOCUMENT_ID');
    }

    const docRef = admin.firestore().collection(collection).doc(docId);
    const docSnap = await docRef.get();

    if (!docSnap.exists) return undefined;

    const data = docSnap.data();

    // IDOR Check - Assuming top-level collections have a `userId` property bridging ownership
    // For nested (users/{uid}/collection), the collection path itself must be evaluated before getting here.
    if (data && data.userId && data.userId !== requestingUid) {
      throw new SecurityError('IDOR_ATTEMPT');
    }

    return data;
  }

  /**
   * Validates SSRF attempts (e.g. webhooks, AI requests targeting internal IPs)
   */
  validateUrl(url: string): boolean {
    try {
      const parsedUrl = new URL(url);

      // Block local and private IPs (DNS rebinding checks would ideally happen at the network level as well)
      const forbiddenDomains = ['localhost', '127.0.0.1', '169.254.169.254', '::1'];
      if (forbiddenDomains.includes(parsedUrl.hostname)) {
        return false;
      }
      
      // Scheme validation
      if (parsedUrl.protocol !== 'https:') {
        return false;
      }

      return true;
    } catch {
      return false;
    }
  }

  /**
   * Prototype Pollution / Deep Freeze Protection
   * Ensures incoming JSON payloads cannot inject __proto__ headers before merging
   */
  sanitizePayload(payload: any): any {
    if (typeof payload === 'object' && payload !== null) {
      if ('__proto__' in payload || 'constructor' in payload || 'prototype' in payload) {
        throw new SecurityError('PROTOTYPE_POLLUTION_ATTEMPT');
      }
    }
    return payload;
  }

  /**
   * Query Building without NoSQL injection
   */
  buildSafeQuery(collection: string, filters: Array<{ field: string; operator: string; value: any }>): admin.firestore.Query {
    if (!ALLOWED_COLLECTIONS.includes(collection)) {
      throw new SecurityError('INVALID_COLLECTION');
    }

    let query: admin.firestore.Query = admin.firestore().collection(collection);

    for (const filter of filters) {
      if (!ALLOWED_OPERATORS.includes(filter.operator)) {
        throw new SecurityError('INVALID_OPERATOR');
      }
      // Apply safe filters
      query = query.where(filter.field, filter.operator as admin.firestore.WhereFilterOp, filter.value);
    }

    // Default limit applied to mitigate large read queries impacting billing (DDoS)
    return query.limit(100);
  }
}

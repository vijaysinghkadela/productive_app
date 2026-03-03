import { z } from 'zod';
import DOMPurify from 'isomorphic-dompurify';
import { fileTypeFromBuffer } from 'file-type';

export class ValidationError extends Error {
  constructor(message: string, public code: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

const isDisposableEmail = (email: string) => {
  const disposableDomains = ['mailinator.com', '10minutemail.com', 'tempmail.com']; // Extend in prod
  const domain = email.split('@')[1];
  return disposableDomains.includes(domain);
};

const isBannedDomain = (email: string) => {
  const bannedDomains = ['banned.xyz'];
  const domain = email.split('@')[1];
  return bannedDomains.includes(domain);
};

/**
 * Standard string validation with buffer overflow prevention and control char stripping.
 */
export const secureStringSchema = z.string()
  .max(10000) // Prevent buffer overflow
  .regex(/^[^\x00-\x1F\x7F]*$/) // No control characters
  .transform(s => s.normalize('NFC').trim()); // Unicode normalization

export const emailSchema = z.string()
  .email()
  .max(254) // RFC 5321 length
  .toLowerCase()
  .refine(email => !isDisposableEmail(email), 'Disposable emails not allowed')
  .refine(email => !isBannedDomain(email), 'Domain not allowed');

export const userIdSchema = z.string()
  .regex(/^[a-zA-Z0-9_\-]{20,28}$/) // Firebase Auth UID format constraints
  .max(128);

/**
 * Html Sanitizer for markdown/journal entries using isomorphic DOMPurify
 */
export const sanitizeHtml = (dirty: string): string => {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'u', 's', 'em', 'strong', 'ul', 'ol', 'li', 'h2', 'h3', 'p', 'br'],
    ALLOWED_ATTR: [], // Strict: No attributes allowed to prevent JS event injection or CSS escape
    FORBID_CONTENTS: ['script', 'style', 'iframe', 'object', 'embed'],
    RETURN_DOM: false,
    RETURN_DOM_FRAGMENT: false,
  });
};

const MAX_FILE_SIZES: Record<string, number> = {
  'image/jpeg': 5 * 1024 * 1024, // 5MB
  'image/png': 5 * 1024 * 1024,
  'application/pdf': 10 * 1024 * 1024, // 10MB
};

/**
 * Validates magic bytes, mime type, and file sizes for buffer uploads.
 */
export const validateFileUpload = async (buffer: Buffer, expectedType: string): Promise<void> => {
  const detected = await fileTypeFromBuffer(buffer);
  
  if (!detected || detected.mime !== expectedType) {
    throw new ValidationError('File type does not match declared type', 'FILE_TYPE_MISMATCH');
  }

  // Size validation
  const maxSize = MAX_FILE_SIZES[expectedType] || 1 * 1024 * 1024; // default 1MB
  if (buffer.length > maxSize) {
    throw new ValidationError('File exceeds maximum allowed size', 'FILE_TOO_LARGE');
  }

  if (expectedType.startsWith('image/')) {
    // In production, scan for polyglot files, strip EXIF metadata (ImageMagick), 
    // and ideally run a virus scan via Cloud Security Scanner API / ClamAV.
  }
};

import { z } from 'zod';
export declare class ValidationError extends Error {
    code: string;
    constructor(message: string, code: string);
}
/**
 * Standard string validation with buffer overflow prevention and control char stripping.
 */
export declare const secureStringSchema: z.ZodEffects<z.ZodString, string, string>;
export declare const emailSchema: z.ZodEffects<z.ZodEffects<z.ZodString, string, string>, string, string>;
export declare const userIdSchema: z.ZodString;
/**
 * Html Sanitizer for markdown/journal entries using isomorphic DOMPurify
 */
export declare const sanitizeHtml: (dirty: string) => string;
/**
 * Validates magic bytes, mime type, and file sizes for buffer uploads.
 */
export declare const validateFileUpload: (buffer: Buffer, expectedType: string) => Promise<void>;
//# sourceMappingURL=security.validators.d.ts.map
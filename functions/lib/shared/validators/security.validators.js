"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateFileUpload = exports.sanitizeHtml = exports.userIdSchema = exports.emailSchema = exports.secureStringSchema = exports.ValidationError = void 0;
const zod_1 = require("zod");
const isomorphic_dompurify_1 = __importDefault(require("isomorphic-dompurify"));
const file_type_1 = require("file-type");
class ValidationError extends Error {
    code;
    constructor(message, code) {
        super(message);
        this.code = code;
        this.name = 'ValidationError';
    }
}
exports.ValidationError = ValidationError;
const isDisposableEmail = (email) => {
    const disposableDomains = ['mailinator.com', '10minutemail.com', 'tempmail.com']; // Extend in prod
    const domain = email.split('@')[1];
    return disposableDomains.includes(domain);
};
const isBannedDomain = (email) => {
    const bannedDomains = ['banned.xyz'];
    const domain = email.split('@')[1];
    return bannedDomains.includes(domain);
};
/**
 * Standard string validation with buffer overflow prevention and control char stripping.
 */
exports.secureStringSchema = zod_1.z.string()
    .max(10000) // Prevent buffer overflow
    .regex(/^[^\x00-\x1F\x7F]*$/) // No control characters
    .transform(s => s.normalize('NFC').trim()); // Unicode normalization
exports.emailSchema = zod_1.z.string()
    .email()
    .max(254) // RFC 5321 length
    .toLowerCase()
    .refine(email => !isDisposableEmail(email), 'Disposable emails not allowed')
    .refine(email => !isBannedDomain(email), 'Domain not allowed');
exports.userIdSchema = zod_1.z.string()
    .regex(/^[a-zA-Z0-9_\-]{20,28}$/) // Firebase Auth UID format constraints
    .max(128);
/**
 * Html Sanitizer for markdown/journal entries using isomorphic DOMPurify
 */
const sanitizeHtml = (dirty) => {
    return isomorphic_dompurify_1.default.sanitize(dirty, {
        ALLOWED_TAGS: ['b', 'i', 'u', 's', 'em', 'strong', 'ul', 'ol', 'li', 'h2', 'h3', 'p', 'br'],
        ALLOWED_ATTR: [], // Strict: No attributes allowed to prevent JS event injection or CSS escape
        FORBID_CONTENTS: ['script', 'style', 'iframe', 'object', 'embed'],
        RETURN_DOM: false,
        RETURN_DOM_FRAGMENT: false,
    });
};
exports.sanitizeHtml = sanitizeHtml;
const MAX_FILE_SIZES = {
    'image/jpeg': 5 * 1024 * 1024, // 5MB
    'image/png': 5 * 1024 * 1024,
    'application/pdf': 10 * 1024 * 1024, // 10MB
};
/**
 * Validates magic bytes, mime type, and file sizes for buffer uploads.
 */
const validateFileUpload = async (buffer, expectedType) => {
    const detected = await (0, file_type_1.fileTypeFromBuffer)(buffer);
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
exports.validateFileUpload = validateFileUpload;
//# sourceMappingURL=security.validators.js.map
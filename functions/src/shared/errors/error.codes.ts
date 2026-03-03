export const ErrorCodes = {
  // Auth errors
  AUTH_001: 'AUTH_001', // Not authenticated
  AUTH_002: 'AUTH_002', // Email not verified
  AUTH_003: 'AUTH_003', // Account suspended
  AUTH_004: 'AUTH_004', // Insufficient subscription tier
  AUTH_005: 'AUTH_005', // MFA required
  AUTH_006: 'AUTH_006', // Invalid MFA token
  AUTH_007: 'AUTH_007', // Account locked

  // Usage errors
  USAGE_001: 'USAGE_001', // Invalid date format
  USAGE_002: 'USAGE_002', // Future date not allowed
  USAGE_003: 'USAGE_003', // Usage values out of range

  // Session errors
  SESSION_001: 'SESSION_001', // Session not found
  SESSION_002: 'SESSION_002', // Session already ended
  SESSION_003: 'SESSION_003', // Invalid session duration

  // Goal errors
  GOAL_001: 'GOAL_001', // Goal limit exceeded for tier
  GOAL_002: 'GOAL_002', // Invalid goal type

  // Habit errors
  HABIT_001: 'HABIT_001', // Habit limit exceeded for tier
  HABIT_002: 'HABIT_002', // Invalid habit frequency

  // AI errors
  AI_001: 'AI_001', // Rate limit exceeded
  AI_002: 'AI_002', // Subscription required

  // Blocking errors
  BLOCK_001: 'BLOCK_001', // App in allowlist cannot be blocked
  BLOCK_002: 'BLOCK_002', // Block limit exceeded for tier

  // Rate limit
  RATE_001: 'RATE_001', // Too many requests

  // Validation
  VALIDATION_001: 'VALIDATION_001', // Invalid input

  // Internal
  INTERNAL_001: 'INTERNAL_001', // Internal server error
  NOT_FOUND: 'NOT_FOUND', // Resource not found
} as const;

export type ErrorCode = (typeof ErrorCodes)[keyof typeof ErrorCodes];

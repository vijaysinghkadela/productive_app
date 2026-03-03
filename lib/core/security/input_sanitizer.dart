/// Input sanitization utilities to prevent injection vulnerabilities
/// across all user-facing text fields.
class InputSanitizer {
  InputSanitizer._();

  /// Maximum allowed lengths for different field types.
  static const int maxNameLength = 100;
  static const int maxEmailLength = 254;
  static const int maxTextFieldLength = 500;
  static const int maxJournalLength = 5000;
  static const int maxPinLength = 6;

  /// Strips HTML tags, script injection patterns, and control characters.
  static String sanitize(String input) {
    // Remove HTML tags
    var cleaned = input.replaceAll(RegExp('<[^>]*>'), '');
    // Remove script-like patterns
    cleaned = cleaned.replaceAll(
      RegExp('javascript:', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'on\w+\s*=', caseSensitive: false),
      '',
    );
    // Remove control characters except newline/tab
    cleaned =
        cleaned.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
    // Trim whitespace
    return cleaned.trim();
  }

  /// Sanitize and enforce length limit.
  static String sanitizeWithLimit(String input, int maxLength) {
    final cleaned = sanitize(input);
    if (cleaned.length > maxLength) {
      return cleaned.substring(0, maxLength);
    }
    return cleaned;
  }

  /// Validate and sanitize a display name.
  static String sanitizeName(String input) =>
      sanitizeWithLimit(input, maxNameLength);

  /// Validate and sanitize email address.
  static String? sanitizeEmail(String input) {
    final cleaned = sanitize(input).toLowerCase();
    if (cleaned.length > maxEmailLength) return null;
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(cleaned)) return null;
    return cleaned;
  }

  /// Sanitize a text field (goals, habit names, etc.).
  static String sanitizeTextField(String input) =>
      sanitizeWithLimit(input, maxTextFieldLength);

  /// Sanitize journal/long-form content.
  static String sanitizeJournal(String input) =>
      sanitizeWithLimit(input, maxJournalLength);

  /// Validate a numeric PIN (digits only).
  static String? sanitizePin(String input) {
    final digitsOnly = input.replaceAll(RegExp('[^0-9]'), '');
    if (digitsOnly.isEmpty || digitsOnly.length > maxPinLength) return null;
    return digitsOnly;
  }

  /// Check if a string contains potential SQL injection patterns.
  static bool hasSqlInjection(String input) {
    final patterns = [
      RegExp(r"('\s*(OR|AND)\s*')", caseSensitive: false),
      RegExp(r'(;\s*(DROP|DELETE|UPDATE|INSERT))', caseSensitive: false),
      RegExp(r'(--\s)', caseSensitive: false),
      RegExp(r'(/\*.*\*/)', caseSensitive: false),
    ];
    return patterns.any((p) => p.hasMatch(input));
  }
}

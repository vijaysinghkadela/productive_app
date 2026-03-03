// ignore_for_file: avoid_positional_boolean_parameters, prefer_expression_function_bodies
import 'package:sanitize_html/sanitize_html.dart';

class ValidationResult {
  ValidationResult(this.isValid, [this.errorMessage]);
  final bool isValid;
  final String? errorMessage;
}

/// Provides strict input validation and sanitization
class InputValidator {
  /// String sanitization for generic text inputs
  static String sanitizeText(String input) {
    if (input.isEmpty) return input;

    var sanitized = input;

    // Remove null bytes
    sanitized = sanitized.replaceAll('\u0000', '');

    // Normalize Unicode (NFC normalization is default in Dart string rendering,
    // but explicit constraints can be added here if needed for exact byte counting)

    // Trim whitespace
    sanitized = sanitized.trim();

    // Strip control characters (except standard newlines/tabs)
    sanitized =
        sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // Disallow potential script tags broadly for plain text
    sanitized = sanitized.replaceAll(
      RegExp('<script.*?>.*?</script>', caseSensitive: false),
      '',
    );
    sanitized =
        sanitized.replaceAll(RegExp('javascript:', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'on\w+\s*='), ''); // e.g. onclick=

    // Max length limit enforcement is usually better handled at the TextField level
    return sanitized;
  }

  static ValidationResult validateEmail(String email) {
    if (email.length > 254) {
      return ValidationResult(false, 'Email exceeds maximum length');
    }

    // RFC 5322 compliant regex
    final regex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
    );
    if (!regex.hasMatch(email)) {
      return ValidationResult(false, 'Invalid email format');
    }

    return ValidationResult(true);
  }

  static ValidationResult validatePassword(String password) {
    if (password.length < 12) {
      return ValidationResult(false, 'Password must be at least 12 characters');
    }
    if (!RegExp('[A-Z]').hasMatch(password)) {
      return ValidationResult(
        false,
        'Password must contain an uppercase letter',
      );
    }
    if (!RegExp('[a-z]').hasMatch(password)) {
      return ValidationResult(
        false,
        'Password must contain a lowercase letter',
      );
    }
    if (!RegExp('[0-9]').hasMatch(password)) {
      return ValidationResult(false, 'Password must contain a number');
    }
    if (!RegExp(r'[!@#\$&*~`%\^\(\)\-\+=\[\]\{\}\|;:,.<>/?]')
        .hasMatch(password)) {
      return ValidationResult(
        false,
        'Password must contain a special character',
      );
    }
    return ValidationResult(true);
  }

  static ValidationResult validateUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    if (!regex.hasMatch(username)) {
      return ValidationResult(
        false,
        'Username must be 3-20 alphanumeric characters or underscores',
      );
    }
    return ValidationResult(true);
  }

  /// XSS prevention for rich text (e.g. journal entries)
  static String sanitizeForDisplay(String userContent) {
    // Use sanitize_html package
    return sanitizeHtml(
      userContent,
      allowElementId: (id) => false, // Strip IDs to prevent DOM clobbering
      allowClassName: (className) => false, // Strip classes
    );
  }

  /// Validates journal entry text before submission
  static ValidationResult validateJournalEntry(String html) {
    if (html.length > 50000) {
      // Arbitrary safe limit
      return ValidationResult(false, 'Journal entry too large');
    }

    // Reject if it contains object, embed, iframe, or script
    if (RegExp(
      '<(script|iframe|object|embed|style|link|meta)',
      caseSensitive: false,
    ).hasMatch(html)) {
      return ValidationResult(false, 'Contains forbidden HTML elements');
    }

    return ValidationResult(true);
  }
}

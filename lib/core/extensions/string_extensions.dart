/// String extensions for common transformations
extension StringExtension on String {
  /// Capitalize first letter
  String get capitalized =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  /// Title case: capitalize each word
  String get titleCase => split(' ').map((w) => w.capitalized).join(' ');

  /// Check if valid email
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(trim());

  /// Truncate with ellipsis
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';

  /// Extract initials (first letter of first 2 words)
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Convert to URL-safe slug
  String get slug => toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  /// Mask email for privacy display
  String get maskedEmail {
    if (!contains('@')) return this;
    final parts = split('@');
    final name = parts[0];
    if (name.length <= 2) return '$name@${parts[1]}';
    return '${name[0]}${'•' * (name.length - 2)}${name[name.length - 1]}@${parts[1]}';
  }
}

/// Nullable string extensions
extension NullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  String get orEmpty => this ?? '';
}

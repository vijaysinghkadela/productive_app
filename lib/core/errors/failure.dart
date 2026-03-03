/// Result type for domain layer operations.
/// Replaces try-catch with explicit success/failure returns.
library;

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success<T> s => s.value,
        Failure<T> _ => null,
      };

  String? get errorOrNull => switch (this) {
        Success<T> _ => null,
        Failure<T> f => f.message,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(String message, String? code) failure,
  }) =>
      switch (this) {
        Success<T> s => success(s.value),
        Failure<T> f => failure(f.message, f.code),
      };
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Failure<T> extends Result<T> {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
}

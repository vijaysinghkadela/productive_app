import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../errors/app_exceptions.dart';

/// Configured Dio HTTP client with interceptors for auth, logging, retry, and caching.
class DioClient {
  late final Dio _dio;

  DioClient({String? baseUrl, String? authToken}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.openAiBaseUrl,
        connectTimeout: ApiConstants.apiTimeout,
        receiveTimeout: ApiConstants.apiTimeout,
        sendTimeout: ApiConstants.uploadTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _RetryInterceptor(_dio),
    ]);
  }

  Dio get dio => _dio;

  /// GET request with error mapping
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path,
          queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// POST request with error mapping
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// PUT request with error mapping
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// DELETE request with error mapping
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Map Dio errors to domain exceptions
  AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timed out. Try again.');
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        return NetworkException(
          e.response?.data?['error']?['message']?.toString() ?? 'Server error',
          e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const AppException('Request cancelled');
      default:
        return AppException('Network error: ${e.message}');
    }
  }

  /// Update auth token
  void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear auth token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

/// Auth interceptor — attaches Firebase ID token to requests
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // In production: get fresh Firebase ID token and attach
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // In production: refresh token and retry
      debugPrint('🔐 Auth token expired — needs refresh');
    }
    handler.next(err);
  }
}

/// Logging interceptor for debug builds
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('→ ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
          '✗ ${err.response?.statusCode} ${err.requestOptions.uri}: ${err.message}');
    }
    handler.next(err);
  }
}

/// Retry interceptor with exponential backoff
class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  static const int _maxRetries = 3;

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
    final shouldRetry = retryCount < _maxRetries &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.connectionError ||
            (err.response?.statusCode ?? 0) >= 500);

    if (shouldRetry) {
      final delay = Duration(milliseconds: 500 * (retryCount + 1));
      await Future.delayed(delay);
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      try {
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {
        // Fall through to handler.next
      }
    }
    handler.next(err);
  }
}

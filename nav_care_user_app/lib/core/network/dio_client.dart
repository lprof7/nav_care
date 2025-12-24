import 'package:dio/dio.dart';
import 'package:nav_care_user_app/core/storage/token_store.dart';
import 'package:nav_care_user_app/core/storage/user_store.dart';

class DioClient {
  final String baseUrl;
  final Duration timeout;
  final TokenStore? tokenStore;
  final UserStore? userStore;
  final Future<void> Function()? onUnauthorized;
  bool _isClearingSession = false;

  DioClient({
    required this.baseUrl,
    required this.timeout,
    this.tokenStore,
    this.userStore,
    this.onUnauthorized,
  });

  Dio build() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {'Accept': 'application/json'},
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStore?.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final shouldClearSession =
            status == 401 || _isInvalidTokenResponse(error);
        if (shouldClearSession && !_isClearingSession) {
          _isClearingSession = true;
          try {
            await Future.wait([
              if (tokenStore != null) tokenStore!.clearToken(),
              if (userStore != null) userStore!.clearUser(),
            ]);
            if (onUnauthorized != null) {
              await onUnauthorized!();
            }
          } finally {
            _isClearingSession = false;
          }
        }
        handler.next(error);
      },
    ));
    return dio;
  }

  bool _isInvalidTokenResponse(DioException error) {
    final response = error.response;
    if (response?.statusCode != 400) return false;
    final data = response?.data;
    if (data is! Map) return false;
    final errorCode = data['error']?.toString().toLowerCase();
    if (errorCode == 'invalidtoken') return true;
    final message = data['message'];
    return _messageContainsInvalidToken(message);
  }

  bool _messageContainsInvalidToken(dynamic message) {
    if (message is String) {
      return message.toLowerCase().contains('invalid token');
    }
    if (message is Map) {
      for (final value in message.values) {
        if (value is String && value.toLowerCase().contains('invalid token')) {
          return true;
        }
      }
    }
    return false;
  }
}

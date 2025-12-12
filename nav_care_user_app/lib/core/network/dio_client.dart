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
        if (status == 401 && !_isClearingSession) {
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
}

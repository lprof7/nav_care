import 'package:dio/dio.dart';
import 'package:nav_care_app/core/storage/token_store.dart';

class DioClient {
  final String baseUrl;
  final Duration timeout;
  final TokenStore? tokenStore;

  DioClient({required this.baseUrl, required this.timeout, this.tokenStore});

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
        final token = tokenStore == null ? null : await tokenStore!.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
    return dio;
  }
}

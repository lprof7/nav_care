import 'package:dio/dio.dart';
import 'package:nav_care_offers_app/core/storage/doctor_store.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';

class DioClient {
  final String baseUrl;
  final Duration timeout;
  final TokenStore? tokenStore;
  final DoctorStore? doctorStore;
  final Future<void> Function()? onUnauthorized;
  bool _isClearingSession = false;

  DioClient({
    required this.baseUrl,
    required this.timeout,
    this.tokenStore,
    this.doctorStore,
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
        String? token;
        if (options.extra['useHospitalToken'] == true) {
          token =
              tokenStore == null ? null : await tokenStore!.getHospitalToken();
        } else {
          token = tokenStore == null ? null : await tokenStore!.getUserToken();
        }

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
              if (tokenStore != null) tokenStore!.clearUserToken(),
              if (tokenStore != null) tokenStore!.clearHospitalToken(),
              if (doctorStore != null) doctorStore!.clearDoctor(),
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

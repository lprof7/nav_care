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
        } else if (options.extra['useDoctorToken'] == true) {
          token = tokenStore == null ? null : await tokenStore!.getDoctorToken();
        } else {
          token = tokenStore == null ? null : await tokenStore!.getUserToken();
          if ((token == null || token.isEmpty) && tokenStore != null) {
            final isDoctor = await tokenStore!.getIsDoctor();
            if (isDoctor == true) {
              token = await tokenStore!.getDoctorToken();
            }
          }
        }

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
              if (tokenStore != null) tokenStore!.clearUserToken(),
              if (tokenStore != null) tokenStore!.clearDoctorToken(),
              if (tokenStore != null) tokenStore!.clearHospitalToken(),
              if (tokenStore != null) tokenStore!.clearIsDoctor(),
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
        if (value is String &&
            value.toLowerCase().contains('invalid token')) {
          return true;
        }
      }
    }
    return false;
  }
}

import 'package:dio/dio.dart';
import 'package:nav_care_offers_app/core/config/api_config.dart';
import 'package:nav_care_offers_app/core/config/api_config.dart';
import '../responses/result.dart';
import '../responses/failure.dart';

typedef FromJson<T> = T Function(dynamic json);

class ApiClient {
  final Dio _dio;
  final ApiConfig apiConfig;
  ApiClient(this._dio, this.apiConfig);

  Future<Result<T>> get<T>(String path,
      {Map<String, dynamic>? query,
      required FromJson<T> parser,
      Map<String, String>? headers,
      bool useHospitalToken = false}) async {
    try {
      final res = await _dio.get(path,
          queryParameters: query,
          options: Options(
              headers: headers, extra: {'useHospitalToken': useHospitalToken}));
      return Result.success(parser(res.data));
    } on DioException catch (e) {
      print(e);
      return Result.failure(_mapDio(e));
    }
  }

  Future<Result<T>> post<T>(String path,
      {Object? body,
      required FromJson<T> parser,
      Map<String, String>? headers,
      bool useHospitalToken = false}) async {
    try {
      final res = await _dio.post(path,
          data: body,
          options: Options(
            headers: headers,
            extra: {'useHospitalToken': useHospitalToken},
          ));
      return Result.success(parser(res.data));
    } on DioException catch (e) {
      print("error: ${e.message} ${e.response}}");
      return Result.failure(_mapDio(e));
    }
  }

  Future<Result<T>> put<T>(String path,
      {Object? body,
      required FromJson<T> parser,
      Map<String, String>? headers,
      bool useHospitalToken = false}) async {
    try {
      final res = await _dio.put(path,
          data: body,
          options: Options(
            headers: headers,
            extra: {'useHospitalToken': useHospitalToken},
          ));
      return Result.success(parser(res.data));
    } on DioException catch (e) {
      return Result.failure(_mapDio(e));
    }
  }

  Future<Result<T>> patch<T>(String path,
      {Object? body,
      required FromJson<T> parser,
      Map<String, String>? headers,
      bool useHospitalToken = false}) async {
    try {
      final res = await _dio.patch(path,
          data: body,
          options: Options(
            headers: headers,
            extra: {'useHospitalToken': useHospitalToken},
          ));
      return Result.success(parser(res.data));
    } on DioException catch (e) {
      return Result.failure(_mapDio(e));
    }
  }

  Future<Result<T>> delete<T>(String path,
      {Object? body,
      required FromJson<T> parser,
      Map<String, String>? headers,
      bool useHospitalToken = false}) async {
    try {
      final res = await _dio.delete(path,
          data: body,
          options: Options(
            headers: headers,
            extra: {'useHospitalToken': useHospitalToken},
          ));

      return Result.success(parser(res.data));
    } on DioException catch (e) {
      print("error: $e");
      return Result.failure(_mapDio(e));
    }
  }

  Failure _mapDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const Failure.timeout();
      case DioExceptionType.badResponse:
        final sc = e.response?.statusCode;
        final rawMessage =
            e.response?.data is Map ? (e.response?.data['message']) : null;
        final msg = _pickLocalizedMessage(rawMessage);
        if (sc == 401) return const Failure.unauthorized();
        if (sc == 422) {
          return Failure.validation(
              message: msg.isEmpty ? 'Validation error' : msg);
        }
        return Failure.server(
            message: msg.isEmpty ? 'Server error' : msg, statusCode: sc);
      case DioExceptionType.cancel:
        return const Failure.cancelled();
      case DioExceptionType.connectionError:
        return const Failure.network();
      case DioExceptionType.unknown:
      default:
        return const Failure.unknown();
    }
  }

  String _pickLocalizedMessage(dynamic raw) {
    if (raw is Map) {
      final map = raw.map((key, value) => MapEntry(key.toString(), value));
      final orderedKeys = ['ar', 'fr', 'en', 'sp', 'es'];
      for (final key in orderedKeys) {
        final val = map[key];
        if (val is String && val.trim().isNotEmpty) {
          return val.trim();
        }
      }
      final firstString = map.values.firstWhere(
        (v) => v is String && v.trim().isNotEmpty,
        orElse: () => null,
      );
      if (firstString is String) return firstString.trim();
      return map.toString();
    }
    if (raw is String) return raw;
    return '';
  }
}

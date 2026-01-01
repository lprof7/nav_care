import 'package:nav_care_offers_app/core/responses/paged.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/doctors/services/doctors_service.dart';

class DoctorsRepository {
  final DoctorsService _doctorsService;

  DoctorsRepository(this._doctorsService);

  Future<Result<DoctorListModel>> listDoctors({
    int page = 1,
    int limit = 10,
  }) {
    return _doctorsService.listDoctors(page: page, limit: limit);
  }

  Future<Result<DoctorListModel>> getHospitalDoctors(String hospitalId) async {
    return _doctorsService.getHospitalDoctors(hospitalId);
  }

  Future<Result<DoctorModel>> getDoctorById(String doctorId) {
    return _doctorsService.getDoctorById(doctorId);
  }

  Future<Paged<DoctorModel>> searchDoctorsCollection({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 50
            ? 50
            : limit;
    final result = await _doctorsService.searchDoctorsCollection(
      query: query,
      page: page,
      limit: requestLimit,
    );

    if (!result.isSuccess || result.data == null) {
      final message =
          _extractMessage(result.error?.message) ?? 'Failed to search doctors.';
      throw Exception(message);
    }

    final payload = result.data!;
    final data = _asMap(payload['data']) ?? _asMap(payload);
    final doctorMaps = _extractDoctorMaps(data);
    final pagination = _parsePagination(
      _asMap(data?['pagination']) ?? _asMap(payload['pagination']),
    );

    final doctors =
        doctorMaps.map(DoctorModel.fromJson).toList(growable: false);

    return Paged<DoctorModel>(
      items: doctors,
      meta: pagination,
    );
  }

  String? _extractMessage(dynamic message) {
    if (message is String && message.isNotEmpty) {
      return message;
    }
    if (message is Map<String, dynamic>) {
      final localized = [
        message['ar'],
        message['fr'],
        message['en'],
      ].whereType<String>().firstWhere(
            (value) => value.isNotEmpty,
            orElse: () => '',
          );
      if (localized.isNotEmpty) {
        return localized;
      }
    }
    return null;
  }

  PageMeta? _parsePagination(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;

    int? toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return PageMeta(
      page: toInt(json['page']) ?? 1,
      limit: toInt(json['limit']) ?? 10,
      total: toInt(json['total']) ?? 0,
      pages: toInt(json['pages']) ?? toInt(json['totalPages']) ?? 1,
      hasNextPage: json['hasNextPage'] == true ||
          (toInt(json['page']) ?? 1) < (toInt(json['pages']) ?? 1),
      hasPrevPage: json['hasPrevPage'] == true ||
          (toInt(json['page']) ?? 1) > 1,
      nextPage: toInt(json['nextPage']),
      prevPage: toInt(json['prevPage']),
    );
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  List<Map<String, dynamic>> _extractDoctorMaps(dynamic source) {
    if (source is List) {
      return source.whereType<Map<String, dynamic>>().toList(growable: false);
    }

    if (source is Map<String, dynamic>) {
      const candidateKeys = ['data', 'doctors', 'docs', 'items', 'results'];
      for (final key in candidateKeys) {
        if (!source.containsKey(key)) continue;
        final extracted = _extractDoctorMaps(source[key]);
        if (extracted.isNotEmpty) {
          return extracted;
        }
      }

      for (final value in source.values) {
        final extracted = _extractDoctorMaps(value);
        if (extracted.isNotEmpty) {
          return extracted;
        }
      }
    }

    return <Map<String, dynamic>>[];
  }
}

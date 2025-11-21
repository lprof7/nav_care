import 'package:nav_care_user_app/core/responses/pagination.dart';
import 'package:nav_care_user_app/data/clinics/clinics_remote_service.dart';
import 'package:nav_care_user_app/data/clinics/models/clinic_model.dart';

class ClinicsRepository {
  ClinicsRepository({required ClinicsRemoteService remoteService})
      : _remoteService = remoteService;

  final ClinicsRemoteService _remoteService;

  Future<Paged<ClinicModel>> getHospitalClinics(String hospitalId) async {
    final response = await _remoteService.getHospitalClinics(hospitalId);
    if (!response.isSuccess || response.data == null) {
      throw Exception('clinics.error.generic');
    }
    final data = response.data!;
    final list = _extractClinics(data);
    final pagination = _parsePagination(
      _asMap(data['pagination']) ??
          _asMap((data['data'] as Map?)?['pagination']),
    );

    return Paged(
      items: list,
      meta: pagination,
    );
  }

  List<ClinicModel> _extractClinics(Map<String, dynamic> source) {
    final root = _asMap(source['data']) ?? source;
    final raw = root['clinics'] ?? root['data'] ?? root['items'] ?? root;
    final list = _mapList(raw);
    return list.map(ClinicModel.fromJson).toList(growable: false);
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  List<Map<String, dynamic>> _mapList(dynamic source) {
    if (source is Iterable) {
      return source
          .whereType<Map>()
          .map((e) => e.map((key, value) => MapEntry(key.toString(), value)))
          .toList(growable: false);
    }
    return const [];
  }

  PageMeta? _parsePagination(Map<String, dynamic>? json) {
    if (json == null) return null;
    int? toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return PageMeta(
      page: toInt(json['page']) ?? 1,
      pageSize: toInt(json['limit']) ?? toInt(json['pageSize']) ?? 10,
      total: toInt(json['total']) ?? 0,
      totalPages: toInt(json['pages']) ?? toInt(json['totalPages']) ?? 1,
    );
  }
}

import 'package:nav_care_user_app/core/responses/pagination.dart';

import 'models/hospital_model.dart';
import 'responses/fake_featured_hospitals_response.dart';
import 'hospitals_remote_service.dart';

class HospitalsRepository {
  // ignore: unused_field
  final HospitalsRemoteService _remoteService;

  HospitalsRepository({required HospitalsRemoteService remoteService})
      : _remoteService = remoteService;

  Future<Paged<HospitalModel>> getNavcareHospitalsChoice({
    int page = 1,
    int limit = 6,
  }) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 20
            ? 20
            : limit;

    return _fetchBoostedHospitals(
      type: 'nav_care',
      page: page,
      limit: requestLimit,
    );
  }

  Future<List<HospitalModel>> getNavcareFeaturedHospitals(
      {int limit = 3}) async {
    final paged = await getFeaturedHospitals(limit: limit);
    return paged.items;
  }

  Future<List<HospitalModel>> getNavcareFeaturedClinics({int limit = 6}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 15
            ? 15
            : limit;

    final fetchLimit = ((requestLimit * 2).clamp(1, 40)).toInt();
    final pagedHospitals = await _fetchHospitals(limit: fetchLimit);
    if (pagedHospitals.items.isEmpty) {
      return pagedHospitals.items;
    }

    final clinics = pagedHospitals.items.where((hospital) {
      final facilityType = hospital.facilityType.trim().toLowerCase();
      final field = hospital.field.trim().toLowerCase();
      return facilityType.contains('clinic') || field.contains('clinic');
    }).toList(growable: false);

    if (clinics.isEmpty) {
      return clinics;
    }

    final sorted = [...clinics]..sort((a, b) => b.rating.compareTo(a.rating));
    final cappedLimit =
        requestLimit > sorted.length ? sorted.length : requestLimit;
    return sorted.sublist(0, cappedLimit);
  }

  Future<Paged<HospitalModel>> getFeaturedHospitals({
    int page = 1,
    int limit = 6,
  }) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 20
            ? 20
            : limit;
    final result = await _remoteService.listBoostedHospitals(
      type: 'featured',
      page: page,
      limit: requestLimit,
    );

    if (!result.isSuccess || result.data == null) {
      final message = _extractMessage(result.error?.message) ??
          'Failed to load featured hospitals.';
      throw Exception(message);
    }

    final payload = result.data!;
    final data = _asMap(payload['data']) ?? _asMap(payload);
    final hospitalMaps = _extractHospitalMaps(data);
    final pagination =
        _parsePagination(_asMap(payload['pagination']) ?? _asMap(data?['pagination']));

    final hospitals =
        hospitalMaps.map(HospitalModel.fromJson).toList(growable: false);

    return Paged<HospitalModel>(
      items: hospitals,
      meta: pagination,
    );
  }

  Future<Paged<HospitalModel>> _fetchBoostedHospitals({
    required String type,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _remoteService.listBoostedHospitals(
      type: type,
      page: page,
      limit: limit,
    );

    if (!result.isSuccess || result.data == null) {
      final message = _extractMessage(result.error?.message) ??
          'Failed to load boosted hospitals.';
      throw Exception(message);
    }

    final payload = result.data!;
    final data = _asMap(payload['data']) ?? _asMap(payload);
    final hospitalMaps = _extractHospitalMaps(data);
    final pagination =
        _parsePagination(_asMap(payload['pagination']) ?? _asMap(data?['pagination']));

    final hospitals =
        hospitalMaps.map(HospitalModel.fromJson).toList(growable: false);

    return Paged<HospitalModel>(
      items: hospitals,
      meta: pagination,
    );
  }

  Future<Paged<HospitalModel>> getRecentHospitals({
    int page = 1,
    int limit = 6,
  }) {
    return _fetchHospitals(page: page, limit: limit);
  }

  Future<List<HospitalModel>> getFakeFeaturedHospitals({int limit = 6}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 12
            ? 12
            : limit;

    final hospitals = FakeFeaturedHospitalsResponse.getFakeFeaturedHospitals();
    if (hospitals.isEmpty) {
      return hospitals;
    }

    final cappedLimit =
        requestLimit > hospitals.length ? hospitals.length : requestLimit;
    return hospitals.sublist(0, cappedLimit);
  }

  Future<Paged<HospitalModel>> _fetchHospitals({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _remoteService.listHospitals(page: page, limit: limit);

    if (!result.isSuccess || result.data == null) {
      final message =
          _extractMessage(result.error?.message) ?? 'Failed to load hospitals.';
      throw Exception(message);
    }

    final payload = result.data!;
    final data = _asMap(payload['data']) ?? _asMap(payload);
    final hospitalMaps = _extractHospitalMaps(data);
    final pagination =
        _parsePagination(_asMap(payload['pagination']) ?? _asMap(data?['pagination']));

    final hospitals =
        hospitalMaps.map(HospitalModel.fromJson).toList(growable: false);

    return Paged<HospitalModel>(
      items: hospitals,
      meta: pagination,
    );
  }

  Future<HospitalModel> getHospitalById(String id) async {
    final result = await _remoteService.getHospitalById(id);
    if (!result.isSuccess || result.data == null) {
      final message =
          _extractMessage(result.error?.message) ?? 'Failed to load hospital.';
      throw Exception(message);
    }

    final data = result.data!;
    final maps = _extractHospitalMaps(data);

    if (maps.isEmpty) {
      throw Exception('Failed to parse hospital details.');
    }
    return HospitalModel.fromJson(maps.first);
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

  List<Map<String, dynamic>> _extractHospitalMaps(dynamic source) {
    if (source is List) {
      return source.whereType<Map<String, dynamic>>().toList(growable: false);
    }

    if (source is Map<String, dynamic>) {
      // Handle single hospital response
      if (source.containsKey('hospital') &&
          source['hospital'] is Map<String, dynamic>) {
        return [source['hospital'] as Map<String, dynamic>];
      }

      const candidateKeys = [
        'hospitals',
        'data',
        'docs',
        'items',
        'results',
      ];
      for (final key in candidateKeys) {
        if (!source.containsKey(key)) continue;
        final extracted = _extractHospitalMaps(source[key]);
        if (extracted.isNotEmpty) {
          return extracted;
        }
      }

      // Fallback: inspect nested map values
      for (final value in source.values) {
        final extracted = _extractHospitalMaps(value);
        if (extracted.isNotEmpty) {
          return extracted;
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _asMap(dynamic source) {
    if (source is Map<String, dynamic>) {
      return source;
    }
    if (source is Map) {
      return source.map((key, value) => MapEntry(key.toString(), value));
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
      pageSize: toInt(json['limit']) ?? toInt(json['pageSize']) ?? 10,
      total: toInt(json['total']) ?? 0,
      totalPages: toInt(json['pages']) ?? toInt(json['totalPages']) ?? 1,
    );
  }
}

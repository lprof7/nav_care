import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/services/models/pagination.dart';

import 'models/hospital.dart';
import 'models/hospital_payload.dart';
import 'models/hospitals_result.dart';
import 'services/hospitals_service.dart';

class HospitalsRepository {
  HospitalsRepository(this._service);

  final HospitalsService _service;
  List<Hospital> _cache = const [];
  Pagination? _lastPagination;

  List<Hospital> get cachedHospitals => List.unmodifiable(_cache);
  Pagination? get lastPagination => _lastPagination;

  Hospital? findById(String id) {
    try {
      return _cache.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Result<HospitalsResult>> fetchHospitals({
    int? page,
    int? limit,
  }) async {
    final response = await _service.fetchHospitals(page: page, limit: limit);

    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final parsed = _parseHospitalsResponse(response.data!);
      _cache = parsed.hospitals;
      _lastPagination = parsed.pagination;
      return Result.success(parsed);
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'Unable to parse hospitals response'),
      );
    }
  }

  Future<Result<Hospital>> submitHospital(HospitalPayload payload) async {
    try {
      final response =
          await _service.submitHospital(payload.toJson());



      final data = response.data;
      final rawHospital = data?['hospital'] ?? data?['data'] ?? data;
      final hospital = Hospital.fromJson(
          rawHospital is Map<String, dynamic> ? rawHospital : {});

      _cache = _upsert(_cache, hospital);
      return Result.success(hospital);
    } catch (e) {
      print(e);
      return Result.failure(
        const Failure.server(message: 'Failed to submit hospital'),
      );
    }
  }

  Future<Result<String>> deleteHospital(String hospitalId) async {
    final response = await _service.deleteHospital(hospitalId);

    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final message = response.data!['message']?.toString() ??
          'Hospital deleted successfully';
      _cache = _cache.where((element) => element.id != hospitalId).toList();
      return Result.success(message);
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'Failed to delete hospital'),
      );
    }
  }

  HospitalsResult _parseHospitalsResponse(Map<String, dynamic> json) {
    final data = _extractDataMap(json);
    final rawHospitals = data['hospitals'] ?? data['hospital'] ?? data['data'];

    List<Hospital> hospitals;
    if (rawHospitals is Iterable) {
      hospitals = rawHospitals
          .whereType<Map<String, dynamic>>()
          .map(Hospital.fromJson)
          .toList();
    } else if (rawHospitals is Map<String, dynamic>) {
      hospitals = [Hospital.fromJson(rawHospitals)];
    } else {
      hospitals = const [];
    }

    final paginationJson = data['pagination'];
    final pagination = paginationJson is Map<String, dynamic>
        ? Pagination.fromJson(paginationJson)
        : _lastPagination;

    return HospitalsResult(hospitals: hospitals, pagination: pagination);
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> json) {
    const candidates = ['data', 'result', 'payload'];
    for (final key in candidates) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }
    return json;
  }

  List<Hospital> _upsert(List<Hospital> source, Hospital hospital) {
    final list = List<Hospital>.from(source);
    final index = list.indexWhere((element) => element.id == hospital.id);
    if (index >= 0) {
      list[index] = hospital;
    } else {
      list.add(hospital);
    }
    return list;
  }
}

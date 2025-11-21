import 'models/hospital_model.dart';
import 'responses/fake_featured_hospitals_response.dart';
import 'hospitals_remote_service.dart';

class HospitalsRepository {
  // ignore: unused_field
  final HospitalsRemoteService _remoteService;

  HospitalsRepository({required HospitalsRemoteService remoteService})
      : _remoteService = remoteService;

  Future<List<HospitalModel>> getNavcareHospitalsChoice({int limit = 6}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 20
            ? 20
            : limit;

    final hospitals = await _fetchHospitals(limit: requestLimit);
    if (hospitals.isEmpty) {
      return hospitals;
    }

    final cappedLimit =
        requestLimit > hospitals.length ? hospitals.length : requestLimit;
    return hospitals.sublist(0, cappedLimit);
  }

  Future<List<HospitalModel>> getNavcareFeaturedHospitals(
      {int limit = 3}) async {
    return getFeaturedHospitals(limit: limit);
  }

  Future<List<HospitalModel>> getNavcareFeaturedClinics({int limit = 6}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 15
            ? 15
            : limit;

    final fetchLimit = ((requestLimit * 2).clamp(1, 40)).toInt();
    final hospitals = await _fetchHospitals(limit: fetchLimit);
    if (hospitals.isEmpty) {
      return hospitals;
    }

    final clinics = hospitals.where((hospital) {
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

  Future<List<HospitalModel>> getFeaturedHospitals({int limit = 6}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 20
            ? 20
            : limit;
    final result = await _remoteService.listBoostedHospitals(
      type: 'nav_care',
      page: 1,
      limit: requestLimit,
    );

    if (!result.isSuccess || result.data == null) {
      final message = _extractMessage(result.error?.message) ??
          'Failed to load featured hospitals.';
      throw Exception(message);
    }

    final hospitalMaps = _extractHospitalMaps(result.data);
    if (hospitalMaps.isEmpty) {
      return const [];
    }

    return hospitalMaps
        .take(requestLimit)
        .map(HospitalModel.fromJson)
        .toList(growable: false);
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

  Future<List<HospitalModel>> _fetchHospitals({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _remoteService.listHospitals(page: page, limit: limit);

    if (!result.isSuccess || result.data == null) {
      final message =
          _extractMessage(result.error?.message) ?? 'Failed to load hospitals.';
      throw Exception(message);
    }

    final hospitalMaps = _extractHospitalMaps(result.data);
    if (hospitalMaps.isEmpty) {
      return const [];
    }

    return hospitalMaps.map(HospitalModel.fromJson).toList(growable: false);
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
      const candidateKeys = [
        'hospital',
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
        if (key == 'hospital' && source[key] is Map<String, dynamic>) {
          return [source[key] as Map<String, dynamic>];
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
}

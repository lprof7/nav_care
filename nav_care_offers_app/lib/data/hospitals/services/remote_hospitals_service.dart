import 'dart:io';
import 'package:dio/dio.dart';
import 'package:nav_care_offers_app/core/config/api_config.dart';
import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart';
import 'package:cross_file/cross_file.dart';

import 'hospitals_service.dart';

class RemoteHospitalsService implements HospitalsService {
  RemoteHospitalsService(this._apiClient);

  final ApiClient _apiClient;

  @override
  String get baseUrl => _apiClient.apiConfig.baseUrl;

  ApiConfig get _config => _apiClient.apiConfig;

  @override
  Future<Result<Map<String, dynamic>>> fetchHospitals({
    int? page,
    int? limit,
  }) {
    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;
    return _apiClient.get(
      _config.userHospitals,
      query: query.isEmpty ? null : query,
      parser: _parseMap,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> submitHospital(
      HospitalPayload payload) async {
    print(payload.facilityType);
    final formData = FormData.fromMap(payload.toJson());

    for (final image in payload.images) {
      final bytes = await image.readAsBytes(); // Read file as bytes
      formData.files.add(MapEntry(
        'images',
        MultipartFile.fromBytes(bytes, filename: image.name),
      ));
    }

    return _apiClient.post(
      _config.hospitals,
      body: formData,
      parser: _parseMap,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> updateHospital(
      HospitalPayload payload) async {
    final formData = FormData.fromMap(payload.toJson());

    for (final image in payload.images) {
      final bytes = await image.readAsBytes(); // Read file as bytes
      formData.files.add(MapEntry(
        'images',
        MultipartFile.fromBytes(bytes, filename: image.name),
      ));
    }
    //TODO: add deleteItems to the payload
    return _apiClient.patch(
      _config.hospitals,
      body: formData,
      parser: _parseMap,
      useHospitalToken: true,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> deleteHospital(String hospitalId) {
    return _apiClient.delete(
      _config.hospitalById(hospitalId),
      parser: _parseMap,
      useHospitalToken: true,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> accessHospitalToken(String hospitalId) {
    return _apiClient.get(
      _config.accessHospitalById(hospitalId),
      parser: _parseMap,
    );
  }

  Map<String, dynamic> _parseMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, dynamic val) => MapEntry(key.toString(), val),
      );
    }
    return <String, dynamic>{};
  }
}

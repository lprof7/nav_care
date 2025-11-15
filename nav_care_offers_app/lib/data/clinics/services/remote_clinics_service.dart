import 'dart:io';
import 'package:dio/dio.dart';
import 'package:nav_care_offers_app/core/config/api_config.dart';
import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart';
import 'package:cross_file/cross_file.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';

import 'clinics_service.dart';

import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';
import 'package:get_it/get_it.dart';

class RemoteClinicsService implements ClinicsService {
  RemoteClinicsService(this._apiClient);

  final TokenStore _tokenStore = GetIt.I<TokenStore>();

  final ApiClient _apiClient;

  @override
  String get baseUrl => _apiClient.apiConfig.baseUrl;

  ApiConfig get _config => _apiClient.apiConfig;

  @override
  Future<Result<Map<String, dynamic>>> submitClinic(
      HospitalPayload payload) async {
    final formData = FormData.fromMap(payload.toJson());

    for (final image in payload.images) {
      final bytes = await image.readAsBytes();
      formData.files.add(MapEntry(
        'images',
        MultipartFile.fromBytes(bytes, filename: image.name),
      ));
    }
    return _apiClient.post(
      _config.clinics,
      body: formData,
      parser: _parseMap,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> updateClinic(
      HospitalPayload payload) async {
    final formData = FormData.fromMap(payload.toJson());

    for (final image in payload.images) {
      final bytes = await image.readAsBytes();
      formData.files.add(MapEntry(
        'images',
        MultipartFile.fromBytes(bytes, filename: image.name),
      ));
    }

    return _apiClient.patch(
      _config.clinicById(payload.id!), // Assuming a clinicById endpoint
      body: formData,
      parser: _parseMap,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> deleteClinic(String clinicId) {
    return _apiClient.delete(
      _config.clinicById(clinicId),
      parser: _parseMap,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> getHospitalClinics(
      String hospitalId) async {
    final hospitalToken = await _tokenStore.getHospitalToken();
    if (hospitalToken == null) {
      return Result.failure(Failure.unauthorized());
    }

    return _apiClient.get(
      _config.hospitalClinics(hospitalId),
      headers: {'Authorization': 'Bearer $hospitalToken'},
      parser: (data) => data as Map<String, dynamic>,
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

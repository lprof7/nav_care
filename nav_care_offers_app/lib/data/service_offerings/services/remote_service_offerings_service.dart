import 'package:dio/dio.dart';
import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering_payload.dart';

import 'service_offerings_service.dart';

class RemoteServiceOfferingsService implements ServiceOfferingsService {
  RemoteServiceOfferingsService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<Map<String, dynamic>>> fetchMyOfferings({
    int? page,
    int? limit,
    bool useHospitalToken = true,
  }) {
    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;
    final useDoctorToken = !useHospitalToken;
    return _apiClient.get(
      _apiClient.apiConfig.myServiceOfferings,
      query: query.isEmpty ? null : query,
      parser: _parseMap,
      useHospitalToken: useHospitalToken,
      useDoctorToken: useDoctorToken,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> fetchOfferingById(
    String offeringId, {
    bool useHospitalToken = true,
  }) async {
    final useDoctorToken = !useHospitalToken;
    return _apiClient.get(
      _apiClient.apiConfig.serviceOfferingById(offeringId),
      parser: _parseMap,
      useHospitalToken: useHospitalToken,
      useDoctorToken: useDoctorToken,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> createOffering(
    ServiceOfferingPayload payload, {
    bool useHospitalToken = true,
  }) async {
    final useDoctorToken = !useHospitalToken;
    final formData = FormData.fromMap(payload.toJson());
    if (payload.images != null) {
      for (final image in payload.images!) {
        final bytes = await image.readAsBytes();
        formData.files.add(MapEntry(
          'images',
          MultipartFile.fromBytes(bytes, filename: image.name),
        ));
      }
    }
    return _apiClient.post(
      _apiClient.apiConfig.serviceOfferingsBase,
      body: formData,
      parser: _parseMap,
      useHospitalToken: useHospitalToken,
      useDoctorToken: useDoctorToken,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> updateOffering(
    String offeringId,
    ServiceOfferingPayload payload,
    {bool useHospitalToken = true}) {
    final useDoctorToken = !useHospitalToken;
    final formData = FormData.fromMap(payload.toJson());
    return _apiClient.patch(
      _apiClient.apiConfig.serviceOfferingById(offeringId),
      body: formData,
      parser: _parseMap,
      useHospitalToken: useHospitalToken,
      useDoctorToken: useDoctorToken,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> deleteOffering(
    String offeringId, {
    bool useHospitalToken = true,
  }) {
    final useDoctorToken = !useHospitalToken;
    return _apiClient.delete(
      _apiClient.apiConfig.serviceOfferingById(offeringId),
      parser: _parseMap,
      useHospitalToken: useHospitalToken,
      useDoctorToken: useDoctorToken,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> fetchServicesCatalog({
    int? page,
    int? limit,
  }) {
    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;
    return _apiClient.get(
      _apiClient.apiConfig.servicesCatalog,
      query: query.isEmpty ? null : query,
      parser: _parseMap,
    );
  }

  Map<String, dynamic> _parseMap(dynamic source) {
    if (source is Map<String, dynamic>) return source;
    if (source is Map) {
      return source.map(
        (key, dynamic value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{};
  }
}

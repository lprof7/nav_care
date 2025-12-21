import 'package:dio/dio.dart';
import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_catalog_payload.dart';

import 'doctor_services_service.dart';

class RemoteDoctorServicesService implements DoctorServicesService {
  RemoteDoctorServicesService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<Map<String, dynamic>>> fetchServices({
    int? page,
    int? limit,
    bool? active,
  }) {
    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;
    if (active != null) query['active'] = active;

    return _apiClient.get(
      _apiClient.apiConfig.doctorServices,
      query: query.isEmpty ? null : query,
      parser: (json) => json as Map<String, dynamic>,
      useDoctorToken: true,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> fetchServicesCatalog({
    int? page,
    int? limit,
    bool useHospitalToken = true,
  }) {
    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;
    return _apiClient.get(
      _apiClient.apiConfig.servicesCatalog,
      query: query.isEmpty ? null : query,
      parser: (json) => json as Map<String, dynamic>,
      useHospitalToken: useHospitalToken,
      useDoctorToken: !useHospitalToken,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> createService(
    ServiceCatalogPayload payload, {
    bool useHospitalToken = true,
  }) async {
    final formData = FormData.fromMap(payload.toJson());
    if (payload.image != null) {
      final bytes = await payload.image!.readAsBytes();
      formData.files.add(MapEntry(
        'image',
        MultipartFile.fromBytes(bytes, filename: payload.image!.name),
      ));
    }
    return _apiClient.post(
      _apiClient.apiConfig.servicesCatalog,
      body: formData,
      parser: (json) => json as Map<String, dynamic>,
      useHospitalToken: useHospitalToken,
      useDoctorToken: !useHospitalToken,
    );
  }
}

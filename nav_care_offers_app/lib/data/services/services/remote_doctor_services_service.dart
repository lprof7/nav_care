import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';

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
    );
  }
}

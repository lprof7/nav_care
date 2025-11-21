import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';

class ClinicsRemoteService {
  ClinicsRemoteService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<Map<String, dynamic>>> getHospitalClinics(
    String hospitalId,
  ) {
    return _apiClient.get<Map<String, dynamic>>(
      _apiClient.apiConfig.hospitalClinics(hospitalId),
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}

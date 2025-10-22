import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';

class HospitalsRemoteService {
  HospitalsRemoteService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<Map<String, dynamic>>> listHospitals({
    int page = 1,
    int limit = 10,
  }) {
    /*return _apiClient.get<Map<String, dynamic>>(
      '/api/hospitals',
      query: {
        'page': page,
        'limit': limit,
      },
      parser: (json) => json as Map<String, dynamic>,
    );*/
    return _apiClient.get<Map<String, dynamic>>(
      '/api/hospitals',
      query: {},
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}

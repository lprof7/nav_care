import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';

class DoctorsRemoteService {
  DoctorsRemoteService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<Map<String, dynamic>>> listDoctors({
    int page = 1,
    int limit = 10,
  }) {
    return _apiClient.get<Map<String, dynamic>>(
      '/api/doctors',
      query: {
        'page': page,
        'limit': limit,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
  }
  
    Future<Result<Map<String, dynamic>>> listBoostedDoctors({
      required String type,
      int page = 1,
      int limit = 10,
    }) {
      return _apiClient.get<Map<String, dynamic>>(
        '/api/doctors/boosted',
        query: {
          'type': type,
          'page': page,
          'limit': limit,
        },
        parser: (json) => json as Map<String, dynamic>,
      );
    }
}

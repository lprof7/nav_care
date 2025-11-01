import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';

class SearchRemoteService {
  SearchRemoteService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<Map<String, dynamic>>> globalSearch(
      Map<String, dynamic> query) {
    return _apiClient.get<Map<String, dynamic>>(
      '/api/search/global',
      query: query,
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Result<Map<String, dynamic>>> suggestions(
      Map<String, dynamic> query) {
    return _apiClient.get<Map<String, dynamic>>(
      '/api/search/suggestions',
      query: query,
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}

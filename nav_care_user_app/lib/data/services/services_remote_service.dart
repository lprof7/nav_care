import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';

class ServicesRemoteService {
  ServicesRemoteService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<Map<String, dynamic>>> listServices({
    int page = 1,
    int limit = 20,
  }) {
    return _apiClient.get<Map<String, dynamic>>(
      _apiClient.apiConfig.listServices,
      query: {
        'page': page,
        'limit': limit,
      },
      parser: _parseMap,
    );
  }

  Future<Result<Map<String, dynamic>>> listServiceOfferings({
    required String serviceId,
    int page = 1,
    int limit = 20,
    String? providerId,
  }) {
    final query = <String, dynamic>{
      'service': serviceId,
      'page': page,
      'limit': limit,
      if (providerId != null && providerId.isNotEmpty) 'providerId': providerId,
    };

    return _apiClient.get<Map<String, dynamic>>(
      _apiClient.apiConfig.listServiceOfferings,
      query: query,
      parser: _parseMap,
    );
  }

  Map<String, dynamic> _parseMap(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) {
      return json.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}

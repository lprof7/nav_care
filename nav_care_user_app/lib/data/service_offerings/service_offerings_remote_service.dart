import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';

class ServiceOfferingsRemoteService {
  ServiceOfferingsRemoteService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<Map<String, dynamic>>> listServiceOfferings({
    int page = 1,
    int limit = 10,
    String? providerId,
    String? serviceId,
  }) {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (providerId != null && providerId.isNotEmpty) 'providerId': providerId,
      if (serviceId != null && serviceId.isNotEmpty) 'service': serviceId,
    };

    return _apiClient.get<Map<String, dynamic>>(
      _apiClient.apiConfig.listServiceOfferings,
      query: query,
      parser: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }
        if (json is Map) {
          return json.map(
            (key, value) => MapEntry(key.toString(), value),
          );
        }
        return <String, dynamic>{};
      },
    );
  }
}

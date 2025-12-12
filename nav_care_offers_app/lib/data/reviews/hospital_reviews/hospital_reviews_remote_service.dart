import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';

class HospitalReviewsRemoteService {
  final ApiClient _apiClient;
  final TokenStore _tokenStore;

  HospitalReviewsRemoteService({
    required ApiClient apiClient,
    required TokenStore tokenStore,
  })  : _apiClient = apiClient,
        _tokenStore = tokenStore;

  Future<Result<Map<String, dynamic>>> getHospitalReviews({
    required String hospitalId,
    int page = 1,
    int limit = 10,
  }) async {
    final token = await _tokenStore.getUserToken();
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return _apiClient.get(
      _apiClient.apiConfig.hospitalReviews(hospitalId),
      query: {'page': page, 'limit': limit},
      headers: headers.isEmpty ? null : headers,
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}

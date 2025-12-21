import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';

class ServiceOfferingReviewsRemoteService {
  final ApiClient _apiClient;
  final TokenStore _tokenStore;

  ServiceOfferingReviewsRemoteService({
    required ApiClient apiClient,
    required TokenStore tokenStore,
  })  : _apiClient = apiClient,
        _tokenStore = tokenStore;

  Future<Result<Map<String, dynamic>>> getReviews({
    required String offeringId,
    int page = 1,
    int limit = 10,
  }) async {
    final token = await _resolveToken();
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return _apiClient.get(
      _apiClient.apiConfig.serviceOfferingReviews(offeringId),
      query: {'page': page, 'limit': limit},
      headers: headers.isEmpty ? null : headers,
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<String?> _resolveToken() async {
    final isDoctor = await _tokenStore.getIsDoctor() ?? false;
    if (isDoctor) {
      final doctorToken = await _tokenStore.getDoctorToken();
      if (doctorToken != null && doctorToken.isNotEmpty) {
        return doctorToken;
      }
    }
    return _tokenStore.getUserToken();
  }
}

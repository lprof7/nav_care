import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/core/storage/token_store.dart';
import 'package:nav_care_user_app/core/responses/failure.dart';

class DoctorReviewsRemoteService {
  final ApiClient _apiClient;
  final TokenStore _tokenStore;

  DoctorReviewsRemoteService({
    required ApiClient apiClient,
    required TokenStore tokenStore,
  })  : _apiClient = apiClient,
        _tokenStore = tokenStore;

  Future<Result<Map<String, dynamic>>> getDoctorReviews({
    required String doctorId,
    int page = 1,
    int limit = 10,
  }) async {
    final token = await _tokenStore.getToken();
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return _apiClient.get(
      _apiClient.apiConfig.doctorReviews(doctorId),
      query: {'page': page, 'limit': limit},
      headers: headers.isEmpty ? null : headers,
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Result<Map<String, dynamic>>> createDoctorReview({
    required String doctorId,
    required double rating,
    required String comment,
  }) async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.post(
      _apiClient.apiConfig.doctorReviews(doctorId),
      body: {'rating': rating, 'comment': comment},
      headers: {'Authorization': 'Bearer $token'},
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}

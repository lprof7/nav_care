import 'package:dio/dio.dart';
import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/network/unauthorized_guard.dart';
import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/core/storage/token_store.dart';

class FeedbackRemoteService {
  FeedbackRemoteService({
    required ApiClient apiClient,
    required TokenStore tokenStore,
  })  : _apiClient = apiClient,
        _tokenStore = tokenStore;

  final ApiClient _apiClient;
  final TokenStore _tokenStore;

  Future<Result<Map<String, dynamic>>> sendFeedback({
    required String comment,
    MultipartFile? screenshot,
  }) async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      await handleUnauthorized();
      return Result.failure(const Failure.unauthorized());
    }

    final payload = <String, dynamic>{
      'comment': comment,
      if (screenshot != null) 'image': screenshot,
    };

    final body = screenshot != null ? FormData.fromMap(payload) : payload;

    return _apiClient.post(
      _apiClient.apiConfig.sendFeedback,
      body: body,
      headers: {'Authorization': 'Bearer $token'},
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}

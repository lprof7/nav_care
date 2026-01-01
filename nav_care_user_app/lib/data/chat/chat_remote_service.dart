import 'package:dio/dio.dart';
import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/network/unauthorized_guard.dart';
import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/core/storage/token_store.dart';

class ChatRemoteService {
  ChatRemoteService({required ApiClient apiClient, required TokenStore tokenStore})
      : _apiClient = apiClient,
        _tokenStore = tokenStore;

  final ApiClient _apiClient;
  final TokenStore _tokenStore;

  Future<Result<Map<String, dynamic>>> listConversations() async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      await handleUnauthorized();
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.get<Map<String, dynamic>>(
      _apiClient.apiConfig.listConversations,
      parser: (json) => json as Map<String, dynamic>,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Result<Map<String, dynamic>>> listMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      await handleUnauthorized();
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.get<Map<String, dynamic>>(
      _apiClient.apiConfig.conversationMessages(conversationId),
      query: {
        'page': page,
        'limit': limit,
      },
      parser: (json) => json as Map<String, dynamic>,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Result<Map<String, dynamic>>> createConversation({
    required String userId,
  }) async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      await handleUnauthorized();
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.post<Map<String, dynamic>>(
      _apiClient.apiConfig.listConversations,
      body: {'userId': userId},
      parser: (json) => json as Map<String, dynamic>,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Result<Map<String, dynamic>>> sendMessage({
    required String conversationId,
    required String type,
    required String message,
    String? imagePath,
  }) async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      await handleUnauthorized();
      return Result.failure(const Failure.unauthorized());
    }

    final data = FormData.fromMap({
      'type': type,
      'message': message,
      if (imagePath != null && imagePath.trim().isNotEmpty)
        'image': await MultipartFile.fromFile(imagePath),
    });

    return _apiClient.post<Map<String, dynamic>>(
      _apiClient.apiConfig.conversationMessages(conversationId),
      body: data,
      parser: (json) => json as Map<String, dynamic>,
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}

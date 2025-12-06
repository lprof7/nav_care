import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/core/storage/token_store.dart';

class UserRemoteService {
  UserRemoteService(
      {required ApiClient apiClient, required TokenStore tokenStore})
      : _apiClient = apiClient,
        _tokenStore = tokenStore;

  final ApiClient _apiClient;
  final TokenStore _tokenStore;

  Future<Result<Map<String, dynamic>>> getProfile() async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.get<Map<String, dynamic>>(
      '/api/users/me',
      parser: (json) {
        return json as Map<String, dynamic>;
      },
      headers: _authHeaders(token),
    );
  }

  Future<Result<Map<String, dynamic>>> updateProfile(Object payload) async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.patch<Map<String, dynamic>>(
      '/api/users/me',
      body: payload,
      parser: (json) {
        return json as Map<String, dynamic>;
      },
      headers: _authHeaders(token),
    );
  }

  Future<Result<Map<String, dynamic>>> updatePassword(
      {required String currentPassword, required String newPassword}) async {
    final token = await _tokenStore.getToken();
    if (token == null || token.isEmpty) {
      return Result.failure(const Failure.unauthorized());
    }

    return _apiClient.patch<Map<String, dynamic>>(
      '/api/users/me/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      parser: (json) => json as Map<String, dynamic>,
      headers: _authHeaders(token),
    );
  }

  Future<Result<Map<String, dynamic>>> requestPasswordReset(
      {required String email}) async {
    return _apiClient.post<Map<String, dynamic>>(
      '/api/auth/forgot-password',
      body: {'email': email},
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Map<String, String> _authHeaders(String token) =>
      {'Authorization': 'Bearer $token'};
}

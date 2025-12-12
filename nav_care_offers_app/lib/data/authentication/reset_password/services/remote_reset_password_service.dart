import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';

import 'reset_password_service.dart';

class RemoteResetPasswordService implements ResetPasswordService {
  RemoteResetPasswordService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<Map<String, dynamic>>> sendResetCode({required String email}) {
    return _apiClient.post(
      _apiClient.apiConfig.passwordResetCode,
      body: {'email': email},
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> verifyResetCode({
    required String email,
    required String resetCode,
  }) {
    return _apiClient.post(
      _apiClient.apiConfig.passwordVerifyCode,
      body: {'email': email, 'resetCode': resetCode},
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> resetPassword({
    required String email,
    required String resetCode,
    required String newPassword,
  }) {
    return _apiClient.post(
      _apiClient.apiConfig.passwordReset,
      body: {
        'email': email,
        'resetCode': resetCode,
        'newPassword': newPassword,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}

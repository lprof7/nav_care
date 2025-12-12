import 'package:nav_care_offers_app/core/responses/result.dart';

import 'services/reset_password_service.dart';

class ResetPasswordRepository {
  ResetPasswordRepository({required ResetPasswordService service})
      : _service = service;

  final ResetPasswordService _service;

  Future<void> sendResetCode(String email) async {
    final result = await _service.sendResetCode(email: email);
    _throwOnFailure(result);
  }

  Future<void> verifyResetCode({
    required String email,
    required String resetCode,
  }) async {
    final result =
        await _service.verifyResetCode(email: email, resetCode: resetCode);
    _throwOnFailure(result);
  }

  Future<void> resetPassword({
    required String email,
    required String resetCode,
    required String newPassword,
  }) async {
    final result = await _service.resetPassword(
      email: email,
      resetCode: resetCode,
      newPassword: newPassword,
    );
    _throwOnFailure(result);
  }

  void _throwOnFailure(Result<Map<String, dynamic>> result) {
    if (!result.isSuccess) {
      final message = result.error?.message;
      throw Exception(
        (message != null && message.isNotEmpty)
            ? message
            : 'Unable to process request.',
      );
    }
  }
}

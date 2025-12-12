import 'package:nav_care_offers_app/core/responses/result.dart';

abstract class ResetPasswordService {
  Future<Result<Map<String, dynamic>>> sendResetCode({required String email});

  Future<Result<Map<String, dynamic>>> verifyResetCode({
    required String email,
    required String resetCode,
  });

  Future<Result<Map<String, dynamic>>> resetPassword({
    required String email,
    required String resetCode,
    required String newPassword,
  });
}

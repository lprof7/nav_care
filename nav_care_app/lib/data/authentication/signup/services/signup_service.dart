import 'package:nav_care_app/core/responses/result.dart';

abstract class SignupService {
  Future<Result<Map<String, dynamic>>> signup(Map<String, dynamic> body);
}

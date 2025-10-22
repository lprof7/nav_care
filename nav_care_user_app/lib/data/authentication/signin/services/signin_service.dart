import 'package:nav_care_user_app/core/responses/result.dart';

abstract class SigninService {
  Future<Result<Map<String, dynamic>>> signin(Map<String, dynamic> body);
}

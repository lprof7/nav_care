import 'package:nav_care_offers_app/core/responses/result.dart';

abstract class SigninService {
  Future<Result<Map<String, dynamic>>> loginUser(
      Map<String, dynamic> body);
  Future<Result<Map<String, dynamic>>> loginDoctor(
      Map<String, dynamic> body);
}

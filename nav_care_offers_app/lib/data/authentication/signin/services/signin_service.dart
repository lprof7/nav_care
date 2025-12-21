import 'package:nav_care_offers_app/core/responses/result.dart';

abstract class SigninService {
  Future<Result<Map<String, dynamic>>> loginCheck(
      Map<String, dynamic> body);
}

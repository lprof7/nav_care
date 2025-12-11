import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/authentication/signup/models/signup_request.dart';

abstract class SignupService {
  Future<Result<Map<String, dynamic>>> signup(SignupRequest request);
}

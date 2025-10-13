import 'package:nav_care_app/core/responses/result.dart';
import 'services/signup_service.dart';

class SignupRepository {
  final SignupService _signupService;

  SignupRepository(this._signupService);

  Future<Result<void>> signup(Map<String, dynamic> body) {
    // TODO: implement signup
    throw UnimplementedError();
  }
}

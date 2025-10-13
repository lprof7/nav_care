import 'package:nav_care_app/core/network/api_client.dart';
import 'package:nav_care_app/core/responses/result.dart';
import 'signup_service.dart';

class RemoteSignupService implements SignupService {
  final ApiClient _api;
  RemoteSignupService(this._api);

  @override
  Future<Result<Map<String, dynamic>>> signup(Map<String, dynamic> body) {
    // TODO: implement signup
    throw UnimplementedError();
  }
}

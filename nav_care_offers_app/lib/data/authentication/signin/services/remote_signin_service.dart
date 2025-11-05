import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'signin_service.dart';

class RemoteSigninService implements SigninService {
  final ApiClient _api;
  RemoteSigninService(this._api);

  @override
  Future<Result<Map<String, dynamic>>> loginUser(
      Map<String, dynamic> body) async {
    return _api.post(
      _api.apiConfig.userLogin,
      body: body,
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> loginDoctor(
      Map<String, dynamic> body) async {
    return _api.post(
      _api.apiConfig.login,
      body: body,
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}

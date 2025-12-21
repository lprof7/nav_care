import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'signin_service.dart';

class RemoteSigninService implements SigninService {
  final ApiClient _api;
  RemoteSigninService(this._api);

  @override
  Future<Result<Map<String, dynamic>>> loginCheck(
      Map<String, dynamic> body) async {
    return _api.post(
      _api.apiConfig.loginCheck,
      body: body,
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}

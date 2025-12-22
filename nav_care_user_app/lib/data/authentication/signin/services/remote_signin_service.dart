import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'signin_service.dart';

class RemoteSigninService implements SigninService {
  final ApiClient _api;
  RemoteSigninService(this._api);

  @override
  Future<Result<Map<String, dynamic>>> signin(Map<String, dynamic> body) async {
    print("request all information: $body API: ${_api.apiConfig.login} ");
    return await _api.post(
      _api.apiConfig.login,
      body: body,
      parser: (json) {
        print(json);
        return json as Map<String, dynamic>;
      },
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    );
  }
}

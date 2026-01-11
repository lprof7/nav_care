import 'package:dio/dio.dart';
import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/core/utils/multipart_helper.dart';
import 'package:nav_care_user_app/data/authentication/signup/models/signup_request.dart';
import 'signup_service.dart';

class RemoteSignupService implements SignupService {
  final ApiClient _api;
  RemoteSignupService(this._api);

  @override
  Future<Result<Map<String, dynamic>>> signup(SignupRequest request) async {
    final payload = request.toMap();
    final fileValue = payload.remove('file');
    final file = await MultipartHelper.toMultipartFile(
      fileValue,
      fallbackName: 'profile-picture',
    );
    if (file != null) {
      payload['image'] = file;
    }

    final formData = FormData.fromMap(payload);
    print('Signup FormData: $formData');
    print("phone number: ${payload['phone_number']}");

    return _api.post(_api.apiConfig.register,
        body: formData, parser: (json) => json as Map<String, dynamic>);
  }
}

import 'package:dio/dio.dart';
import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/core/utils/multipart_helper.dart';
import 'service_creation_service.dart';

class RemoteServiceCreationService implements ServiceCreationService {
  final ApiClient _api;

  RemoteServiceCreationService(this._api);

  @override
  Future<Result<Map<String, dynamic>>> createService(
    Map<String, dynamic> body,
  ) async {
    final payload = Map<String, dynamic>.from(body);
    final fileValue = payload.remove('file');
    final file = await MultipartHelper.toMultipartFile(
      fileValue,
      fallbackName: 'service-image',
    );
    if (file != null) {
      payload['file'] = file;
    }

    final formData = FormData.fromMap(payload);

    return _api.post(
      _api.apiConfig.createService,
      body: formData,
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}

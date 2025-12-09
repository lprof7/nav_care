import 'package:dio/dio.dart';
import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/doctors/services/become_doctor_service.dart';

class RemoteBecomeDoctorService implements BecomeDoctorService {
  RemoteBecomeDoctorService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<Map<String, dynamic>>> becomeDoctor(FormData body) {
    return _apiClient.post(
      _apiClient.apiConfig.becomeDoctor,
      body: body,
      parser: (json) =>
          json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }
}

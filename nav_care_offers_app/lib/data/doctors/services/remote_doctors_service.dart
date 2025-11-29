import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/doctors/services/doctors_service.dart';

class RemoteDoctorsService implements DoctorsService {
  final ApiClient _apiClient;

  RemoteDoctorsService(this._apiClient);

  @override
  Future<Result<DoctorListModel>> getHospitalDoctors(String hospitalId) async {
    return _apiClient.get(
      '/api/hospitals/$hospitalId/doctors',
      parser: _parseDoctorList,
      useHospitalToken: true, // Use hospital token for this API call
    );
  }

  DoctorListModel _parseDoctorList(dynamic json) {
    if (json is Map<String, dynamic>) {
      final dataMap = json['data'] is Map<String, dynamic> ? json['data'] : json;
      return DoctorListModel.fromJson(
          dataMap is Map<String, dynamic> ? dataMap : <String, dynamic>{});
    }
    return DoctorListModel.fromJson(<String, dynamic>{'data': [], 'pagination': {}});
  }
}

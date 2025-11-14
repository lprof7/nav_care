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
      parser: (json) => DoctorListModel.fromJson(json['data']),
      useHospitalToken: true, // Use hospital token for this API call
    );
  }
}
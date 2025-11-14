import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/data/clinics/services/clinics_service.dart';

class RemoteClinicsService implements ClinicsService {
  final ApiClient _apiClient;

  RemoteClinicsService(this._apiClient);

  @override
  Future<Result<ClinicListModel>> getHospitalClinics(String hospitalId) async {
    return _apiClient.get(
      '/api/hospitals/$hospitalId/clinics',
      parser: (json) => ClinicListModel.fromJson(json['data']),
      useHospitalToken: true, // Use hospital token for this API call
    );
  }
}
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/data/clinics/services/clinics_service.dart';

class ClinicsRepository {
  final ClinicsService _clinicsService;

  ClinicsRepository(this._clinicsService);

  Future<Result<ClinicListModel>> getHospitalClinics(String hospitalId) async {
    return _clinicsService.getHospitalClinics(hospitalId);
  }
}
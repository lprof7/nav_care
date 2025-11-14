import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';

abstract class ClinicsService {
  Future<Result<ClinicListModel>> getHospitalClinics(String hospitalId);
}
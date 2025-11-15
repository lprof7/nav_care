import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart'; // Reusing HospitalPayload

abstract class ClinicsService {
  String get baseUrl;

  Future<Result<Map<String, dynamic>>> submitClinic(HospitalPayload payload);

  Future<Result<Map<String, dynamic>>> updateClinic(HospitalPayload payload);

  Future<Result<Map<String, dynamic>>> deleteClinic(String clinicId);
  Future<Result<Map<String, dynamic>>> getHospitalClinics(String hospitalId);
}

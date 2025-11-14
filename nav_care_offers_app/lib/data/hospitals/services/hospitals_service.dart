import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart';

abstract class HospitalsService {
  String get baseUrl;

  Future<Result<Map<String, dynamic>>> fetchHospitals({
    int? page,
    int? limit,
  });

  Future<Result<Map<String, dynamic>>> submitHospital(HospitalPayload payload);

  Future<Result<Map<String, dynamic>>> deleteHospital(String hospitalId);

  Future<Result<Map<String, dynamic>>> updateHospital(HospitalPayload payload);

  Future<Result<Map<String, dynamic>>> accessHospitalToken(String hospitalId);
}

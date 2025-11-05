import 'package:nav_care_offers_app/core/responses/result.dart';

abstract class HospitalsService {
  Future<Result<Map<String, dynamic>>> fetchHospitals({
    int? page,
    int? limit,
  });

  Future<Result<Map<String, dynamic>>> submitHospital(
      Map<String, dynamic> body);

  Future<Result<Map<String, dynamic>>> deleteHospital(String hospitalId);
}

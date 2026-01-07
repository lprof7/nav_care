import 'package:nav_care_offers_app/core/responses/result.dart';

abstract class HospitalStatsService {
  Future<Result<Map<String, dynamic>>> fetchHospitalStats();
}

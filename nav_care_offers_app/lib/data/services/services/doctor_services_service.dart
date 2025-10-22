import 'package:nav_care_offers_app/core/responses/result.dart';

abstract class DoctorServicesService {
  Future<Result<Map<String, dynamic>>> fetchServices({
    int? page,
    int? limit,
    bool? active,
  });
}

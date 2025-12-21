import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_catalog_payload.dart';

abstract class DoctorServicesService {
  Future<Result<Map<String, dynamic>>> fetchServices({
    int? page,
    int? limit,
    bool? active,
  });

  Future<Result<Map<String, dynamic>>> fetchServicesCatalog({
    int? page,
    int? limit,
    bool useHospitalToken = true,
  });

  Future<Result<Map<String, dynamic>>> createService(
    ServiceCatalogPayload payload, {
    bool useHospitalToken = true,
  });
}

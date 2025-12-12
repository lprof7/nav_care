import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering_payload.dart';

abstract class ServiceOfferingsService {
  Future<Result<Map<String, dynamic>>> fetchMyOfferings({
    int? page,
    int? limit,
    bool useHospitalToken = true,
  });

  Future<Result<Map<String, dynamic>>> fetchOfferingById(
    String offeringId, {
    bool useHospitalToken = true,
  });

  Future<Result<Map<String, dynamic>>> createOffering(
    ServiceOfferingPayload payload, {
    bool useHospitalToken = true,
  });

  Future<Result<Map<String, dynamic>>> updateOffering(
    String offeringId,
    ServiceOfferingPayload payload, {
    bool useHospitalToken = true,
  });

  Future<Result<Map<String, dynamic>>> deleteOffering(
    String offeringId, {
    bool useHospitalToken = true,
  });

  Future<Result<Map<String, dynamic>>> fetchServicesCatalog({
    int? page,
    int? limit,
  });
}

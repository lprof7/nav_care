import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering_payload.dart';

abstract class ServiceOfferingsService {
  Future<Result<Map<String, dynamic>>> fetchMyOfferings({
    int? page,
    int? limit,
  });

  Future<Result<Map<String, dynamic>>> fetchOfferingById(String offeringId);

  Future<Result<Map<String, dynamic>>> createOffering(
      ServiceOfferingPayload payload);

  Future<Result<Map<String, dynamic>>> updateOffering(
      String offeringId, ServiceOfferingPayload payload);

  Future<Result<Map<String, dynamic>>> fetchServicesCatalog({
    int? page,
    int? limit,
  });
}

import 'service_offering.dart';

class ServiceOfferingPayload {
  final String serviceId;
  final double? price;
  final String? offers;
  final String? descriptionEn;
  final String? descriptionFr;
  final String? descriptionAr;
  final String? descriptionSp;

  const ServiceOfferingPayload({
    required this.serviceId,
    this.price,
    this.offers,
    this.descriptionEn,
    this.descriptionFr,
    this.descriptionAr,
    this.descriptionSp,
  });

  factory ServiceOfferingPayload.fromExisting({
    required ServiceOffering offering,
    String? overrideServiceId,
  }) {
    return ServiceOfferingPayload(
      serviceId: overrideServiceId ?? offering.service.id,
      price: offering.price,
      offers: offering.offers.join(', '),
      descriptionEn: offering.descriptionEn,
      descriptionFr: offering.descriptionFr,
      descriptionAr: offering.descriptionAr,
      descriptionSp: offering.descriptionSp,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'service': serviceId,
    };
    if (price != null) map['price'] = price;
    if (offers != null && offers!.isNotEmpty) map['offers'] = offers;
    if (descriptionEn != null && descriptionEn!.isNotEmpty) {
      map['description_en'] = descriptionEn;
    }
    if (descriptionFr != null && descriptionFr!.isNotEmpty) {
      map['description_fr'] = descriptionFr;
    }
    if (descriptionAr != null && descriptionAr!.isNotEmpty) {
      map['description_ar'] = descriptionAr;
    }
    if (descriptionSp != null && descriptionSp!.isNotEmpty) {
      map['description_sp'] = descriptionSp;
    }
    return map;
  }
}

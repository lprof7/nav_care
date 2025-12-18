import 'service_offering.dart';

import 'package:image_picker/image_picker.dart';

import 'service_offering.dart';

class ServiceOfferingPayload {
  final String serviceId;
  final double? price;
  final String? offers;
  final String? descriptionEn;
  final String? descriptionFr;
  final String? descriptionAr;
  final String? descriptionSp;
  final String? nameEn;
  final String? nameFr;
  final String? nameAr;
  final List<XFile>? images;

  const ServiceOfferingPayload({
    required this.serviceId,
    this.price,
    this.offers,
    this.descriptionEn,
    this.descriptionFr,
    this.descriptionAr,
    this.descriptionSp,
    this.nameEn,
    this.nameFr,
    this.nameAr,
    this.images,
  });

  factory ServiceOfferingPayload.fromExisting({
    required ServiceOffering offering,
    String? overrideServiceId,
    String? nameEn,
    String? nameFr,
    String? nameAr,
    List<XFile>? images,
  }) {
    return ServiceOfferingPayload(
      serviceId: overrideServiceId ?? offering.service.id,
      price: offering.price,
      offers: offering.offers.join(', '),
      descriptionEn: offering.descriptionEn,
      descriptionFr: offering.descriptionFr,
      descriptionAr: offering.descriptionAr,
      descriptionSp: offering.descriptionSp,
      nameEn: nameEn,
      nameFr: nameFr,
      nameAr: nameAr,
      images: images,
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
    if (nameEn != null && nameEn!.isNotEmpty) {
      map['name_en'] = nameEn;
    }
    if (nameFr != null && nameFr!.isNotEmpty) {
      map['name_fr'] = nameFr;
    }
    if (nameAr != null && nameAr!.isNotEmpty) {
      map['name_ar'] = nameAr;
    }

    return map;
  }
}

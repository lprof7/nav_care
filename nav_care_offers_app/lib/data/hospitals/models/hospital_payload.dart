import 'package:cross_file/cross_file.dart';

import 'hospital.dart';

class HospitalPayload {
  final String? id;
  final String name;
  final String? descriptionEn; // Optional source text / English fallback
  final String? descriptionFr;
  final String? descriptionAr;
  final String address;
  final List<String> phones;
  final List<XFile> images;
  final FacilityType facilityType; // Add facilityType
  final String? hospitalId;
  final List<SocialMediaLink> socialMedia;
  final List<String> deleteItems;

  HospitalPayload({
    this.id,
    required this.name,
    this.descriptionEn, // Make descriptionEn optional
    this.descriptionFr,
    this.descriptionAr,
    required this.address,
    this.phones = const [],
    this.images = const [],
    this.facilityType = FacilityType.hospital, // Default to hospital
    this.hospitalId,
    this.socialMedia = const [],
    this.deleteItems = const [],
  });

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'name': name,
      if (descriptionEn != null)
        'description_en': descriptionEn, // Conditionally add descriptionEn
      if (descriptionFr != null) 'description_fr': descriptionFr,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      'address': address,
      'facility_type': facilityType.apiValue, // Use dynamic facilityType
      'coordinates':
          HospitalCoordinates(latitude: 0, longitude: 0).toJson(), // Always 0,0
    };

    if (phones.isNotEmpty) {
      payload['phone'] = phones.join(', ');
    }

    if (socialMedia.isNotEmpty) {
      payload['social_media'] =
          socialMedia.map((entry) => entry.toJson()).toList();
    }

    // Images will be handled separately in the service layer as multipart/form-data
    // if (images.isNotEmpty) {
    //   payload['images'] = images;
    // }

    if (id != null && id!.isNotEmpty) {
      payload['id'] = id;
    }

    if (hospitalId != null && hospitalId!.isNotEmpty) {
      payload['hospitalId'] = hospitalId;
    }
    if (deleteItems.isNotEmpty) {
      payload['deleteItems'] = deleteItems;
    }

    return payload;
  }

  HospitalPayload copyWith({
    String? id,
    String? name,
    String? descriptionEn,
    String? descriptionFr,
    String? descriptionAr,
    String? address,
    List<String>? phones,
    List<XFile>? images,
    FacilityType? facilityType,
    String? hospitalId,
    List<SocialMediaLink>? socialMedia,
    List<String>? deleteItems,
  }) {
    return HospitalPayload(
      id: id ?? this.id,
      name: name ?? this.name,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      address: address ?? this.address,
      phones: phones ?? this.phones,
      images: images ?? this.images,
      facilityType: facilityType ?? this.facilityType,
      hospitalId: hospitalId ?? this.hospitalId,
      socialMedia: socialMedia ?? this.socialMedia,
      deleteItems: deleteItems ?? this.deleteItems,
    );
  }
}

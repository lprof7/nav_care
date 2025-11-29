import 'package:cross_file/cross_file.dart';

import 'hospital.dart';

class HospitalPayload {
  final String? id;
  final String name;
  final String? descriptionEn; // Make descriptionEn optional
  final String address;
  final List<String> phones;
  final List<XFile> images;
  final FacilityType facilityType; // Add facilityType
  final String? hospitalId;

  HospitalPayload({
    this.id,
    required this.name,
    this.descriptionEn, // Make descriptionEn optional
    required this.address,
    this.phones = const [],
    this.images = const [],
    this.facilityType = FacilityType.hospital, // Default to hospital
    this.hospitalId,
  });

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'name': name,
      if (descriptionEn != null)
        'description_en': descriptionEn, // Conditionally add descriptionEn
      'address': address,
      'facility_type': facilityType.apiValue, // Use dynamic facilityType
      'coordinates':
          HospitalCoordinates(latitude: 0, longitude: 0).toJson(), // Always 0,0
    };

    if (phones.isNotEmpty) {
      payload['phone'] = phones.join(', ');
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

    return payload;
  }
}

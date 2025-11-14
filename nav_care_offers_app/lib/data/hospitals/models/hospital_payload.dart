import 'package:cross_file/cross_file.dart';

import 'hospital.dart';

class HospitalPayload {
  final String? id;
  final String name;
  final String descriptionEn;
  final String address;
  final List<String> phones;
  final List<XFile> images;

  HospitalPayload({
    this.id,
    required this.name,
    required this.descriptionEn,
    required this.address,
    this.phones = const [],
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'name': name,
      'description_en': descriptionEn,
      'address': address,
      'facility_type': FacilityType.hospital.apiValue, // Always Hospital
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

    return payload;
  }
}

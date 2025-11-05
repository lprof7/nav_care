import 'hospital.dart';

class HospitalPayload {
  final String? id;
  final String name;
  final String descriptionEn;
  final List<String> phones;
  final HospitalCoordinates? coordinates;
  final FacilityType facilityType;
  final List<String> images;

  HospitalPayload({
    this.id,
    required this.name,
    required this.descriptionEn,
    this.phones = const [],
    this.coordinates,
    this.facilityType = FacilityType.hospital,
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'name': name,
      'description_en': descriptionEn,
      'facility_type': facilityType.apiValue,
    };

    if (phones.isNotEmpty) {
      payload['phone'] = phones.join(', ');
    }

    if (coordinates != null) {
      payload['coordinates'] = coordinates!.toJson();
    }

    if (images.isNotEmpty) {
      payload['images'] = images;
    }

    if (id != null && id!.isNotEmpty) {
      payload['id'] = id;
    }

    return payload;
  }
}

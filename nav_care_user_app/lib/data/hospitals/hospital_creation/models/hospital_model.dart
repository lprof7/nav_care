class HospitalModel {
  final String id;
  final String name;
  final String description;
  final double? latitude;
  final double? longitude;
  final List<String> phones;
  final String facilityType;
  final String? imageUrl;

  HospitalModel({
    required this.id,
    required this.name,
    required this.description,
    required this.phones,
    required this.facilityType,
    this.latitude,
    this.longitude,
    this.imageUrl,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'];
    double? latitude;
    double? longitude;
    if (coordinates is Map<String, dynamic>) {
      final lat = coordinates['latitude'];
      final lng = coordinates['longitude'];
      latitude = lat is num ? lat.toDouble() : double.tryParse('$lat');
      longitude = lng is num ? lng.toDouble() : double.tryParse('$lng');
    }

    final phones = <String>[];
    final phoneField = json['phone'] ?? json['phones'];
    if (phoneField is List) {
      phones.addAll(phoneField.map((e) => e.toString()));
    } else if (phoneField != null) {
      phones.add(phoneField.toString());
    }

    final idValue = json['id'] ?? json['_id'] ?? json['hospital_id'];

    return HospitalModel(
      id: idValue?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      latitude: latitude,
      longitude: longitude,
      phones: phones,
      facilityType: json['facility_type']?.toString() ??
          json['facilityType']?.toString() ??
          '',
      imageUrl: json['image']?.toString() ??
          json['imageUrl']?.toString() ??
          json['file']?.toString(),
    );
  }
}

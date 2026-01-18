class HospitalModel {
  final String id;
  final String name;
  final String description;
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final String descriptionSp;
  final double? latitude;
  final double? longitude;
  final List<String> phones;
  final String facilityType;
  final String? imageUrl;

  HospitalModel({
    required this.id,
    required this.name,
    required this.description,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    required this.descriptionSp,
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
    final descriptionEn = json['description_en']?.toString() ?? '';
    final descriptionFr = json['description_fr']?.toString() ?? '';
    final descriptionAr = json['description_ar']?.toString() ?? '';
    final descriptionSp = json['description_sp']?.toString() ?? '';
    final description = _firstNonEmptyStrings([
      json['description']?.toString(),
      descriptionEn,
      descriptionFr,
      descriptionAr,
      descriptionSp,
    ]);

    return HospitalModel(
      id: idValue?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: description,
      descriptionEn: descriptionEn,
      descriptionFr: descriptionFr,
      descriptionAr: descriptionAr,
      descriptionSp: descriptionSp,
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

  static String _firstNonEmptyStrings(List<String?> values) {
    for (final value in values) {
      if (value == null) continue;
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }
}

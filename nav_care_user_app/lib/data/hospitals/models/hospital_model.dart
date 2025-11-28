class SocialMediaLink {
  final String type;
  final String link;

  SocialMediaLink({required this.type, required this.link});

  factory SocialMediaLink.fromJson(Map<String, dynamic> json) {
    return SocialMediaLink(
      type: json['type'] as String? ?? '',
      link: json['link'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'link': link,
    };
  }
}

class HospitalModel {
  final String id;
  final String name;
  final String field;
  final String facilityType;
  final String address;
  final List<String> images;
  final List<String> videos;
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final String descriptionSp;
  final double? latitude;
  final double? longitude;
  final double rating;
  final List<SocialMediaLink> socialMedia;
  final List<String> phone;

  HospitalModel({
    required this.id,
    required this.name,
    required this.field,
    required this.facilityType,
    required this.address,
    required this.images,
    required this.videos,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    required this.descriptionSp,
    this.latitude,
    this.longitude,
    this.rating = 0,
    this.socialMedia = const [],
    this.phone = const [],
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>?;
    final facilityTypeRaw = json['facility_type'] as String? ?? '';
    final fieldRaw = json['field'] as String? ?? '';
    final fallbackValue = facilityTypeRaw.isNotEmpty
        ? facilityTypeRaw
        : fieldRaw.isNotEmpty
            ? fieldRaw
            : 'Hospital';
    return HospitalModel(
      id: json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      field: fieldRaw.isNotEmpty ? fieldRaw : fallbackValue,
      facilityType:
          facilityTypeRaw.isNotEmpty ? facilityTypeRaw : fallbackValue,
      address: json['address'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      descriptionEn: json['description_en'] as String? ?? '',
      descriptionFr: json['description_fr'] as String? ?? '',
      descriptionAr: json['description_ar'] as String? ?? '',
      descriptionSp: json['description_sp'] as String? ?? '',
      latitude: coordinates?['latitude'] != null
          ? (coordinates?['latitude'] as num).toDouble()
          : null,
      longitude: coordinates?['longitude'] != null
          ? (coordinates?['longitude'] as num).toDouble()
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      socialMedia: (json['social_media'] as List<dynamic>?)
              ?.map((e) => SocialMediaLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      phone: (json['phone'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'field': field,
      'facility_type': facilityType,
      'address': address,
      'images': images,
      'videos': videos,
      'description_en': descriptionEn,
      'description_fr': descriptionFr,
      'description_ar': descriptionAr,
      'description_sp': descriptionSp,
      'coordinates': latitude != null && longitude != null
          ? {
              'latitude': latitude,
              'longitude': longitude,
            }
          : null,
      'rating': rating,
      'social_media': socialMedia.map((e) => e.toJson()).toList(),
      'phone': phone,
    };
  }

  String descriptionForLocale(String code) {
    switch (code) {
      case 'ar':
        return descriptionAr.isNotEmpty ? descriptionAr : descriptionEn;
      case 'fr':
        return descriptionFr.isNotEmpty ? descriptionFr : descriptionEn;
      case 'sp':
      case 'es':
        return descriptionSp.isNotEmpty ? descriptionSp : descriptionEn;
      default:
        return descriptionEn;
    }
  }

  String? primaryImage({String? baseUrl}) {
    if (images.isEmpty) return null;
    final first = images.first.trim();
    if (first.isEmpty) return null;
    if (first.startsWith('http')) return first;
    if (first.startsWith('assets/')) return first;
    if (baseUrl == null || baseUrl.isEmpty) return first;
    try {
      final resolved = Uri.parse(baseUrl).resolve(first);
      return resolved.toString();
    } catch (_) {
      return first;
    }
  }
}

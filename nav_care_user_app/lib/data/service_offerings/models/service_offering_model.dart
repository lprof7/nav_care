class ServiceOfferingModel {
  final String id;
  final ServiceSummary service;
  final ProviderSummary provider;
  final String providerType;
  final String nameEn;
  final String nameFr;
  final String nameAr;
  final String nameSp;
  final double? price;
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final String descriptionSp;
  final List<String> images;

  const ServiceOfferingModel({
    required this.id,
    required this.service,
    required this.provider,
    required this.providerType,
    required this.nameEn,
    required this.nameFr,
    required this.nameAr,
    required this.nameSp,
    required this.price,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    required this.descriptionSp,
    required this.images,
  });

  factory ServiceOfferingModel.fromJson(Map<String, dynamic> json) {
    return ServiceOfferingModel(
      id: json['_id']?.toString() ?? '',
      service: ServiceSummary.fromJson(
        (json['service'] as Map?)?.cast<String, dynamic>(),
      ),
      provider: ProviderSummary.fromJson(
        (json['provider'] as Map?)?.cast<String, dynamic>(),
      ),
      providerType: json['providerType']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      nameFr: json['name_fr']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameSp: json['name_sp']?.toString() ?? '',
      price: _parseDouble(json['price']),
      descriptionEn: json['description_en']?.toString() ?? '',
      descriptionFr: json['description_fr']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      descriptionSp: json['description_sp']?.toString() ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String nameForLocale(String locale) {
    switch (locale) {
      case 'ar':
        return _firstNonEmpty([nameAr, nameEn, nameFr, nameSp, service.fallbackName]);
      case 'fr':
        return _firstNonEmpty([nameFr, nameEn, nameAr, nameSp, service.fallbackName]);
      case 'sp':
      case 'es':
        return _firstNonEmpty([nameSp, nameEn, nameFr, nameAr, service.fallbackName]);
      default:
        return _firstNonEmpty([nameEn, nameFr, nameAr, nameSp, service.fallbackName]);
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String _firstNonEmpty(List<String> values) {
    return values.firstWhere(
      (value) => value.trim().isNotEmpty,
      orElse: () => '',
    );
  }
}

class ServiceSummary {
  final String id;
  final String nameEn;
  final String nameFr;
  final String nameAr;
  final String nameSp;
  final String? image;

  const ServiceSummary({
    required this.id,
    required this.nameEn,
    required this.nameFr,
    required this.nameAr,
    required this.nameSp,
    this.image,
  });

  factory ServiceSummary.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return ServiceSummary(
      id: map['_id']?.toString() ?? '',
      nameEn: map['name_en']?.toString() ?? '',
      nameFr: map['name_fr']?.toString() ?? '',
      nameAr: map['name_ar']?.toString() ?? '',
      nameSp: map['name_sp']?.toString() ?? '',
      image: map['image']?.toString(),
    );
  }

  String nameForLocale(String locale) {
    switch (locale) {
      case 'ar':
        return nameAr.isNotEmpty ? nameAr : fallbackName;
      case 'fr':
        return nameFr.isNotEmpty ? nameFr : fallbackName;
      case 'sp':
      case 'es':
        return nameSp.isNotEmpty ? nameSp : fallbackName;
      default:
        return fallbackName;
    }
  }

  String get fallbackName => nameEn.isNotEmpty
      ? nameEn
      : nameFr.isNotEmpty
          ? nameFr
          : nameAr.isNotEmpty
              ? nameAr
              : nameSp;
}

class ProviderSummary {
  final String id;
  final String name;
  final String? profilePicture;
  final String specialty;
  final double? rating;
  final int reviewsCount;
  final String? cover;
  final String? descriptionEn;
  final String? descriptionFr;
  final String? descriptionAr;
  final String? descriptionSp;
  final String? bioEn;
  final String? bioFr;
  final String? bioAr;
  final String? bioSp;
  final dynamic boost;
  final String? boostType;
  final DateTime? boostExpiresAt;

  const ProviderSummary({
    required this.id,
    required this.name,
    this.profilePicture,
    required this.specialty,
    required this.rating,
    required this.reviewsCount,
    required this.cover,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    required this.descriptionSp,
    required this.bioEn,
    required this.bioFr,
    required this.bioAr,
    required this.bioSp,
    required this.boost,
    required this.boostType,
    required this.boostExpiresAt,
  });

  factory ProviderSummary.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    final user = (map['user'] as Map?)?.cast<String, dynamic>() ?? {};
    final images = (map['images'] as List?)?.cast<dynamic>() ?? const [];

    return ProviderSummary(
      id: map['_id']?.toString() ?? '',
      name: map['name']?.toString() ?? user['name']?.toString() ?? '',
      profilePicture: map['profilePicture']?.toString() ??
          user['profilePicture']?.toString(),
      specialty: map['specialty']?.toString() ?? '',
      rating: ServiceOfferingModel._parseDouble(map['rating']),
      reviewsCount: map['reviewsCount'] is int ? map['reviewsCount'] : 0,
      cover: map['cover']?.toString() ??
          (images.isNotEmpty ? images.first.toString() : null),
      descriptionEn: map['description_en']?.toString(),
      descriptionFr: map['description_fr']?.toString(),
      descriptionAr: map['description_ar']?.toString(),
      descriptionSp: map['description_sp']?.toString(),
      bioEn: map['bio_en']?.toString(),
      bioFr: map['bio_fr']?.toString(),
      bioAr: map['bio_ar']?.toString(),
      bioSp: map['bio_sp']?.toString(),
      boost: map['boost'],
      boostType: map['boostType']?.toString(),
      boostExpiresAt: _parseDate(map['boostExpiresAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  String descriptionForLocale(String locale) {
    String? candidate;
    switch (locale) {
      case 'ar':
        candidate = descriptionAr ??
            bioAr ??
            descriptionEn ??
            bioEn ??
            descriptionFr ??
            bioFr ??
            descriptionSp ??
            bioSp;
        break;
      case 'fr':
        candidate = descriptionFr ??
            bioFr ??
            descriptionEn ??
            bioEn ??
            descriptionAr ??
            bioAr ??
            descriptionSp ??
            bioSp;
        break;
      case 'sp':
      case 'es':
        candidate = descriptionSp ??
            bioSp ??
            descriptionEn ??
            bioEn ??
            descriptionFr ??
            bioFr ??
            descriptionAr ??
            bioAr;
        break;
      default:
        candidate = descriptionEn ??
            bioEn ??
            descriptionFr ??
            bioFr ??
            descriptionAr ??
            bioAr ??
            descriptionSp ??
            bioSp;
    }
    return candidate?.trim() ?? '';
  }
}

class ProviderUser {
  final String id;
  final String phone;
  final String name;
  final String email;
  final String? profilePicture;

  const ProviderUser({
    required this.id,
    required this.phone,
    required this.name,
    required this.email,
    required this.profilePicture,
  });

  factory ProviderUser.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return ProviderUser(
      id: map['_id']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      profilePicture: map['profilePicture']?.toString(),
    );
  }
}

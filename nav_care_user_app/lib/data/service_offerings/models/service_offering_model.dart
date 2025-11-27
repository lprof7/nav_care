class ServiceOfferingModel {
  final String id;
  final ServiceSummary service;
  final ProviderSummary provider;
  final String providerType;
  final double? price;
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final String descriptionSp;

  const ServiceOfferingModel({
    required this.id,
    required this.service,
    required this.provider,
    required this.providerType,
    required this.price,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    required this.descriptionSp,
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
      price: _parseDouble(json['price']),
      descriptionEn: json['description_en']?.toString() ?? '',
      descriptionFr: json['description_fr']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      descriptionSp: json['description_sp']?.toString() ?? '',
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
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
  final ProviderUser user;
  final String specialty;
  final double? rating;
  final int reviewsCount;
  final String? cover;
  final String? bioEn;
  final String? bioFr;
  final String? bioAr;
  final String? bioSp;
  final dynamic boost;
  final String? boostType;
  final DateTime? boostExpiresAt;

  const ProviderSummary({
    required this.id,
    required this.user,
    required this.specialty,
    required this.rating,
    required this.reviewsCount,
    required this.cover,
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
    return ProviderSummary(
      id: map['_id']?.toString() ?? '',
      user: ProviderUser.fromJson(
        (map['user'] as Map?)?.cast<String, dynamic>(),
      ),
      specialty: map['specialty']?.toString() ?? '',
      rating: ServiceOfferingModel._parseDouble(map['rating']),
      reviewsCount: map['reviewsCount'] is int ? map['reviewsCount'] : 0,
      cover: map['cover']?.toString(),
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

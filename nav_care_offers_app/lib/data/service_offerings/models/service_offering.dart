import 'package:nav_care_offers_app/core/responses/pagination.dart';

class ServiceOfferingsResult {
  final List<ServiceOffering> offerings;
  final Pagination? pagination;

  ServiceOfferingsResult({
    required this.offerings,
    this.pagination,
  });
}

class ServiceOffering {
  final String id;
  final ServiceCategory service;
  final ProviderSummary provider;
  final String providerType;
  final double price;
  final List<String> images;
  final List<String> offers;
  final String? descriptionEn;
  final String? descriptionFr;
  final String? descriptionAr;
  final String? descriptionSp;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceOffering({
    required this.id,
    required this.service,
    required this.provider,
    required this.providerType,
    required this.price,
    this.images = const [],
    this.offers = const [],
    this.descriptionEn,
    this.descriptionFr,
    this.descriptionAr,
    this.descriptionSp,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceOffering.fromJson(Map<String, dynamic> json) {
    final serviceJson = json['service'] as Map<String, dynamic>? ?? const {};
    final providerJson = json['provider'] as Map<String, dynamic>? ?? const {};
    return ServiceOffering(
      id: (json['_id'] ?? json['id']).toString(),
      service: ServiceCategory.fromJson(serviceJson),
      provider: ProviderSummary.fromJson(providerJson),
      providerType: json['providerType']?.toString() ?? 'Hospital',
      price: _parseDouble(json['price']) ?? 0,
      images: _mapStringList(json['images']),
      offers: _mapStringList(json['offers']),
      descriptionEn: json['description_en']?.toString(),
      descriptionFr: json['description_fr']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      descriptionSp: json['description_sp']?.toString(),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }
}

class ServiceCategory {
  final String id;
  final String? nameEn;
  final String? nameFr;
  final String? nameAr;
  final String? nameSp;
  final String? descriptionEn;
  final String? descriptionFr;
  final String? descriptionAr;
  final String? descriptionSp;
  final String? image;

  ServiceCategory({
    required this.id,
    this.nameEn,
    this.nameFr,
    this.nameAr,
    this.nameSp,
    this.descriptionEn,
    this.descriptionFr,
    this.descriptionAr,
    this.descriptionSp,
    this.image,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: (json['_id'] ?? json['id']).toString(),
      nameEn: json['name_en']?.toString(),
      nameFr: json['name_fr']?.toString(),
      nameAr: json['name_ar']?.toString(),
      nameSp: json['name_sp']?.toString(),
      descriptionEn: json['description_en']?.toString(),
      descriptionFr: json['description_fr']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      descriptionSp: json['description_sp']?.toString(),
      image: json['image']?.toString(),
    );
  }

  String localizedName(String locale) {
    switch (locale) {
      case 'ar':
        return nameAr ?? nameEn ?? nameFr ?? nameSp ?? '';
      case 'fr':
        return nameFr ?? nameEn ?? nameAr ?? nameSp ?? '';
      case 'sp':
      case 'es':
        return nameSp ?? nameEn ?? nameFr ?? nameAr ?? '';
      default:
        return nameEn ?? nameAr ?? nameFr ?? nameSp ?? '';
    }
  }
}

class ProviderSummary {
  final String id;
  final ProviderUser user;
  final String? specialty;
  final double? rating;
  final String? cover;
  final String? bioEn;
  final String? bioFr;
  final String? bioAr;
  final String? bioSp;

  ProviderSummary({
    required this.id,
    required this.user,
    this.specialty,
    this.rating,
    this.cover,
    this.bioEn,
    this.bioFr,
    this.bioAr,
    this.bioSp,
  });

  factory ProviderSummary.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final userMap =
        userJson is Map<String, dynamic> ? userJson : <String, dynamic>{};
    return ProviderSummary(
      id: (json['_id'] ?? userMap['_id'] ?? userMap['id'] ?? '').toString(),
      user: ProviderUser.fromJson(userMap),
      specialty: json['specialty']?.toString(),
      rating: _parseDouble(json['rating']),
      cover: json['cover']?.toString(),
      bioEn: json['bio_en']?.toString(),
      bioFr: json['bio_fr']?.toString(),
      bioAr: json['bio_ar']?.toString(),
      bioSp: json['bio_sp']?.toString(),
    );
  }
}

class ProviderUser {
  final String id;
  final String? phone;
  final String name;
  final String? email;
  final String? profilePicture;

  ProviderUser({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.profilePicture,
  });

  factory ProviderUser.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] ?? json['id'] ?? '';
    final name = json['name'] ??
        json['fullName'] ??
        json['displayName'] ??
        'Provider';
    return ProviderUser(
      id: id.toString(),
      name: name.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
    );
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

List<String> _mapStringList(dynamic source) {
  if (source is Iterable) {
    return source.map((e) => e.toString()).toList();
  }
  if (source is String && source.isNotEmpty) {
    return [source];
  }
  return const [];
}

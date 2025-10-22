import 'package:nav_care_offers_app/data/authentication/models.dart';

class DoctorService {
  final String id;
  final ServiceInfo service;
  final String providerType;
  final Doctor provider;
  final List<String> images;
  final List<String> videos;
  final String? descriptionEn;
  final String? descriptionFr;
  final String? descriptionAr;
  final String? descriptionSp;
  final double? price;
  final List<String> offers;
  final bool? active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DoctorService({
    required this.id,
    required this.service,
    required this.providerType,
    required this.provider,
    this.images = const [],
    this.videos = const [],
    this.descriptionEn,
    this.descriptionFr,
    this.descriptionAr,
    this.descriptionSp,
    this.price,
    this.offers = const [],
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory DoctorService.fromJson(Map<String, dynamic> json) {
    return DoctorService(
      id: (json['_id'] ?? json['id']).toString(),
      service: ServiceInfo.fromJson(json['service'] as Map<String, dynamic>),
      providerType: json['providerType']?.toString() ?? 'Doctor',
      provider: Doctor.fromJson(json['provider'] as Map<String, dynamic>),
      images: _mapStringList(json['images']),
      videos: _mapStringList(json['videos']),
      descriptionEn: json['description_en']?.toString(),
      descriptionFr: json['description_fr']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      descriptionSp: json['description_sp']?.toString(),
      price: _parseDouble(json['price']),
      offers: _mapStringList(json['offers']),
      active: json['active'] is bool ? json['active'] as bool : null,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static List<String> _mapStringList(dynamic value) {
    if (value is Iterable) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class ServiceInfo {
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

  ServiceInfo({
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

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
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
}

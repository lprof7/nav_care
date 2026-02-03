import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';

class ClinicModel extends Equatable {
  final String id;
  final String name;
  final List<String> images;
  final String? description;
  final String? descriptionAr;
  final String? descriptionFr;
  final String? address;
  final List<String> phones;
  final List<SocialMediaLink> socialMedia;

  const ClinicModel({
    required this.id,
    required this.name,
    this.images = const [],
    this.description,
    this.descriptionAr,
    this.descriptionFr,
    this.address,
    this.phones = const [],
    this.socialMedia = const [],
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      images: _parseImages(json['images']),
      description:
          json['description']?.toString() ?? json['description_en']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      descriptionFr: json['description_fr']?.toString(),
      address: json['address']?.toString(),
      phones: _parsePhones(json['phone'] ?? json['phones']),
      socialMedia:
          _parseSocialMedia(json['social_media'] ?? json['socialMedia']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'images': images,
      if (description != null) 'description_en': description,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      if (descriptionFr != null) 'description_fr': descriptionFr,
      if (address != null) 'address': address,
      'phones': phones,
      if (socialMedia.isNotEmpty)
        'social_media': socialMedia.map((entry) => entry.toJson()).toList(),
    };
  }

  static List<String> _parsePhones(dynamic value) {
    if (value is Iterable) {
      return value
          .map((item) => item.toString())
          .where((p) => p.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String && value.isNotEmpty) {
      return value
          .split(RegExp(r'[,;]'))
          .map((e) => e.trim())
          .where((p) => p.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  static List<String> _parseImages(dynamic value) {
    if (value is Iterable) {
      return value
          .map((item) => item.toString())
          .where((p) => p.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  static List<SocialMediaLink> _parseSocialMedia(dynamic value) {
    if (value is Iterable) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(SocialMediaLink.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  Hospital toHospital() {
    return Hospital(
      id: id,
      name: name,
      descriptionEn: description,
      address: address,
      phones: phones,
      socialMedia: socialMedia,
      images: images,
      facilityType: FacilityType.clinic,
      clinics: const [],
      doctors: const [],
      rating: 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        images,
        description,
        address,
        phones,
        socialMedia,
      ];
}

class ClinicListModel extends Equatable {
  final List<ClinicModel> data;
  final Pagination pagination;

  const ClinicListModel({
    required this.data,
    required this.pagination,
  });

  factory ClinicListModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] ?? json['clinics'] ?? [];
    final list = (rawList as List)
        .whereType<Map<String, dynamic>>()
        .map(ClinicModel.fromJson)
        .toList();
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};
    return ClinicListModel(
      data: list,
      pagination: Pagination.fromJson(paginationJson),
    );
  }

  @override
  List<Object?> get props => [data, pagination];
}

import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';

class Hospital extends Equatable {
  final String id;
  final String name;
  final String? displayName;
  final String? descriptionEn;
  final String? descriptionFr;
  final String? descriptionAr;
  final String? address; // New address field
  final List<String> phones;
  final HospitalCoordinates? coordinates;
  final FacilityType facilityType;
  final List<String> images;
  final List<HospitalClinic> clinics;
  final List<Doctor> doctors;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Hospital({
    required this.id,
    required this.name,
    this.displayName,
    this.descriptionEn,
    this.descriptionFr,
    this.descriptionAr,
    this.address, // Add to constructor
    this.phones = const [],
    this.coordinates,
    this.facilityType = FacilityType.unknown,
    this.images = const [],
    this.clinics = const [],
    this.doctors = const [],
    this.createdAt,
    this.updatedAt,
  });

  static const _unknownName = 'Unnamed facility';

  factory Hospital.fromJson(Map<String, dynamic> json,
      {required String baseUrl}) {
    final id = (json['_id'] ?? json['id'])?.toString();
    final rawName =
        json['name']?.toString() ?? json['display_name']?.toString();
    final descriptionEn = json['description_en']?.toString();
    final descriptionFr = json['description_fr']?.toString();
    final descriptionAr = json['description_ar']?.toString();

    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      return Hospital.fromJson(
        {...rawData},
        baseUrl: baseUrl,
      );
    }

    final rawClinics = json['clinics'];
    final rawDoctors = json['doctors'];

    return Hospital(
      id: id ?? '',
      name: rawName?.isNotEmpty == true ? rawName! : _unknownName,
      displayName: json['display_name']?.toString(),
      descriptionEn: descriptionEn,
      descriptionFr: descriptionFr,
      descriptionAr: descriptionAr,
      address: json['address']?.toString(), // Parse address
      phones: _parsePhones(json['phone'] ?? json['phones']),
      coordinates: HospitalCoordinates.fromJson(json['coordinates']),
      facilityType: FacilityTypeMapper.fromJson(json['facility_type']),
      images: _parseStringList(json['images'], baseUrl: baseUrl),
      clinics: _parseClinics(rawClinics, baseUrl: baseUrl),
      doctors: _parseDoctors(rawDoctors),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Hospital copyWith({
    String? id,
    String? name,
    String? displayName,
    String? descriptionEn,
    String? descriptionFr,
    String? descriptionAr,
    String? address, // Add to copyWith
    List<String>? phones,
    HospitalCoordinates? coordinates,
    FacilityType? facilityType,
    List<String>? images,
    List<HospitalClinic>? clinics,
    List<Doctor>? doctors,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Hospital(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      address: address ?? this.address, // Update address
      phones: phones ?? this.phones,
      coordinates: coordinates ?? this.coordinates,
      facilityType: facilityType ?? this.facilityType,
      images: images ?? this.images,
      clinics: clinics ?? this.clinics,
      doctors: doctors ?? this.doctors,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      if (displayName != null) 'display_name': displayName,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (descriptionFr != null) 'description_fr': descriptionFr,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      if (address != null) 'address': address, // Add address to toJson
      if (phones.isNotEmpty) 'phones': phones,
      if (coordinates != null) 'coordinates': coordinates!.toJson(),
      'facility_type': facilityType.apiValue,
      if (images.isNotEmpty) 'images': images,
      if (clinics.isNotEmpty)
        'clinics': clinics.map((e) => e.toJson()).toList(),
      if (doctors.isNotEmpty)
        'doctors': doctors.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  static List<String> _parsePhones(dynamic value) {
    if (value is Iterable) {
      return value
          .map((item) => item.toString())
          .where((p) => p.isNotEmpty)
          .toList();
    }
    if (value is String && value.isNotEmpty) {
      return value
          .split(RegExp(r'[,;]'))
          .map((phone) => phone.trim())
          .where((p) => p.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static List<String> _parseStringList(dynamic value,
      {required String baseUrl}) {
    if (value is Iterable) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .map((item) => item.startsWith('http') ? item : '$baseUrl/$item')
          .toList();
    }
    if (value is String && value.isNotEmpty) {
      return value
          .split(RegExp(r'[,;]'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .map((item) => item.startsWith('http') ? item : '$baseUrl/$item')
          .toList();
    }
    return const [];
  }

  static List<HospitalClinic> _parseClinics(dynamic value,
      {required String baseUrl}) {
    if (value is Iterable) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((json) => HospitalClinic.fromJson(json, baseUrl: baseUrl))
          .toList();
    }
    return const [];
  }

  static List<Doctor> _parseDoctors(dynamic value) {
    if (value is Iterable) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(Doctor.fromJson)
          .toList();
    }
    return const [];
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        descriptionEn,
        descriptionFr,
        descriptionAr,
        address, // Add to props
        phones,
        coordinates,
        facilityType,
        images,
        clinics,
        doctors,
        createdAt,
        updatedAt,
      ];
}

class HospitalClinic extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<String> phones;
  final List<String> images;

  const HospitalClinic({
    required this.id,
    required this.name,
    this.description,
    this.phones = const [],
    this.images = const [],
  });

  factory HospitalClinic.fromJson(Map<String, dynamic> json,
      {required String baseUrl}) {
    final id = (json['_id'] ?? json['id'])?.toString() ?? '';
    final name = json['name']?.toString() ?? '';

    return HospitalClinic(
      id: id,
      name: name.isEmpty ? Hospital._unknownName : name,
      description:
          json['description']?.toString() ?? json['description_en']?.toString(),
      phones: Hospital._parsePhones(json['phone'] ?? json['phones']),
      images: Hospital._parseStringList(json['images'], baseUrl: baseUrl),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      if (description != null) 'description_en': description,
      if (phones.isNotEmpty) 'phones': phones,
      if (images.isNotEmpty) 'images': images,
    };
  }

  @override
  List<Object?> get props => [id, name, description, phones, images];
}

class HospitalCoordinates extends Equatable {
  final double latitude;
  final double longitude;

  const HospitalCoordinates({
    required this.latitude,
    required this.longitude,
  });

  static HospitalCoordinates? fromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      final lat = _parseDouble(value['latitude']);
      final lng = _parseDouble(value['longitude']);
      if (lat != null && lng != null) {
        return HospitalCoordinates(latitude: lat, longitude: lng);
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  @override
  List<Object?> get props => [latitude, longitude];
}

enum FacilityType { hospital, clinic, unknown }

extension FacilityTypeMapper on FacilityType {
  static FacilityType fromJson(dynamic value) {
    final text = value?.toString().toLowerCase();
    switch (text) {
      case 'clinic':
        return FacilityType.clinic;
      case 'hospital':
        return FacilityType.hospital;
      default:
        return FacilityType.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case FacilityType.clinic:
        return 'Clinic';
      case FacilityType.hospital:
        return 'Hospital';
      case FacilityType.unknown:
        return 'unknown';
    }
  }

  String translationKey(String baseKey) {
    switch (this) {
      case FacilityType.clinic:
        return '$baseKey.clinic';
      case FacilityType.hospital:
        return '$baseKey.hospital';
      case FacilityType.unknown:
        return '$baseKey.unknown';
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart';

class DoctorModel extends Equatable {
  final String id;
  final String displayName;
  final String specialty;
  final double rating;
  final String cover;
  final String bioEn;
  final String bioFr;
  final String bioAr;
  final String bioSp;
  final String? avatar;
  final String? userId;
  final String? email;
  final String? phone;
  final List<String> affiliations;

  const DoctorModel({
    required this.id,
    required this.displayName,
    required this.specialty,
    required this.rating,
    required this.cover,
    required this.bioEn,
    required this.bioFr,
    required this.bioAr,
    required this.bioSp,
    this.avatar,
    this.userId,
    this.email,
    this.phone,
    this.affiliations = const [],
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final userName = user?['name']?.toString() ??
        user?['full_name']?.toString() ??
        user?['username']?.toString() ??
        '';

    return DoctorModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      displayName: userName,
      specialty: json['specialty']?.toString() ?? '',
      rating: _parseDouble(json['rating']) ?? 0,
      cover: json['cover']?.toString() ?? '',
      bioEn: json['bio_en']?.toString() ?? '',
      bioFr: json['bio_fr']?.toString() ?? '',
      bioAr: json['bio_ar']?.toString() ?? '',
      bioSp: json['bio_sp']?.toString() ?? '',
      avatar: user?['profilePicture']?.toString() ?? user?['avatar']?.toString(),
      userId: user?['_id']?.toString() ?? user?['id']?.toString(),
      email: user?['email']?.toString(),
      phone: user?['phone']?.toString(),
      affiliations: _parseAffiliations(json['affiliations']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'specialty': specialty,
      'rating': rating,
      'cover': cover,
      'bio_en': bioEn,
      'bio_fr': bioFr,
      'bio_ar': bioAr,
      'bio_sp': bioSp,
      'affiliations': affiliations,
      'user': {
        '_id': userId,
        'name': displayName,
        'email': email,
        'avatar': avatar,
        'phone': phone,
      },
    };
  }

  String bioForLocale(String code) {
    switch (code) {
      case 'ar':
        return bioAr.isNotEmpty ? bioAr : bioEn;
      case 'fr':
        return bioFr.isNotEmpty ? bioFr : bioEn;
      case 'sp':
      case 'es':
        return bioSp.isNotEmpty ? bioSp : bioEn;
      default:
        return bioEn;
    }
  }

  String? coverImage({String? baseUrl}) => _resolveAssetPath(cover, baseUrl);

  String? avatarImage({String? baseUrl}) => _resolveAssetPath(avatar, baseUrl);

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String> _parseAffiliations(dynamic value) {
    if (value is Iterable) {
      return value.map((e) => e.toString()).where((v) => v.isNotEmpty).toList();
    }
    return const [];
  }

  String? _resolveAssetPath(String? value, String? baseUrl) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http')) return trimmed;
    if (baseUrl == null || baseUrl.isEmpty) return trimmed;
    return Uri.parse(baseUrl).resolve(trimmed).toString();
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        specialty,
        rating,
        cover,
        bioEn,
        bioFr,
        bioAr,
        bioSp,
        avatar,
        userId,
        email,
        phone,
        affiliations,
      ];
}

class DoctorListModel extends Equatable {
  final List<DoctorModel> data;
  final Pagination pagination;

  const DoctorListModel({
    required this.data,
    required this.pagination,
  });

  factory DoctorListModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] ?? json['doctors'] ?? [];
    final list = (rawList as List)
        .whereType<Map<String, dynamic>>()
        .map(DoctorModel.fromJson)
        .toList();
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};
    return DoctorListModel(
      data: list,
      pagination: Pagination.fromJson(paginationJson),
    );
  }

  @override
  List<Object?> get props => [data, pagination];
}

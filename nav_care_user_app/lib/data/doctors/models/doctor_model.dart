class DoctorModel {
  final String id;
  final String cover;
  final String specialty;
  final double rating;
  final String bioEn;
  final String bioFr;
  final String bioAr;
  final String bioSp;
  final String displayName;
  final String? avatar;
  final String? userId;
  final String? email;
  final String? phone;
  final List<String> affiliations;

  DoctorModel({
    required this.id,
    required this.cover,
    required this.specialty,
    required this.rating,
    required this.bioEn,
    required this.bioFr,
    required this.bioAr,
    required this.bioSp,
    required this.displayName,
    this.avatar,
    this.userId,
    this.email,
    this.phone,
    this.affiliations = const [],
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final userName = user?['name'] as String? ??
        user?['full_name'] as String? ??
        user?['username'] as String? ??
        '';

    return DoctorModel(
      id: json['_id']?.toString() ?? '',
      cover: json['cover'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      bioEn: json['bio_en'] as String? ?? '',
      bioFr: json['bio_fr'] as String? ?? '',
      bioAr: json['bio_ar'] as String? ?? '',
      bioSp: json['bio_sp'] as String? ?? '',
      displayName: userName,
      avatar: (user?['profilePicture'] ?? user?['avatar']) as String?,
      userId: user?['_id']?.toString(),
      email: user?['email'] as String?,
      phone: user?['phone']?.toString(),
      affiliations: (json['affiliations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((value) => value.isNotEmpty)
              .toList(growable: false) ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'cover': cover,
      'specialty': specialty,
      'rating': rating,
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

  String? coverImage({String? baseUrl}) {
    return _resolveAssetPath(cover, baseUrl);
  }

  String? avatarImage({String? baseUrl}) {
    return _resolveAssetPath(avatar, baseUrl);
  }

  String? _resolveAssetPath(String? value, String? baseUrl) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http')) return trimmed;
    if (trimmed.startsWith('assets/')) return trimmed;
    if (baseUrl == null || baseUrl.isEmpty) return trimmed;
    try {
      final resolved = Uri.parse(baseUrl).resolve(trimmed);
      return resolved.toString();
    } catch (_) {
      return trimmed;
    }
  }
}

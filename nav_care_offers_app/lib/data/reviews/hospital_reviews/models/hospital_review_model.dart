class HospitalReviewModel {
  final String id;
  final double rating;
  final String comment;
  final HospitalReviewer reviewer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HospitalReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.reviewer,
    this.createdAt,
    this.updatedAt,
  });

  factory HospitalReviewModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    DateTime? _parseDate(dynamic value) {
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    Map<String, dynamic> _parseReviewer(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), v));
      }
      if (value is String && value.isNotEmpty) return {'_id': value};
      return const {};
    }

    return HospitalReviewModel(
      id: json['_id']?.toString() ?? '',
      rating: _toDouble(json['rating']),
      comment: json['comment']?.toString() ?? '',
      reviewer: HospitalReviewer.fromJson(_parseReviewer(json['reviewer'])),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }
}

class HospitalReviewer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profilePicture;

  const HospitalReviewer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePicture,
  });

  factory HospitalReviewer.fromJson(Map<String, dynamic> json) {
    return HospitalReviewer(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profilePicture: json['profilePicture']?.toString() ?? '',
    );
  }

  String avatarUrl(String baseUrl) {
    if (profilePicture.isEmpty) return '';
    if (profilePicture.startsWith('http')) return profilePicture;
    try {
      return Uri.parse(baseUrl).resolve(profilePicture).toString();
    } catch (_) {
      return profilePicture;
    }
  }
}

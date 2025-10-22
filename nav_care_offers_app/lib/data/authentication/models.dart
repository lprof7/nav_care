class User {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] ?? json['id'];
    final name = json['name'] ?? json['fullName'];
    final email = json['email'];
    if (id == null || name == null || email == null) {
      throw const FormatException('Missing required user fields');
    }
    return User(
      id: id.toString(),
      name: name.toString(),
      email: email.toString(),
      profilePicture: json['profilePicture']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      if (profilePicture != null) 'profilePicture': profilePicture,
    };
  }
}

class Doctor {
  final String id;
  final User user;
  final String? cover;
  final String? specialty;
  final double? rating;
  final String? bioEn;
  final String? bioFr;
  final String? bioAr;
  final String? bioSp;
  final List<String> affiliations;

  Doctor({
    required this.id,
    required this.user,
    this.cover,
    this.specialty,
    this.rating,
    this.bioEn,
    this.bioFr,
    this.bioAr,
    this.bioSp,
    this.affiliations = const [],
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final user = rawUser is Map<String, dynamic>
        ? User.fromJson(rawUser)
        : User.fromJson(json);
    return Doctor(
      id: (json['_id'] ?? user.id).toString(),
      user: user,
      cover: json['cover']?.toString(),
      specialty: json['specialty']?.toString(),
      rating: _parseNullableDouble(json['rating']),
      bioEn: json['bio_en']?.toString(),
      bioFr: json['bio_fr']?.toString(),
      bioAr: json['bio_ar']?.toString(),
      bioSp: json['bio_sp']?.toString(),
      affiliations: _parseAffiliations(json['affiliations']),
    );
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  static List<String> _parseAffiliations(dynamic value) {
    if (value is Iterable) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      if (cover != null) 'cover': cover,
      if (specialty != null) 'specialty': specialty,
      if (rating != null) 'rating': rating,
      if (bioEn != null) 'bio_en': bioEn,
      if (bioFr != null) 'bio_fr': bioFr,
      if (bioAr != null) 'bio_ar': bioAr,
      if (bioSp != null) 'bio_sp': bioSp,
      if (affiliations.isNotEmpty) 'affiliations': affiliations,
    };
  }
}

class AuthResponse {
  final User user;
  final String token;
  final Doctor? doctor;

  AuthResponse({
    required this.user,
    required this.token,
    this.doctor,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString();
    if (token == null || token.isEmpty) {
      throw const FormatException('Missing authentication token');
    }

    Doctor? doctor;
    User? user;

    final doctorJson = json['doctor'];
    if (doctorJson is Map<String, dynamic>) {
      doctor = Doctor.fromJson(doctorJson);
      user = doctor.user;
    }

    final userJson = json['user'];
    if (userJson is Map<String, dynamic>) {
      user = User.fromJson(userJson);
    }

    if (user == null) {
      if (json is Map<String, dynamic>) {
        user = User.fromJson(json);
      } else {
        throw const FormatException('Missing user data');
      }
    }

    return AuthResponse(
      user: user,
      token: token,
      doctor: doctor,
    );
  }
}

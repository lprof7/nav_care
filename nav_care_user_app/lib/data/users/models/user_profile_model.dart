class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePicture;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final bool isVerified;
  final bool isBlocked;
  final bool isDeactivated;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePicture,
    this.address,
    this.city,
    this.state,
    this.country,
    this.isVerified = false,
    this.isBlocked = false,
    this.isDeactivated = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return UserProfileModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      isVerified: json['isVerified'] == true,
      isBlocked: json['blocked'] == true,
      isDeactivated: json['deactivated'] == true,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  String? avatarUrl(String baseUrl) {
    return _resolvePath(profilePicture, baseUrl);
  }

  UserProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profilePicture,
  }) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      address: address,
      city: city,
      state: state,
      country: country,
      isVerified: isVerified,
      isBlocked: isBlocked,
      isDeactivated: isDeactivated,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String? _resolvePath(String? path, String? baseUrl) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    if (baseUrl == null || baseUrl.isEmpty) return path;
    try {
      return Uri.parse(baseUrl).resolve(path).toString();
    } catch (_) {
      return path;
    }
  }
}

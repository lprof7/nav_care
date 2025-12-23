class DoctorInvitation {
  final String id;
  final String status;
  final String hospitalId;
  final String hospitalName;
  final String? hospitalImageUrl;
  final String? invitedByName;
  final String? createdAt;

  const DoctorInvitation({
    required this.id,
    required this.status,
    required this.hospitalId,
    required this.hospitalName,
    this.hospitalImageUrl,
    this.invitedByName,
    this.createdAt,
  });

  factory DoctorInvitation.fromJson(
    Map<String, dynamic> json, {
    required String baseUrl,
  }) {
    final hospital = json['hospital'] as Map<String, dynamic>?;
    final hospitalId = (hospital?['_id'] ?? hospital?['id'] ?? '').toString();
    final hospitalName = (hospital?['name'] ?? hospital?['display_name'] ?? '')
        .toString()
        .trim();
    final imageUrl = _resolveImage(hospital?['images'], baseUrl: baseUrl);
    final invitedBy = json['invitedBy'] as Map<String, dynamic>?;

    return DoctorInvitation(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      status: json['status']?.toString() ?? 'pending',
      hospitalId: hospitalId,
      hospitalName: hospitalName.isNotEmpty ? hospitalName : 'Facility',
      hospitalImageUrl: imageUrl,
      invitedByName: invitedBy?['name']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  static String? _resolveImage(dynamic value, {required String baseUrl}) {
    if (value is Iterable) {
      for (final item in value) {
        final resolved = _resolveSingle(item, baseUrl: baseUrl);
        if (resolved != null) return resolved;
      }
    } else if (value is String) {
      return _resolveSingle(value, baseUrl: baseUrl);
    }
    return null;
  }

  static String? _resolveSingle(dynamic value, {required String baseUrl}) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    if (text.startsWith('http')) return text;
    return '$baseUrl/$text';
  }
}

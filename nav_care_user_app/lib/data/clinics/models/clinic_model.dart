class ClinicModel {
  final String id;
  final String name;
  final String? description;
  final List<String> phones;
  final List<String> images;

  const ClinicModel({
    required this.id,
    required this.name,
    this.description,
    this.phones = const [],
    this.images = const [],
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ??
          json['description_en']?.toString(),
      phones: _parsePhones(json['phone'] ?? json['phones']),
      images: _parseImages(json['images']),
    );
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
}

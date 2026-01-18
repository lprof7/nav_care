class ClinicModel {
  final String id;
  final String name;
  final String description;
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final String descriptionSp;
  final List<String> phones;
  final List<String> images;

  const ClinicModel({
    required this.id,
    required this.name,
    required this.description,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    required this.descriptionSp,
    this.phones = const [],
    this.images = const [],
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    final descriptionEn = json['description_en']?.toString() ?? '';
    final descriptionFr = json['description_fr']?.toString() ?? '';
    final descriptionAr = json['description_ar']?.toString() ?? '';
    final descriptionSp = json['description_sp']?.toString() ?? '';
    final description = _firstNonEmptyStrings([
      json['description']?.toString(),
      descriptionEn,
      descriptionFr,
      descriptionAr,
      descriptionSp,
    ]);

    return ClinicModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: description,
      descriptionEn: descriptionEn,
      descriptionFr: descriptionFr,
      descriptionAr: descriptionAr,
      descriptionSp: descriptionSp,
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

  String descriptionForLocale(String locale) {
    switch (locale) {
      case 'ar':
        return descriptionAr.isNotEmpty
            ? descriptionAr
            : _firstNonEmptyStrings([descriptionEn, descriptionFr, descriptionSp, description]);
      case 'fr':
        return descriptionFr.isNotEmpty
            ? descriptionFr
            : _firstNonEmptyStrings([descriptionEn, descriptionAr, descriptionSp, description]);
      case 'sp':
      case 'es':
        return descriptionSp.isNotEmpty
            ? descriptionSp
            : _firstNonEmptyStrings([descriptionEn, descriptionFr, descriptionAr, description]);
      default:
        return _firstNonEmptyStrings([descriptionEn, descriptionFr, descriptionAr, descriptionSp, description]);
    }
  }

  static String _firstNonEmptyStrings(List<String?> values) {
    for (final value in values) {
      if (value == null) continue;
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }
}

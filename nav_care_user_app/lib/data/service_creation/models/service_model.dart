class ServiceModel {
  final String id;
  final String nameEn;
  final String nameFr;
  final String nameAr;
  final String nameSp;
  final String description;
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final String descriptionSp;
  final String? imageUrl;

  ServiceModel({
    required this.id,
    required this.nameEn,
    required this.nameFr,
    required this.nameAr,
    required this.nameSp,
    required this.description,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    required this.descriptionSp,
    this.imageUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
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

    return ServiceModel(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          json['service_id']?.toString() ??
          '',
      nameEn: json['name_en']?.toString() ?? '',
      nameFr: json['name_fr']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameSp: json['name_sp']?.toString() ?? '',
      description: description,
      descriptionEn: descriptionEn,
      descriptionFr: descriptionFr,
      descriptionAr: descriptionAr,
      descriptionSp: descriptionSp,
      imageUrl: json['image']?.toString() ??
          json['imageUrl']?.toString() ??
          json['file']?.toString(),
    );
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

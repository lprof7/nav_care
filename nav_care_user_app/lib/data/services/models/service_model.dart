class ServiceModel {
  final String id;
  final String nameEn;
  final String nameFr;
  final String nameAr;
  final String nameSp;
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final String descriptionSp;
  final String image;

  ServiceModel({
    required this.id,
    required this.nameEn,
    required this.nameFr,
    required this.nameAr,
    required this.nameSp,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    required this.descriptionSp,
    required this.image,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id']?.toString() ?? '',
      nameEn: json['name_en'] as String? ?? '',
      nameFr: json['name_fr'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      nameSp: json['name_sp'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      descriptionFr: json['description_fr'] as String? ?? '',
      descriptionAr: json['description_ar'] as String? ?? '',
      descriptionSp: json['description_sp'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name_en': nameEn,
      'name_fr': nameFr,
      'name_ar': nameAr,
      'name_sp': nameSp,
      'description_en': descriptionEn,
      'description_fr': descriptionFr,
      'description_ar': descriptionAr,
      'description_sp': descriptionSp,
      'image': image,
    };
  }

  String nameForLanguage(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return nameAr.isNotEmpty ? nameAr : nameEn;
      case 'fr':
        return nameFr.isNotEmpty ? nameFr : nameEn;
      case 'sp':
      case 'es':
        return nameSp.isNotEmpty ? nameSp : nameEn;
      default:
        return nameEn;
    }
  }

  String descriptionForLocale(
    String languageCode, {
    String? fallback,
  }) {
    String candidate;
    switch (languageCode) {
      case 'ar':
        candidate = descriptionAr;
        break;
      case 'fr':
        candidate = descriptionFr;
        break;
      case 'sp':
      case 'es':
        candidate = descriptionSp;
        break;
      default:
        candidate = descriptionEn;
        break;
    }

    if (candidate.isNotEmpty) {
      return candidate;
    }

    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }

    if (descriptionEn.isNotEmpty) {
      return descriptionEn;
    }

    return descriptionFr.isNotEmpty
        ? descriptionFr
        : descriptionAr.isNotEmpty
            ? descriptionAr
            : descriptionSp;
  }

  String? imageUrl(String baseUrl) {
    if (image.isEmpty) return null;
    if (image.startsWith('http')) return image;
    try {
      return Uri.parse(baseUrl).resolve(image).toString();
    } catch (_) {
      return image;
    }
  }
}

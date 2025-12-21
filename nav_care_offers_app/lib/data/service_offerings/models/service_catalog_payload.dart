import 'package:image_picker/image_picker.dart';

class ServiceCatalogPayload {
  final String nameEn;
  final String? nameFr;
  final String? nameAr;
  final String? descriptionEn;
  final String? descriptionFr;
  final String? descriptionAr;
  final XFile? image;

  ServiceCatalogPayload({
    required this.nameEn,
    this.nameFr,
    this.nameAr,
    this.descriptionEn,
    this.descriptionFr,
    this.descriptionAr,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name_en': nameEn,
      if (nameFr != null && nameFr!.trim().isNotEmpty) 'name_fr': nameFr,
      if (nameAr != null && nameAr!.trim().isNotEmpty) 'name_ar': nameAr,
      if (descriptionEn != null && descriptionEn!.trim().isNotEmpty)
        'description_en': descriptionEn,
      if (descriptionFr != null && descriptionFr!.trim().isNotEmpty)
        'description_fr': descriptionFr,
      if (descriptionAr != null && descriptionAr!.trim().isNotEmpty)
        'description_ar': descriptionAr,
    };
  }
}

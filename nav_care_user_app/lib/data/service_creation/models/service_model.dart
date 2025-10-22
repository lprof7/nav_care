class ServiceModel {
  final String id;
  final String nameEn;
  final String nameFr;
  final String nameAr;
  final String description;
  final String? imageUrl;

  ServiceModel({
    required this.id,
    required this.nameEn,
    required this.nameFr,
    required this.nameAr,
    required this.description,
    this.imageUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          json['service_id']?.toString() ??
          '',
      nameEn: json['name_en']?.toString() ?? '',
      nameFr: json['name_fr']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image']?.toString() ??
          json['imageUrl']?.toString() ??
          json['file']?.toString(),
    );
  }
}

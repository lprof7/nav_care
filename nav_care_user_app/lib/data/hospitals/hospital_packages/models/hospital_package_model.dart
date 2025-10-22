class HospitalPackageModel {
  final String id;
  final String name;
  final double price;

  HospitalPackageModel({
    required this.id,
    required this.name,
    required this.price,
  });

  factory HospitalPackageModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['_id'] ?? json['package_id'];
    final priceValue = json['price'];

    return HospitalPackageModel(
      id: idValue?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: priceValue is num ? priceValue.toDouble() : double.tryParse('$priceValue') ?? 0,
    );
  }
}

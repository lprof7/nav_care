import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart';

class ClinicModel extends Equatable {
  final String id;
  final String name;
  final List<String> images;
  final String? description;
  final String? address;
  final List<String> phones;

  const ClinicModel({
    required this.id,
    required this.name,
    this.images = const [],
    this.description,
    this.address,
    this.phones = const [],
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      images: _parseImages(json['images']),
      description: json['description']?.toString() ??
          json['description_en']?.toString(),
      address: json['address']?.toString(),
      phones: _parsePhones(json['phone'] ?? json['phones']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'images': images,
      if (description != null) 'description_en': description,
      if (address != null) 'address': address,
      'phones': phones,
    };
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

  @override
  List<Object?> get props => [id, name, images, description, address, phones];
}

class ClinicListModel extends Equatable {
  final List<ClinicModel> data;
  final Pagination pagination;

  const ClinicListModel({
    required this.data,
    required this.pagination,
  });

  factory ClinicListModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] ?? json['clinics'] ?? [];
    final list = (rawList as List)
        .whereType<Map<String, dynamic>>()
        .map(ClinicModel.fromJson)
        .toList();
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};
    return ClinicListModel(
      data: list,
      pagination: Pagination.fromJson(paginationJson),
    );
  }

  @override
  List<Object?> get props => [data, pagination];
}

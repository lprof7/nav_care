import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:nav_care_user_app/core/responses/pagination.dart';

class UserAppointmentModel extends Equatable {
  final String id;
  final String status;
  final String type;
  final DateTime startTime;
  final DateTime endTime;
  final String serviceName;
  final Map<String, String> serviceNameLocalized;
  final String providerName;
  final double? price;

  const UserAppointmentModel({
    required this.id,
    required this.status,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.serviceName,
    this.serviceNameLocalized = const {},
    required this.providerName,
    this.price,
  });

  factory UserAppointmentModel.fromJson(Map<String, dynamic> json) {
    final service = _asMap(json['service']) ?? _asMap(json['service_offering']);
    final provider = _asMap(json['provider']);
    final providerUser = _asMap(provider?['user']);
    final localizedServiceName =
        _parseLocalizedNames(service?['name'] ?? json['service_name'] ?? service);
    final locale = Intl.getCurrentLocale().split('_').first;

    String readString(dynamic value) => value?.toString() ?? '';

    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      throw FormatException('Invalid date value: $value');
    }

    double? toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return UserAppointmentModel(
      id: readString(json['_id'] ?? json['id']),
      status: readString(json['status']),
      type: readString(json['type']),
      startTime: parseDate(json['start_time']),
      endTime: parseDate(json['end_time']),
      serviceName: _firstNonEmpty([
        _nameForLocale(localizedServiceName, locale),
        readString(service?['name']),
        readString(json['service_name']),
        readString(service?['name_en']),
        readString(service?['name_fr']),
        readString(service?['name_ar']),
        readString(service?['name_sp']),
      ]),
      serviceNameLocalized: Map.unmodifiable(localizedServiceName),
      providerName: readString(providerUser?['name'] ?? provider?['name']),
      price: toDouble(json['price'] ?? service?['price']),
    );
  }

  /// Returns the service name based on the current locale with sensible fallbacks.
  String serviceNameForLocale(String locale) {
    final normalized = locale.split('_').first.toLowerCase();
    String valueFor(String key) =>
        serviceNameLocalized[key]?.toString().trim() ?? '';

    return _firstNonEmpty([
      valueFor(normalized),
      if (normalized == 'es') valueFor('sp'),
      valueFor('en'),
      valueFor('fr'),
      valueFor('ar'),
      valueFor('sp'),
      serviceName,
    ]);
  }

  @override
  List<Object?> get props => [
        id,
        status,
        type,
        startTime,
        endTime,
        serviceName,
        serviceNameLocalized,
        providerName,
        price,
      ];

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static Map<String, String> _parseLocalizedNames(dynamic source) {
    final map = _asMap(source);
    if (map == null) {
      final single = source?.toString() ?? '';
      return single.trim().isNotEmpty ? {'en': single.trim()} : const {};
    }

    String read(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final names = <String, String>{
      'en': read(['en', 'name_en', 'nameEn']),
      'fr': read(['fr', 'name_fr', 'nameFr']),
      'ar': read(['ar', 'name_ar', 'nameAr']),
      'sp': read(['sp', 'es', 'name_sp', 'nameSp']),
    };

    names.removeWhere((_, value) => value.trim().isEmpty);
    return names;
  }

  static String _nameForLocale(Map<String, String> names, String locale) {
    String valueFor(String key) => names[key]?.trim() ?? '';

    switch (locale) {
      case 'ar':
        return _firstNonEmpty([
          valueFor('ar'),
          valueFor('en'),
          valueFor('fr'),
          valueFor('sp'),
        ]);
      case 'fr':
        return _firstNonEmpty([
          valueFor('fr'),
          valueFor('en'),
          valueFor('ar'),
          valueFor('sp'),
        ]);
      case 'es':
        return _firstNonEmpty([
          valueFor('sp'),
          valueFor('en'),
          valueFor('fr'),
          valueFor('ar'),
        ]);
      default:
        return _firstNonEmpty([
          valueFor('en'),
          valueFor('fr'),
          valueFor('ar'),
          valueFor('sp'),
        ]);
    }
  }

  static String _firstNonEmpty(List<String> values) {
    return values.firstWhere(
      (value) => value.trim().isNotEmpty,
      orElse: () => '',
    );
  }
}

class UserAppointmentList extends Equatable {
  final List<UserAppointmentModel> appointments;
  final PageMeta? pagination;

  const UserAppointmentList({
    required this.appointments,
    this.pagination,
  });

  UserAppointmentList copyWith({
    List<UserAppointmentModel>? appointments,
    PageMeta? pagination,
  }) {
    return UserAppointmentList(
      appointments: appointments ?? this.appointments,
      pagination: pagination ?? this.pagination,
    );
  }

  @override
  List<Object?> get props => [appointments, pagination];
}

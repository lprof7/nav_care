import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/core/responses/pagination.dart';

class UserAppointmentModel extends Equatable {
  final String id;
  final String status;
  final String type;
  final DateTime startTime;
  final DateTime endTime;
  final String serviceName;
  final String providerName;
  final double? price;

  const UserAppointmentModel({
    required this.id,
    required this.status,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.serviceName,
    required this.providerName,
    this.price,
  });

  factory UserAppointmentModel.fromJson(Map<String, dynamic> json) {
    final service = _asMap(json['service']) ?? _asMap(json['service_offering']);
    final provider = _asMap(json['provider']);
    final providerUser = _asMap(provider?['user']);

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
      serviceName: readString(service?['name'] ?? json['service_name']),
      providerName: readString(providerUser?['name'] ?? provider?['name']),
      price: toDouble(json['price'] ?? service?['price']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        type,
        startTime,
        endTime,
        serviceName,
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

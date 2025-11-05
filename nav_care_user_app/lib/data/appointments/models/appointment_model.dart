import 'package:equatable/equatable.dart';

class AppointmentModel extends Equatable {
  final String serviceOffering;
  final String type;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  const AppointmentModel({
    required this.serviceOffering,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      serviceOffering: json['service_offering'] as String,
      type: json['type'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_offering': serviceOffering,
      'type': type,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
    };
  }

  @override
  List<Object?> get props => [serviceOffering, type, startTime, endTime, status];
}
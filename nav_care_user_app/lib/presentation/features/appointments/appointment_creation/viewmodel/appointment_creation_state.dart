import 'package:equatable/equatable.dart';
import '../../../../../data/appointments/models/appointment_model.dart';

enum AppointmentCreationStatus { initial, loading, success, failure }

class AppointmentCreationState with EquatableMixin {
  final AppointmentCreationStatus status;
  final String? errorMessage;
  final AppointmentModel? createdAppointment;

  const AppointmentCreationState({
    this.status = AppointmentCreationStatus.initial,
    this.errorMessage,
    this.createdAppointment,
  });

  AppointmentCreationState copyWith({
    AppointmentCreationStatus? status,
    String? errorMessage,
    AppointmentModel? createdAppointment,
  }) {
    return AppointmentCreationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAppointment: createdAppointment ?? this.createdAppointment,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, createdAppointment];
}
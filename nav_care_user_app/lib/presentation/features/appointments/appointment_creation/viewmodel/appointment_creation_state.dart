import 'package:equatable/equatable.dart';
import '../../../../../data/appointments/models/appointment_model.dart';

enum AppointmentCreationStatus { initial, loading, success, failure }

class AppointmentCreationState with EquatableMixin {
  final AppointmentCreationStatus status;
  final String? errorMessage;
  final String? successMessage;

  const AppointmentCreationState({
    this.status = AppointmentCreationStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  AppointmentCreationState copyWith({
    AppointmentCreationStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return AppointmentCreationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage];
}

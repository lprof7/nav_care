import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/data/appointments/models/user_appointment_model.dart';

enum MyAppointmentsStatus { initial, loading, success, failure }

enum AppointmentActionStatus { idle, loading, success, failure }

class MyAppointmentsState extends Equatable {
  final MyAppointmentsStatus status;
  final UserAppointmentList? appointments;
  final Failure? error;
  final bool isProcessing;
  final AppointmentActionStatus actionStatus;
  final Failure? actionError;
  final int actionId;
  final String? filterStatus;

  const MyAppointmentsState({
    this.status = MyAppointmentsStatus.initial,
    this.appointments,
    this.error,
    this.isProcessing = false,
    this.actionStatus = AppointmentActionStatus.idle,
    this.actionError,
    this.actionId = 0,
    this.filterStatus,
  });

  MyAppointmentsState copyWith({
    MyAppointmentsStatus? status,
    UserAppointmentList? appointments,
    Failure? error,
    bool? isProcessing,
    AppointmentActionStatus? actionStatus,
    Failure? actionError,
    bool resetError = false,
    bool resetActionError = false,
    int? actionId,
    String? filterStatus,
    bool resetFilter = false,
  }) {
    return MyAppointmentsState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      error: resetError ? null : error ?? this.error,
      isProcessing: isProcessing ?? this.isProcessing,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: resetActionError ? null : actionError ?? this.actionError,
      actionId: actionId ?? this.actionId,
      filterStatus: resetFilter ? null : filterStatus ?? this.filterStatus,
    );
  }

  @override
  List<Object?> get props => [
        status,
        appointments,
        error,
        isProcessing,
        actionStatus,
        actionError,
        actionId,
        filterStatus,
      ];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/appointments/appointment_repository.dart';

import 'my_appointments_state.dart';

class MyAppointmentsCubit extends Cubit<MyAppointmentsState> {
  MyAppointmentsCubit(this._repository) : super(const MyAppointmentsState());

  final AppointmentRepository _repository;

  Future<void> fetchAppointments() async {
    emit(state.copyWith(
      status: MyAppointmentsStatus.loading,
      resetError: true,
      resetFilter: true,
    ));

    final result = await _repository.getMyAppointments();
    print("myyy appointment type: ${result.data?.appointments.first.type}");
    result.fold(
      onSuccess: (list) => emit(state.copyWith(
        status: MyAppointmentsStatus.success,
        appointments: list,
        resetError: true,
      )),
      onFailure: (failure) => emit(state.copyWith(
        status: MyAppointmentsStatus.failure,
        error: failure,
      )),
    );
  }

  Future<void> refreshAppointments() async {
    final result = await _repository.getMyAppointments();
    result.fold(
      onSuccess: (list) => emit(state.copyWith(
        status: MyAppointmentsStatus.success,
        appointments: list,
        resetError: true,
      )),
      onFailure: (failure) => emit(state.copyWith(
        status: MyAppointmentsStatus.failure,
        error: failure,
      )),
    );
  }

  Future<void> updateAppointment({
    required String appointmentId,
    required DateTime startTime,
    required DateTime endTime,
    String? status,
  }) async {
    final currentList = state.appointments;
    if (currentList == null) return;

    emit(state.copyWith(
      isProcessing: true,
      actionStatus: AppointmentActionStatus.loading,
      resetActionError: true,
    ));

    final result = await _repository.updateAppointment(
      appointmentId: appointmentId,
      startTime: startTime,
      endTime: endTime,
      status: status,
    );

    result.fold(
      onSuccess: (updatedAppointment) {
        final updatedAppointments = currentList.appointments
            .map((appointment) => appointment.id == updatedAppointment.id
                ? updatedAppointment
                : appointment)
            .toList(growable: false);

        emit(state.copyWith(
          appointments: currentList.copyWith(appointments: updatedAppointments),
          isProcessing: false,
          status: MyAppointmentsStatus.success,
          actionStatus: AppointmentActionStatus.success,
          actionId: state.actionId + 1,
        ));
      },
      onFailure: (failure) => emit(state.copyWith(
        isProcessing: false,
        actionStatus: AppointmentActionStatus.failure,
        actionError: failure,
        actionId: state.actionId + 1,
      )),
    );
  }

  void setStatusFilter(String? status) {
    emit(state.copyWith(filterStatus: status ?? 'all', resetError: false));
  }
}

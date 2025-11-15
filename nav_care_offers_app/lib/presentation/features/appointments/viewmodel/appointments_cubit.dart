import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/appointments/appointments_repository.dart';
import 'package:nav_care_offers_app/data/appointments/models/appointment_model.dart';
import 'package:nav_care_offers_app/presentation/features/appointments/viewmodel/appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  AppointmentsCubit(this._appointmentsRepository)
      : super(const AppointmentsState.initial());

  final AppointmentsRepository _appointmentsRepository;

  Future<void> getMyDoctorAppointments() async {
    emit(const AppointmentsState.loading());
    final result = await _appointmentsRepository.getMyDoctorAppointments();
    result.fold(
      onSuccess: (appointmentList) =>
          emit(AppointmentsState.success(appointmentList)),
      onFailure: (failure) => emit(AppointmentsState.failure(failure)),
    );
  }

  Future<void> updateAppointment({
    required String appointmentId,
    required DateTime startTime,
    required DateTime endTime,
    required String status,
  }) async {
    final currentList = _currentAppointments;
    if (currentList == null) return;

    emit(AppointmentsState.processing(currentList));

    final result = await _appointmentsRepository.updateAppointment(
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

        final updatedList = currentList.copyWith(
          appointments: updatedAppointments,
        );

        emit(AppointmentsState.updateSuccess(updatedList, updatedAppointment));
        emit(AppointmentsState.success(updatedList));
      },
      onFailure: (failure) {
        emit(AppointmentsState.updateFailure(currentList, failure));
        emit(AppointmentsState.success(currentList));
      },
    );
  }

  AppointmentListModel? get _currentAppointments {
    return state.maybeWhen(
      success: (list) => list,
      processing: (list) => list,
      updateSuccess: (list, _) => list,
      updateFailure: (list, __) => list,
      orElse: () => null,
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/data/appointments/models/appointment_model.dart';

part 'appointments_state.freezed.dart';

@freezed
class AppointmentsState with _$AppointmentsState {
  const factory AppointmentsState.initial() = AppointmentsInitial;
  const factory AppointmentsState.loading() = AppointmentsLoading;
  const factory AppointmentsState.success(
      AppointmentListModel appointmentList) = AppointmentsSuccess;
  const factory AppointmentsState.failure(Failure failure) =
      AppointmentsFailure;
  const factory AppointmentsState.processing(
      AppointmentListModel appointmentList) = AppointmentsProcessing;
  const factory AppointmentsState.updateSuccess(
    AppointmentListModel appointmentList,
    AppointmentModel updatedAppointment,
  ) = AppointmentsUpdateSuccess;
  const factory AppointmentsState.updateFailure(
    AppointmentListModel appointmentList,
    Failure failure,
  ) = AppointmentsUpdateFailure;
}

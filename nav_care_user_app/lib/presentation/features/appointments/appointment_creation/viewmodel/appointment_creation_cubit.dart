import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/appointments/appointment_repository.dart';
import 'package:nav_care_user_app/data/appointments/models/appointment_model.dart';

import 'appointment_creation_state.dart';

class AppointmentCreationCubit extends Cubit<AppointmentCreationState> {
  final AppointmentRepository _repository;

  AppointmentCreationCubit({required AppointmentRepository repository})
      : _repository = repository,
        super(const AppointmentCreationState());

  Future<void> createAppointment(AppointmentModel appointment) async {
    emit(state.copyWith(status: AppointmentCreationStatus.loading));
    final result = await _repository.createAppointment(appointment);

    result.fold(
      onSuccess: (message) {
        emit(state.copyWith(
          status: AppointmentCreationStatus.success,
          successMessage: message,
        ));
      },
      onFailure: (failure) {
        emit(state.copyWith(
          status: AppointmentCreationStatus.failure,
          errorMessage: failure.message,
        ));
      },
    );
  }
}

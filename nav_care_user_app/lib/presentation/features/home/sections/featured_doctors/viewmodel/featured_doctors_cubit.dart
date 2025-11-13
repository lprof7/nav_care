import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/doctors/doctors_repository.dart';
import '../../../../../../data/doctors/models/doctor_model.dart';
import 'featured_doctors_state.dart';

class FeaturedDoctorsCubit extends Cubit<FeaturedDoctorsState> {
  FeaturedDoctorsCubit({required DoctorsRepository repository})
      : _repository = repository,
        super(const FeaturedDoctorsState());

  final DoctorsRepository _repository;

  Future<void> loadDoctors() async {
    emit(state.copyWith(status: FeaturedDoctorsStatus.loading));

    try {
      List<DoctorModel> doctors;
        doctors = await _repository.getFeaturedDoctors(limit: 6);

      emit(
        state.copyWith(
          status: FeaturedDoctorsStatus.loaded,
          doctors: doctors,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FeaturedDoctorsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}

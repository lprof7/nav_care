import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/hospitals/hospitals_repository.dart';
import 'featured_clinics_state.dart';

class FeaturedClinicsCubit extends Cubit<FeaturedClinicsState> {
  FeaturedClinicsCubit({required HospitalsRepository repository})
      : _repository = repository,
        super(const FeaturedClinicsState());

  final HospitalsRepository _repository;

  Future<void> loadClinics() async {
    emit(state.copyWith(status: FeaturedClinicsStatus.loading));

    try {
      final clinics =
          await _repository.getNavcareFeaturedClinics(limit: 6);

      emit(
        state.copyWith(
          status: FeaturedClinicsStatus.loaded,
          clinics: clinics,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FeaturedClinicsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/hospitals/hospitals_repository.dart';
import 'featured_hospitals_state.dart';

class FeaturedHospitalsCubit extends Cubit<FeaturedHospitalsState> {
  FeaturedHospitalsCubit({required HospitalsRepository repository})
      : _repository = repository,
        super(const FeaturedHospitalsState());

  final HospitalsRepository _repository;

  Future<void> loadHospitals() async {
    emit(state.copyWith(status: FeaturedHospitalsStatus.loading));

    try {
      final hospitals =
          await _repository.getNavcareFeaturedHospitals(limit: 5);

      emit(
        state.copyWith(
          status: FeaturedHospitalsStatus.loaded,
          hospitals: hospitals,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FeaturedHospitalsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}

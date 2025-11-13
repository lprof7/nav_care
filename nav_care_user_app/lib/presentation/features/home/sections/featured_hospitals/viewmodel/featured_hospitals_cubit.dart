import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/hospitals/hospitals_repository.dart';
import '../../../../../../data/hospitals/models/hospital_model.dart';
import 'featured_hospitals_state.dart';

class FeaturedHospitalsCubit extends Cubit<FeaturedHospitalsState> {
  FeaturedHospitalsCubit({required HospitalsRepository repository})
      : _repository = repository,
        super(const FeaturedHospitalsState());

  final HospitalsRepository _repository;

  Future<void> loadHospitals() async {
    emit(state.copyWith(status: FeaturedHospitalsStatus.loading));

    try {
      List<HospitalModel> hospitals;
        hospitals = await _repository.getFeaturedHospitals(limit: 5);

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

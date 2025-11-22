import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/hospitals/hospitals_repository.dart';
import 'hospitals_choice_state.dart';

class HospitalsChoiceCubit extends Cubit<HospitalsChoiceState> {
  HospitalsChoiceCubit({required HospitalsRepository repository})
      : _repository = repository,
        super(const HospitalsChoiceState());

  final HospitalsRepository _repository;

  Future<void> loadHospitals() async {
    emit(state.copyWith(status: HospitalsChoiceStatus.loading));
    try {
      final hospitals = await _repository.getNavcareHospitalsChoice(limit: 6);

      emit(
        state.copyWith(
          status: HospitalsChoiceStatus.loaded,
          hospitals: hospitals,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HospitalsChoiceStatus.failure,
          message: null,
        ),
      );
    }
  }
}

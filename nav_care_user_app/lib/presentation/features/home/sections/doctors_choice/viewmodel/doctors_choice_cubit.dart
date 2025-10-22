import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/doctors/doctors_repository.dart';
import 'doctors_choice_state.dart';

class DoctorsChoiceCubit extends Cubit<DoctorsChoiceState> {
  DoctorsChoiceCubit({required DoctorsRepository repository})
      : _repository = repository,
        super(const DoctorsChoiceState());

  final DoctorsRepository _repository;

  // (اختياري) توحيد الانبعاث الآمن
  void _safeEmit(DoctorsChoiceState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadDoctors() async {
    if (isClosed) return; // حماية مبكرة
    _safeEmit(state.copyWith(status: DoctorsChoiceStatus.loading));

    try {
      final doctors = await _repository.getNavcareDoctorsChoice(limit: 6);

      if (isClosed) return; // حماية بعد await
      _safeEmit(
        state.copyWith(
          status: DoctorsChoiceStatus.loaded,
          doctors: doctors,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      _safeEmit(
        state.copyWith(
          status: DoctorsChoiceStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}

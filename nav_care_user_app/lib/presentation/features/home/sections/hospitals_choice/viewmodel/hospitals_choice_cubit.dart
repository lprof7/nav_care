import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/hospitals/hospitals_repository.dart';
import 'hospitals_choice_state.dart';

class HospitalsChoiceCubit extends Cubit<HospitalsChoiceState> {
  HospitalsChoiceCubit({required HospitalsRepository repository})
      : _repository = repository,
        super(const HospitalsChoiceState());

  final HospitalsRepository _repository;
  int _currentLimit = 6;

  Future<void> loadHospitals({int limit = 6}) async {
    _currentLimit = limit;
    emit(
      state.copyWith(
        status: HospitalsChoiceStatus.loading,
        message: null,
        page: 1,
        hasNextPage: true,
      ),
    );
    try {
      final paged =
          await _repository.getNavcareHospitalsChoice(page: 1, limit: _currentLimit);

      emit(
        state.copyWith(
          status: HospitalsChoiceStatus.loaded,
          hospitals: paged.items,
          page: 1,
          hasNextPage: paged.meta?.hasNextPage ?? false,
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

  Future<void> loadMoreHospitals() async {
    if (!state.hasNextPage || state.status == HospitalsChoiceStatus.loading) {
      return;
    }

    emit(state.copyWith(status: HospitalsChoiceStatus.loading));

    try {
      final nextPage = state.page + 1;
      final paged = await _repository.getNavcareHospitalsChoice(
        page: nextPage,
        limit: _currentLimit,
      );

      emit(
        state.copyWith(
          status: HospitalsChoiceStatus.loaded,
          hospitals: List.of(state.hospitals)..addAll(paged.items),
          page: nextPage,
          hasNextPage: paged.meta?.hasNextPage ?? false,
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

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/hospitals/hospitals_repository.dart';
import 'recent_hospitals_state.dart';

class RecentHospitalsCubit extends Cubit<RecentHospitalsState> {
  RecentHospitalsCubit({required HospitalsRepository repository})
      : _repository = repository,
        super(const RecentHospitalsState());

  final HospitalsRepository _repository;
  int _currentLimit = 6;

  Future<void> loadHospitals({int limit = 6}) async {
    _currentLimit = limit;
    emit(
      state.copyWith(
        status: RecentHospitalsStatus.loading,
        message: null,
        page: 1,
        hasNextPage: true,
      ),
    );

    try {
      final paged =
          await _repository.getRecentHospitals(page: 1, limit: _currentLimit);
      emit(
        state.copyWith(
          status: RecentHospitalsStatus.loaded,
          hospitals: paged.items,
          page: 1,
          hasNextPage: paged.meta?.hasNextPage ?? false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RecentHospitalsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> loadMoreHospitals() async {
    if (!state.hasNextPage || state.status == RecentHospitalsStatus.loading) {
      return;
    }

    emit(state.copyWith(status: RecentHospitalsStatus.loading));

    try {
      final nextPage = state.page + 1;
      final paged = await _repository.getRecentHospitals(
        page: nextPage,
        limit: _currentLimit,
      );

      emit(
        state.copyWith(
          status: RecentHospitalsStatus.loaded,
          hospitals: List.of(state.hospitals)..addAll(paged.items),
          page: nextPage,
          hasNextPage: paged.meta?.hasNextPage ?? false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RecentHospitalsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}

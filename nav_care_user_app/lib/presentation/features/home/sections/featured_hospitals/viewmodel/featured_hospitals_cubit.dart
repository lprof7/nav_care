import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/hospitals/hospitals_repository.dart';
import 'featured_hospitals_state.dart';

class FeaturedHospitalsCubit extends Cubit<FeaturedHospitalsState> {
  FeaturedHospitalsCubit({required HospitalsRepository repository})
      : _repository = repository,
        super(const FeaturedHospitalsState());

  final HospitalsRepository _repository;
  int _currentLimit = 5;

  Future<void> loadHospitals({int limit = 5}) async {
    emit(
      state.copyWith(
        status: FeaturedHospitalsStatus.loading,
        message: null,
        page: 1,
        hasNextPage: true,
      ),
    );
    _currentLimit = limit;

    try {
      final paged =
          await _repository.getFeaturedHospitals(page: 1, limit: _currentLimit);

      emit(
        state.copyWith(
          status: FeaturedHospitalsStatus.loaded,
          hospitals: paged.items,
          page: 1,
          hasNextPage: paged.meta?.hasNextPage ?? false,
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

  Future<void> loadMoreHospitals() async {
    if (!state.hasNextPage || state.status == FeaturedHospitalsStatus.loading) {
      return;
    }

    emit(state.copyWith(status: FeaturedHospitalsStatus.loading));

    try {
      final nextPage = state.page + 1;
      final paged = await _repository.getFeaturedHospitals(
        page: nextPage,
        limit: _currentLimit,
      );

      emit(
        state.copyWith(
          status: FeaturedHospitalsStatus.loaded,
          hospitals: List.of(state.hospitals)..addAll(paged.items),
          page: nextPage,
          hasNextPage: paged.meta?.hasNextPage ?? false,
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

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/doctors/doctors_repository.dart';
import 'doctors_choice_state.dart';

class DoctorsChoiceCubit extends Cubit<DoctorsChoiceState> {
  DoctorsChoiceCubit({required DoctorsRepository repository})
      : _repository = repository,
        super(const DoctorsChoiceState());

  final DoctorsRepository _repository;
  int _currentLimit = 6;

  void _safeEmit(DoctorsChoiceState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadDoctors({int limit = 6}) async {
    if (isClosed) return;
    _currentLimit = limit;
    _safeEmit(
      state.copyWith(
        status: DoctorsChoiceStatus.loading,
        message: null,
        page: 1,
        hasNextPage: true,
      ),
    );

    try {
      final paged =
          await _repository.getNavcareDoctorsChoice(page: 1, limit: _currentLimit);
      if (isClosed) return;
      _safeEmit(
        state.copyWith(
          status: DoctorsChoiceStatus.loaded,
          doctors: paged.items,
          page: 1,
          hasNextPage: paged.meta?.hasNextPage ?? false,
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

  Future<void> loadMoreDoctors() async {
    if (isClosed) return;
    if (!state.hasNextPage || state.status == DoctorsChoiceStatus.loading) {
      return;
    }

    _safeEmit(state.copyWith(status: DoctorsChoiceStatus.loading));

    try {
      final nextPage = state.page + 1;
      final paged = await _repository.getNavcareDoctorsChoice(
        page: nextPage,
        limit: _currentLimit,
      );
      if (isClosed) return;
      _safeEmit(
        state.copyWith(
          status: DoctorsChoiceStatus.loaded,
          doctors: List.of(state.doctors)..addAll(paged.items),
          page: nextPage,
          hasNextPage: paged.meta?.hasNextPage ?? false,
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

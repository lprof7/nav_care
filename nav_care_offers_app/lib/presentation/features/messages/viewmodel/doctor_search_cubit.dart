import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/doctors/doctors_repository.dart';

import 'doctor_search_state.dart';

class DoctorSearchCubit extends Cubit<DoctorSearchState> {
  DoctorSearchCubit({required DoctorsRepository repository})
      : _repository = repository,
        super(const DoctorSearchState());

  final DoctorsRepository _repository;
  Timer? _debounce;
  static const Duration _debounceDuration = Duration(milliseconds: 350);
  static const int _pageSize = 20;

  void updateQuery(String query) {
    final trimmed = query.trim();
    _debounce?.cancel();
    if (trimmed.isEmpty) {
      emit(const DoctorSearchState());
      return;
    }
    emit(state.copyWith(query: trimmed));
    _debounce = Timer(_debounceDuration, () {
      search(trimmed);
    });
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    emit(state.copyWith(
      status: DoctorSearchStatus.loading,
      query: trimmed,
      doctors: const [],
      pagination: null,
      errorMessage: null,
      isLoadingMore: false,
    ));
    try {
      final result = await _repository.searchDoctorsCollection(
        query: trimmed,
        page: 1,
        limit: _pageSize,
      );
      emit(state.copyWith(
        status: DoctorSearchStatus.success,
        doctors: result.items,
        pagination: result.meta,
        errorMessage: null,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: DoctorSearchStatus.failure,
        errorMessage: _normalizeError(error),
      ));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    if (state.status != DoctorSearchStatus.success) return;
    final nextPage = (state.pagination?.page ?? 1) + 1;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final result = await _repository.searchDoctorsCollection(
        query: state.query,
        page: nextPage,
        limit: _pageSize,
      );
      emit(state.copyWith(
        doctors: [...state.doctors, ...result.items],
        pagination: result.meta ?? state.pagination,
        isLoadingMore: false,
        errorMessage: null,
      ));
    } catch (error) {
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: _normalizeError(error),
      ));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  String _normalizeError(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '').trim();
  }
}

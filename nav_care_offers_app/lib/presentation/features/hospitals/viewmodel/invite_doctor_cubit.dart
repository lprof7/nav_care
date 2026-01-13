import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/data/doctors/doctors_repository.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';

class InviteDoctorState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final List<DoctorModel> doctors;
  final String query;
  final Failure? failure;
  final int page;
  final bool hasNext;

  const InviteDoctorState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.doctors = const [],
    this.query = '',
    this.failure,
    this.page = 1,
    this.hasNext = true,
  });

  List<DoctorModel> get filteredDoctors {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return doctors;
    return doctors
        .where((doctor) {
          final name = doctor.displayName.toLowerCase();
          final email = doctor.email?.toLowerCase() ?? '';
          return name.contains(term) || email.contains(term);
        })
        .toList(growable: false);
  }

  InviteDoctorState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<DoctorModel>? doctors,
    String? query,
    Failure? failure,
    int? page,
    bool? hasNext,
    bool clearFailure = false,
  }) {
    return InviteDoctorState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      doctors: doctors ?? this.doctors,
      query: query ?? this.query,
      failure: clearFailure ? null : failure ?? this.failure,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingMore,
        doctors,
        query,
        failure,
        page,
        hasNext,
      ];
}

class InviteDoctorCubit extends Cubit<InviteDoctorState> {
  final DoctorsRepository _repository;
  static const int _pageSize = 30;

  InviteDoctorCubit(this._repository) : super(const InviteDoctorState());

  Future<void> load({bool refresh = true}) async {
    if (state.isLoading || state.isLoadingMore) return;
    if (!refresh && !state.hasNext) return;

    final nextPage = (refresh || state.doctors.isEmpty) ? 1 : state.page + 1;
    emit(state.copyWith(
      isLoading: refresh || state.doctors.isEmpty,
      isLoadingMore: !refresh && state.doctors.isNotEmpty,
      clearFailure: true,
    ));
    final result = await _repository.listDoctors(
      page: nextPage,
      limit: _pageSize,
    );
    result.fold(
      onFailure: (failure) => emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          failure: failure,
        ),
      ),
      onSuccess: (data) {
        final merged = refresh || state.doctors.isEmpty
            ? data.data
            : [
                ...state.doctors,
                ...data.data.where(
                  (item) =>
                      state.doctors.indexWhere((d) => d.id == item.id) < 0,
                ),
              ];
        final pagination = data.pagination;
        final hasNext = pagination.page < pagination.pages;
        emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            doctors: merged,
            page: pagination.page,
            hasNext: hasNext,
            clearFailure: true,
          ),
        );
      },
    );
  }

  Future<void> loadMore() => load(refresh: false);

  void updateQuery(String value) {
    emit(state.copyWith(query: value));
  }
}

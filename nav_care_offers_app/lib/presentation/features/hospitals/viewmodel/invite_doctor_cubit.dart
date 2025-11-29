import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/data/doctors/doctors_repository.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';

class InviteDoctorState extends Equatable {
  final bool isLoading;
  final List<DoctorModel> doctors;
  final String query;
  final Failure? failure;

  const InviteDoctorState({
    this.isLoading = false,
    this.doctors = const [],
    this.query = '',
    this.failure,
  });

  List<DoctorModel> get filteredDoctors {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return doctors;
    return doctors
        .where((doctor) {
          final name = doctor.displayName.toLowerCase();
          final id = doctor.id.toLowerCase();
          return name.contains(term) || id.contains(term);
        })
        .toList(growable: false);
  }

  InviteDoctorState copyWith({
    bool? isLoading,
    List<DoctorModel>? doctors,
    String? query,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return InviteDoctorState(
      isLoading: isLoading ?? this.isLoading,
      doctors: doctors ?? this.doctors,
      query: query ?? this.query,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [isLoading, doctors, query, failure];
}

class InviteDoctorCubit extends Cubit<InviteDoctorState> {
  final DoctorsRepository _repository;

  InviteDoctorCubit(this._repository) : super(const InviteDoctorState());

  Future<void> load({int page = 1, int limit = 30}) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    final result = await _repository.listDoctors(page: page, limit: limit);
    result.fold(
      onFailure: (failure) =>
          emit(state.copyWith(isLoading: false, failure: failure)),
      onSuccess: (data) => emit(
        state.copyWith(
          isLoading: false,
          doctors: data.data,
          clearFailure: true,
        ),
      ),
    );
  }

  void updateQuery(String value) {
    emit(state.copyWith(query: value));
  }
}

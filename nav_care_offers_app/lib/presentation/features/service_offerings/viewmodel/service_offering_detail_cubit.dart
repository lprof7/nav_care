import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/service_offerings/service_offerings_repository.dart';

class ServiceOfferingDetailCubit extends Cubit<ServiceOfferingDetailState> {
  ServiceOfferingDetailCubit(
    this._repository, {
    required String offeringId,
    ServiceOffering? initial,
    this.useHospitalToken = true,
  }) : super(ServiceOfferingDetailState(
          offeringId: offeringId,
          offering: initial,
        ));

  final ServiceOfferingsRepository _repository;
  final bool useHospitalToken;

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    final result = await _repository.fetchOfferingById(
      state.offeringId,
      useHospitalToken: useHospitalToken,
    );
    result.fold(
      onFailure: (failure) =>
          emit(state.copyWith(isLoading: false, failure: failure)),
      onSuccess: (offering) => emit(
        state.copyWith(
          isLoading: false,
          offering: offering,
          clearFailure: true,
        ),
      ),
    );
  }

  void replace(ServiceOffering offering) {
    if (offering.id == state.offeringId) {
      emit(state.copyWith(offering: offering));
    }
  }

  Future<void> deleteOffering() async {
    if (state.isDeleting) return;
    emit(state.copyWith(isDeleting: true, clearFailure: true));
    final result = await _repository.deleteOffering(
      state.offeringId,
      useHospitalToken: useHospitalToken,
    );
    result.fold(
      onFailure: (failure) => emit(
        state.copyWith(isDeleting: false, failure: failure),
      ),
      onSuccess: (_) => emit(
        state.copyWith(
          isDeleting: false,
          isDeleted: true,
          offering: null,
          clearFailure: true,
        ),
      ),
    );
  }
}

class ServiceOfferingDetailState extends Equatable {
  final String offeringId;
  final ServiceOffering? offering;
  final bool isLoading;
  final bool isDeleting;
  final bool isDeleted;
  final Failure? failure;

  const ServiceOfferingDetailState({
    required this.offeringId,
    this.offering,
    this.isLoading = false,
    this.isDeleting = false,
    this.isDeleted = false,
    this.failure,
  });

  ServiceOfferingDetailState copyWith({
    ServiceOffering? offering,
    bool? isLoading,
    bool? isDeleting,
    bool? isDeleted,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ServiceOfferingDetailState(
      offeringId: offeringId,
      offering: offering ?? this.offering,
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      isDeleted: isDeleted ?? this.isDeleted,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props =>
      [offeringId, offering, isLoading, isDeleting, isDeleted, failure];
}

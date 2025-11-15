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
  }) : super(ServiceOfferingDetailState(
          offeringId: offeringId,
          offering: initial,
        ));

  final ServiceOfferingsRepository _repository;

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    final result = await _repository.fetchOfferingById(state.offeringId);
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
}

class ServiceOfferingDetailState extends Equatable {
  final String offeringId;
  final ServiceOffering? offering;
  final bool isLoading;
  final Failure? failure;

  const ServiceOfferingDetailState({
    required this.offeringId,
    this.offering,
    this.isLoading = false,
    this.failure,
  });

  ServiceOfferingDetailState copyWith({
    ServiceOffering? offering,
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ServiceOfferingDetailState(
      offeringId: offeringId,
      offering: offering ?? this.offering,
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [offeringId, offering, isLoading, failure];
}

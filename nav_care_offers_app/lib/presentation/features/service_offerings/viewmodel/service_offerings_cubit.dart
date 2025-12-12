import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/service_offerings/service_offerings_repository.dart';

class ServiceOfferingsCubit extends Cubit<ServiceOfferingsState> {
  ServiceOfferingsCubit(
    this._repository, {
    this.useHospitalToken = true,
  }) : super(const ServiceOfferingsState());

  final ServiceOfferingsRepository _repository;
  final bool useHospitalToken;

  Future<void> loadOfferings({bool refresh = false}) async {
    if (state.isLoading) return;
    emit(state.copyWith(
      isLoading: true,
      clearFailure: true,
      isRefreshing: refresh,
    ));

    final result = await _repository.fetchMyOfferings(
      useHospitalToken: useHospitalToken,
    );
    result.fold(
      onFailure: (failure) => emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        failure: failure,
      )),
      onSuccess: (data) => emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        clearFailure: true,
        offerings: data.offerings,
      )),
    );
  }

  void updateOffering(ServiceOffering offering) {
    final updated = List<ServiceOffering>.from(state.offerings);
    final index = updated.indexWhere((element) => element.id == offering.id);
    if (index >= 0) {
      updated[index] = offering;
      emit(state.copyWith(offerings: updated));
    } else {
      updated.insert(0, offering);
      emit(state.copyWith(offerings: updated));
    }
  }

  void removeOffering(String offeringId) {
    final updated =
        state.offerings.where((element) => element.id != offeringId).toList();
    emit(state.copyWith(offerings: updated));
  }
}

class ServiceOfferingsState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final List<ServiceOffering> offerings;
  final Failure? failure;

  const ServiceOfferingsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.offerings = const [],
    this.failure,
  });

  bool get hasError => failure != null;
  bool get isEmpty => offerings.isEmpty && !isLoading && failure == null;

  ServiceOfferingsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<ServiceOffering>? offerings,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ServiceOfferingsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      offerings: offerings ?? this.offerings,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [isLoading, isRefreshing, offerings, failure];
}

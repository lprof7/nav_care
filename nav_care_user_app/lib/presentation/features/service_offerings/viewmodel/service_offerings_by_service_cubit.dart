import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nav_care_user_app/data/services/services_repository.dart';

import 'service_offerings_by_service_state.dart';

class ServiceOfferingsByServiceCubit
    extends Cubit<ServiceOfferingsByServiceState> {
  ServiceOfferingsByServiceCubit(this._repository)
      : super(const ServiceOfferingsByServiceState());

  final ServicesRepository _repository;
  String? _serviceId;

  Future<void> loadOfferings(String serviceId) async {
    _serviceId = serviceId;
    emit(
      state.copyWith(
        status: ServiceOfferingsByServiceStatus.loading,
        offerings: const [],
        message: null,
        page: 1,
        hasNextPage: true,
        isLoadingMore: false,
      ),
    );
    try {
      final paged = await _repository.getServiceOfferings(
        serviceId: serviceId,
        limit: 20,
        page: 1,
      );
      emit(
        state.copyWith(
          status: ServiceOfferingsByServiceStatus.success,
          offerings: paged.items,
          message: null,
          page: 1,
          hasNextPage: paged.meta?.hasNextPage ?? false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ServiceOfferingsByServiceStatus.failure,
          message: 'services.offerings.error'.tr(),
        ),
      );
    }
  }

  Future<void> loadMoreOfferings() async {
    if (state.isLoadingMore || !state.hasNextPage) return;
    final serviceId = _serviceId;
    if (serviceId == null || serviceId.isEmpty) return;

    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.page + 1;
      final paged = await _repository.getServiceOfferings(
        serviceId: serviceId,
        limit: 20,
        page: nextPage,
      );
      emit(
        state.copyWith(
          status: ServiceOfferingsByServiceStatus.success,
          offerings: List.of(state.offerings)..addAll(paged.items),
          page: nextPage,
          hasNextPage: paged.meta?.hasNextPage ?? false,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ServiceOfferingsByServiceStatus.success,
          isLoadingMore: false,
          message: 'services.offerings.error'.tr(),
        ),
      );
    }
  }
}

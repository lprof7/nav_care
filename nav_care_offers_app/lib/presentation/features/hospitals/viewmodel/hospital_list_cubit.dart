import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospitals_result.dart';
import 'package:nav_care_offers_app/data/services/models/pagination.dart';

part 'hospital_list_state.dart';

class HospitalListCubit extends Cubit<HospitalListState> {
  HospitalListCubit(this._repository) : super(HospitalListInitial());

  final HospitalsRepository _repository;

  Future<void> fetchHospitals({int? page, int? limit}) async {
    emit(HospitalListLoading());
    final result = await _repository.fetchHospitals(page: page, limit: limit);
    result.fold(
      onFailure: (failure) => emit(
        HospitalListFailure(message: _messageForFailure(failure)),
      ),
      onSuccess: (data) => _emitData(data),
    );
  }

  void refreshFromCache() {
    final cached = _repository.cachedHospitals;
    final pagination = _repository.lastPagination;
    if (cached.isEmpty) {
      emit(const HospitalListEmpty(messageKey: 'hospitals.list.empty'));
    } else {
      emit(HospitalListSuccess(
        hospitals: cached,
        pagination: pagination,
      ));
    }
  }

  void upsertHospital(Hospital hospital) {
    final current = state;
    if (current is HospitalListSuccess) {
      final list = List<Hospital>.from(current.hospitals);
      final index = list.indexWhere((element) => element.id == hospital.id);
      if (index >= 0) {
        list[index] = hospital;
      } else {
        list.insert(0, hospital);
      }
      emit(current.copyWith(hospitals: list));
    } else {
      refreshFromCache();
    }
  }

  void removeHospital(String hospitalId) {
    final current = state;
    if (current is HospitalListSuccess) {
      final list =
          current.hospitals.where((element) => element.id != hospitalId).toList();
      if (list.isEmpty) {
        emit(const HospitalListEmpty(messageKey: 'hospitals.list.empty'));
      } else {
        emit(current.copyWith(hospitals: list));
      }
    } else {
      refreshFromCache();
    }
  }

  Hospital? findById(String id) => _repository.findById(id);

  void _emitData(HospitalsResult result) {
    if (result.hospitals.isEmpty) {
      emit(const HospitalListEmpty(messageKey: 'hospitals.list.empty'));
    } else {
      emit(HospitalListSuccess(
        hospitals: result.hospitals,
        pagination: result.pagination,
      ));
    }
  }

  String _messageForFailure(Failure failure) {
    if (failure.message.isNotEmpty) {
      return failure.message;
    }
    switch (failure.type) {
      case FailureType.network:
        return 'hospitals.list.error_network';
      case FailureType.timeout:
        return 'hospitals.list.error_timeout';
      case FailureType.unauthorized:
        return 'hospitals.list.error_unauthorized';
      default:
        return 'hospitals.list.error_generic';
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/service_creation/models/service_creation_result.dart';
import 'package:nav_care_user_app/data/service_creation/service_creation_repository.dart';

abstract class ServiceCreationState {}

class ServiceCreationInitial extends ServiceCreationState {}

class ServiceCreationLoading extends ServiceCreationState {}

class ServiceCreationSuccess extends ServiceCreationState {
  final ServiceCreationResult result;
  ServiceCreationSuccess(this.result);
}

class ServiceCreationFailure extends ServiceCreationState {
  final String message;
  ServiceCreationFailure(this.message);
}

class ServiceCreationCubit extends Cubit<ServiceCreationState> {
  final ServiceCreationRepository _repository;

  ServiceCreationCubit(this._repository) : super(ServiceCreationInitial());

  Future<void> createService(Map<String, dynamic> body) async {
    emit(ServiceCreationLoading());
    final result = await _repository.createService(body);
    result.fold(
      onFailure: (failure) => emit(ServiceCreationFailure(failure.message)),
      onSuccess: (data) => emit(ServiceCreationSuccess(data)),
    );
  }
}

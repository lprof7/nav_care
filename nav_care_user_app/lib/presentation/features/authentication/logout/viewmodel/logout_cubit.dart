import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/authentication/logout/logout_repository.dart';

abstract class LogoutState {}

class LogoutInitial extends LogoutState {}

class LogoutInProgress extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutFailure extends LogoutState {
  final String message;
  LogoutFailure(this.message);
}

class LogoutCubit extends Cubit<LogoutState> {
  final LogoutRepository _logoutRepository;

  LogoutCubit(this._logoutRepository) : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutInProgress());
    try {
      await _logoutRepository.logout();
      emit(LogoutSuccess());
    } catch (error) {
      emit(LogoutFailure(error.toString()));
      emit(LogoutInitial());
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';

abstract class LogoutState {}

class LogoutInitial extends LogoutState {}

class LogoutInProgress extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutFailure extends LogoutState {
  final String message;
  LogoutFailure(this.message);
}

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit(this._authCubit) : super(LogoutInitial());

  final AuthCubit _authCubit;

  Future<void> logout() async {
    emit(LogoutInProgress());
    try {
      await _authCubit.logout();
      emit(LogoutSuccess());
    } catch (error) {
      emit(LogoutFailure(error.toString()));
      emit(LogoutInitial());
    }
  }
}

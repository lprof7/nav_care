import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/authentication/reset_password/reset_password_repository.dart';

import 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit(this._repository) : super(const ResetPasswordState());

  final ResetPasswordRepository _repository;
  Timer? _timer;

  Future<void> sendResetCode(String email) async {
    final trimmed = email.trim();
    emit(
      state.copyWith(
        email: trimmed,
        sendCodeStatus: ResetRequestStatus.loading,
        verifyCodeStatus: ResetRequestStatus.idle,
        resetStatus: ResetRequestStatus.idle,
        verifiedCode: '',
        clearError: true,
      ),
    );
    try {
      await _repository.sendResetCode(trimmed);
      emit(
        state.copyWith(
          sendCodeStatus: ResetRequestStatus.success,
          secondsRemaining: 60,
        ),
      );
      _startTimer();
    } catch (e) {
      emit(
        state.copyWith(
          sendCodeStatus: ResetRequestStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> verifyResetCode(String code) async {
    if (state.email.isEmpty) return;
    emit(
      state.copyWith(
        verifyCodeStatus: ResetRequestStatus.loading,
        clearError: true,
      ),
    );
    try {
      await _repository.verifyResetCode(email: state.email, resetCode: code);
      _timer?.cancel();
      emit(
        state.copyWith(
          verifyCodeStatus: ResetRequestStatus.success,
          verifiedCode: code,
          secondsRemaining: state.secondsRemaining,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          verifyCodeStatus: ResetRequestStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> resetPassword(String newPassword) async {
    if (state.email.isEmpty || state.verifiedCode.isEmpty) return;
    emit(
      state.copyWith(
        resetStatus: ResetRequestStatus.loading,
        clearError: true,
      ),
    );
    try {
      await _repository.resetPassword(
        email: state.email,
        resetCode: state.verifiedCode,
        newPassword: newPassword,
      );
      emit(state.copyWith(resetStatus: ResetRequestStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          resetStatus: ResetRequestStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void restartTimer() {
    emit(state.copyWith(secondsRemaining: 60));
    _startTimer();
  }

  void resetFlow() {
    _timer?.cancel();
    emit(const ResetPasswordState());
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.secondsRemaining - 1;
      if (next <= 0) {
        timer.cancel();
        emit(state.copyWith(secondsRemaining: 0));
      } else {
        emit(state.copyWith(secondsRemaining: next));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

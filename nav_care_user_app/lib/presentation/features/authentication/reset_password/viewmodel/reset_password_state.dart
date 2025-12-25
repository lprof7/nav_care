import 'package:equatable/equatable.dart';

enum ResetRequestStatus { idle, loading, success, failure }

class ResetPasswordState extends Equatable {
  const ResetPasswordState({
    this.email = '',
    this.verifiedCode = '',
    this.sendCodeStatus = ResetRequestStatus.idle,
    this.verifyCodeStatus = ResetRequestStatus.idle,
    this.resetStatus = ResetRequestStatus.idle,
    this.secondsRemaining = 0,
    this.errorMessage,
    this.successMessage,
  });

  final String email;
  final String verifiedCode;
  final ResetRequestStatus sendCodeStatus;
  final ResetRequestStatus verifyCodeStatus;
  final ResetRequestStatus resetStatus;
  final int secondsRemaining;
  final String? errorMessage;
  final String? successMessage;

  bool get isCodeVerified =>
      verifyCodeStatus == ResetRequestStatus.success && verifiedCode.isNotEmpty;

  ResetPasswordState copyWith({
    String? email,
    String? verifiedCode,
    ResetRequestStatus? sendCodeStatus,
    ResetRequestStatus? verifyCodeStatus,
    ResetRequestStatus? resetStatus,
    int? secondsRemaining,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ResetPasswordState(
      email: email ?? this.email,
      verifiedCode: verifiedCode ?? this.verifiedCode,
      sendCodeStatus: sendCodeStatus ?? this.sendCodeStatus,
      verifyCodeStatus: verifyCodeStatus ?? this.verifyCodeStatus,
      resetStatus: resetStatus ?? this.resetStatus,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        email,
        verifiedCode,
        sendCodeStatus,
        verifyCodeStatus,
        resetStatus,
        secondsRemaining,
        errorMessage,
        successMessage,
      ];
}

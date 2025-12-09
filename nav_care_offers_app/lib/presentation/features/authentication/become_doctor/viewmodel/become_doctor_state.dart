part of 'become_doctor_cubit.dart';

class BecomeDoctorState extends Equatable {
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final Doctor? doctor;

  const BecomeDoctorState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.doctor,
  });

  BecomeDoctorState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    Doctor? doctor,
    bool clearError = false,
  }) {
    return BecomeDoctorState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      doctor: doctor ?? this.doctor,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, isSuccess, errorMessage, doctor];
}

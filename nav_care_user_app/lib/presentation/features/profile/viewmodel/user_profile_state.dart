import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/data/users/models/user_profile_model.dart';

enum ProfileLoadStatus { idle, loading, success, failure }
enum ProfileUpdateStatus { idle, updating, success, failure }
enum PasswordUpdateStatus { idle, updating, success, failure }
enum PasswordResetStatus { idle, sending, success, failure }

class UserProfileState extends Equatable {
  final UserProfileModel? profile;
  final ProfileLoadStatus loadStatus;
  final ProfileUpdateStatus updateStatus;
  final PasswordUpdateStatus passwordStatus;
  final PasswordResetStatus resetStatus;
  final String? errorMessage;

  const UserProfileState({
    this.profile,
    this.loadStatus = ProfileLoadStatus.idle,
    this.updateStatus = ProfileUpdateStatus.idle,
    this.passwordStatus = PasswordUpdateStatus.idle,
    this.resetStatus = PasswordResetStatus.idle,
    this.errorMessage,
  });

  UserProfileState copyWith({
    UserProfileModel? profile,
    bool clearProfile = false,
    ProfileLoadStatus? loadStatus,
    ProfileUpdateStatus? updateStatus,
    PasswordUpdateStatus? passwordStatus,
    PasswordResetStatus? resetStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserProfileState(
      profile: clearProfile ? null : profile ?? this.profile,
      loadStatus: loadStatus ?? this.loadStatus,
      updateStatus: updateStatus ?? this.updateStatus,
      passwordStatus: passwordStatus ?? this.passwordStatus,
      resetStatus: resetStatus ?? this.resetStatus,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        loadStatus,
        updateStatus,
        passwordStatus,
        resetStatus,
        errorMessage,
      ];
}

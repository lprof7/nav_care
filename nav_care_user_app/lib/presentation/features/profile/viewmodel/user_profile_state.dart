import 'package:equatable/equatable.dart';

import '../../../../data/users/models/user_profile_model.dart';

enum UserProfileStatus { initial, loading, loaded, failure }

enum UserProfileAction { updated, updateFailed }

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final UserProfileModel? profile;
  final bool isUpdating;
  final String? errorMessage;
  final UserProfileAction? lastAction;
  final int actionId;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.profile,
    this.isUpdating = false,
    this.errorMessage,
    this.lastAction,
    this.actionId = 0,
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserProfileModel? profile,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
    UserProfileAction? lastAction,
    bool clearAction = false,
    int? actionId,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      lastAction: clearAction ? null : lastAction ?? this.lastAction,
      actionId: actionId ?? this.actionId,
    );
  }

  @override
  List<Object?> get props =>
      [status, profile, isUpdating, errorMessage, lastAction, actionId];
}

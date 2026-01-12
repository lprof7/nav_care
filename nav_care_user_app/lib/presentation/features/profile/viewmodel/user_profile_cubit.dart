import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/storage/user_store.dart';
import 'package:nav_care_user_app/data/authentication/models.dart';
import 'package:nav_care_user_app/data/users/user_repository.dart';
import 'package:nav_care_user_app/presentation/features/authentication/session/auth_session_cubit.dart';

import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit({
    required UserRepository repository,
    required UserStore userStore,
    required AuthSessionCubit authSessionCubit,
  })  : _repository = repository,
        _userStore = userStore,
        _authSessionCubit = authSessionCubit,
        super(const UserProfileState());

  final UserRepository _repository;
  final UserStore _userStore;
  final AuthSessionCubit _authSessionCubit;
  StreamSubscription<AuthSessionState>? _authSubscription;

  void listenToAuth([AuthSessionCubit? authCubit]) {
    _authSubscription?.cancel();
    final cubit = authCubit ?? _authSessionCubit;
    _authSubscription = cubit.stream.listen((authState) {
      if (authState.isAuthenticated) {
        loadProfile();
      } else {
        resetProfile();
      }
    });
  }

  Future<void> loadProfile() async {
    if (state.loadStatus == ProfileLoadStatus.loading) return;
    emit(state.copyWith(
        loadStatus: ProfileLoadStatus.loading, clearError: true));
    try {
      final profile = await _repository.fetchProfile();
      emit(state.copyWith(
        profile: profile,
        loadStatus: ProfileLoadStatus.success,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        loadStatus: ProfileLoadStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? province,
    String? country,
    String? imagePath,
  }) async {
    emit(state.copyWith(
        updateStatus: ProfileUpdateStatus.updating, clearError: true));
    try {
      final updated = await _repository.updateProfile(
        name: name,
        email: email,
        phone: phone,
        address: address,
        city: city,
        state: province,
        country: country,
        imagePath: imagePath,
      );
      await _userStore.saveUser(
        User(
          id: updated.id,
          name: updated.name,
          email: updated.email,
          phone: updated.phone,
          profilePicture: updated.profilePicture,
        ),
      );
      _authSessionCubit.setAuthenticatedUser(
        User(
          id: updated.id,
          name: updated.name,
          email: updated.email,
          phone: updated.phone,
          profilePicture: updated.profilePicture,
        ),
      );
      emit(state.copyWith(
        profile: updated,
        updateStatus: ProfileUpdateStatus.success,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        updateStatus: ProfileUpdateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updatePassword(
      {required String currentPassword, required String newPassword}) async {
    emit(state.copyWith(
        passwordStatus: PasswordUpdateStatus.updating, clearError: true));
    try {
      await _repository.updatePassword(
          currentPassword: currentPassword, newPassword: newPassword);
      emit(state.copyWith(passwordStatus: PasswordUpdateStatus.success));
    } catch (e) {
      emit(state.copyWith(
        passwordStatus: PasswordUpdateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> requestPasswordReset(String email) async {
    emit(state.copyWith(
        resetStatus: PasswordResetStatus.sending, clearError: true));
    try {
      await _repository.requestPasswordReset(email);
      emit(state.copyWith(resetStatus: PasswordResetStatus.success));
    } catch (e) {
      emit(state.copyWith(
        resetStatus: PasswordResetStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteAccount() async {
    if (state.deleteStatus == ProfileDeleteStatus.deleting) return;
    emit(state.copyWith(
      deleteStatus: ProfileDeleteStatus.deleting,
      clearError: true,
    ));
    try {
      await _repository.deleteAccount();
      await _authSessionCubit.logout();
      emit(state.copyWith(deleteStatus: ProfileDeleteStatus.success));
    } catch (e) {
      emit(state.copyWith(
        deleteStatus: ProfileDeleteStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void resetStatuses() {
    emit(state.copyWith(
      updateStatus: ProfileUpdateStatus.idle,
      passwordStatus: PasswordUpdateStatus.idle,
      resetStatus: PasswordResetStatus.idle,
      deleteStatus: ProfileDeleteStatus.idle,
      clearError: true,
    ));
  }

  void resetProfile() {
    emit(state.copyWith(
      clearProfile: true,
      loadStatus: ProfileLoadStatus.idle,
      updateStatus: ProfileUpdateStatus.idle,
      passwordStatus: PasswordUpdateStatus.idle,
      resetStatus: PasswordResetStatus.idle,
      deleteStatus: ProfileDeleteStatus.idle,
      clearError: true,
    ));
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}

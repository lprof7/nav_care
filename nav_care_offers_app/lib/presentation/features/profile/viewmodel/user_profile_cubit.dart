import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/storage/doctor_store.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'package:nav_care_offers_app/data/users/models/user_profile_model.dart';
import 'package:nav_care_offers_app/data/users/user_repository.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';

import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit({
    required UserRepository repository,
    required DoctorStore doctorStore,
    required AuthCubit authCubit,
  })  : _repository = repository,
        _doctorStore = doctorStore,
        _authCubit = authCubit,
        super(const UserProfileState());

  final UserRepository _repository;
  final DoctorStore _doctorStore;
  final AuthCubit _authCubit;
  StreamSubscription<AuthState>? _authSubscription;

  void listenToAuth([AuthCubit? authCubit]) {
    _authSubscription?.cancel();
    final cubit = authCubit ?? _authCubit;
    _authSubscription = cubit.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated) {
        loadProfile();
      } else if (authState.status == AuthStatus.unauthenticated) {
        resetProfile();
      }
    });
  }

  Future<void> loadProfile() async {
    if (_authCubit.state.status != AuthStatus.authenticated) return;
    if (state.loadStatus == ProfileLoadStatus.loading) return;
    emit(state.copyWith(loadStatus: ProfileLoadStatus.loading, clearError: true));
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
    emit(state.copyWith(updateStatus: ProfileUpdateStatus.updating, clearError: true));
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
      final user = _mapToUser(updated);
      await _doctorStore.setDoctor(user.toJson());
      await _authCubit.setAuthenticatedUser(user);
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

  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    emit(state.copyWith(passwordStatus: PasswordUpdateStatus.updating, clearError: true));
    try {
      await _repository.updatePassword(currentPassword: currentPassword, newPassword: newPassword);
      emit(state.copyWith(passwordStatus: PasswordUpdateStatus.success));
    } catch (e) {
      emit(state.copyWith(
        passwordStatus: PasswordUpdateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> requestPasswordReset(String email) async {
    emit(state.copyWith(resetStatus: PasswordResetStatus.sending, clearError: true));
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

  void resetStatuses() {
    emit(state.copyWith(
      updateStatus: ProfileUpdateStatus.idle,
      passwordStatus: PasswordUpdateStatus.idle,
      resetStatus: PasswordResetStatus.idle,
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
      clearError: true,
    ));
  }

  User _mapToUser(UserProfileModel profile) {
    return User(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      profilePicture: profile.profilePicture,
    );
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}

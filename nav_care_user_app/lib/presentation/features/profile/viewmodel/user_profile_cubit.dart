import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/storage/user_store.dart';
import 'package:nav_care_user_app/data/authentication/models.dart';
import 'package:nav_care_user_app/data/users/models/user_profile_model.dart';
import 'package:nav_care_user_app/data/users/user_repository.dart';

import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit({
    required UserRepository repository,
    required UserStore userStore,
  })  : _repository = repository,
        _userStore = userStore,
        super(const UserProfileState());

  final UserRepository _repository;
  final UserStore _userStore;

  Future<void> loadProfile() async {
    emit(
      state.copyWith(
        status: UserProfileStatus.loading,
        clearError: true,
        clearAction: true,
      ),
    );
    try {
      final profile = await _repository.fetchProfile();
      await _syncUserStore(profile);
      emit(
        state.copyWith(
          status: UserProfileStatus.loaded,
          profile: profile,
          clearError: true,
          clearAction: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: error.toString(),
          clearAction: true,
        ),
      );
    }
  }

  Future<void> refreshProfile() => loadProfile();

  Future<void> updateProfile({
    String? name,
    String? password,
  }) async {
    emit(
      state.copyWith(
        isUpdating: true,
        clearAction: true,
      ),
    );
    try {
      final profile = await _repository.updateProfile(
        name: name,
        password: password,
      );
      await _syncUserStore(profile);
      emit(
        state.copyWith(
          profile: profile,
          isUpdating: false,
          status: UserProfileStatus.loaded,
          clearError: true,
          lastAction: UserProfileAction.updated,
          actionId: state.actionId + 1,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: error.toString(),
          lastAction: UserProfileAction.updateFailed,
          actionId: state.actionId + 1,
        ),
      );
    }
  }

  Future<void> _syncUserStore(UserProfileModel profile) async {
    final current = await _userStore.getUser();
    final updated = User(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      profilePicture: profile.profilePicture ?? current?.profilePicture,
    );
    await _userStore.saveUser(updated);
  }
}

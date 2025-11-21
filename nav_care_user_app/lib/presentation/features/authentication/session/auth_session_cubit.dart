import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/storage/token_store.dart';
import 'package:nav_care_user_app/core/storage/user_store.dart';
import 'package:nav_care_user_app/data/authentication/models.dart';

part 'auth_session_state.dart';

class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit({
    required TokenStore tokenStore,
    required UserStore userStore,
  })  : _tokenStore = tokenStore,
        _userStore = userStore,
        super(const AuthSessionState());

  final TokenStore _tokenStore;
  final UserStore _userStore;

  Future<void> refreshSession() async {
    final token = await _tokenStore.getToken();
    final user = await _userStore.getUser();
    if (token != null && token.isNotEmpty && user != null) {
      emit(
        state.copyWith(
          status: AuthSessionStatus.authenticated,
          user: user,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AuthSessionStatus.unauthenticated,
          clearUser: true,
        ),
      );
    }
  }

  void setAuthenticatedUser(User user) {
    emit(
      state.copyWith(
        status: AuthSessionStatus.authenticated,
        user: user,
      ),
    );
  }

  void clearSession() {
    emit(
      state.copyWith(
        status: AuthSessionStatus.unauthenticated,
        clearUser: true,
      ),
    );
  }
}

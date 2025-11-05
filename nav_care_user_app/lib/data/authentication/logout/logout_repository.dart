import 'package:nav_care_user_app/core/storage/token_store.dart';
import 'package:nav_care_user_app/core/storage/user_store.dart';

class LogoutRepository {
  final TokenStore _tokenStore;
  final UserStore _userStore;

  LogoutRepository({
    required TokenStore tokenStore,
    required UserStore userStore,
  })  : _tokenStore = tokenStore,
        _userStore = userStore;

  /// Clears any persisted authentication state for the current user.
  Future<void> logout() async {
    await Future.wait([
      _tokenStore.clearToken(),
      _userStore.clearUser(),
    ]);
  }
}

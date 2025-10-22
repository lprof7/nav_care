import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/core/storage/token_store.dart';
import 'package:nav_care_user_app/data/authentication/models.dart';
import 'services/signin_service.dart';

class SigninRepository {
  final SigninService _signinService;
  final TokenStore _tokenStore;

  SigninRepository(this._signinService, this._tokenStore);

  Future<Result<User>> signin(Map<String, dynamic> body) async {
    final result = await _signinService.signin(body);

    return result.fold(
      onFailure: (failure) => Result.failure(failure),
      onSuccess: (data) {
        final authResponse = AuthResponse.fromJson(data['data']);
        _tokenStore.setToken(authResponse.token);
        return Result.success(authResponse.user);
      },
    );
  }
}

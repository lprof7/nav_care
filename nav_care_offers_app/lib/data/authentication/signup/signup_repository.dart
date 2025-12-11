import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/storage/doctor_store.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'models/signup_request.dart';
import 'models/signup_result.dart';
import 'services/signup_service.dart';

class SignupRepository {
  final SignupService _signupService;
  final TokenStore _tokenStore;
  final DoctorStore _doctorStore;

  SignupRepository(
    this._signupService,
    this._tokenStore,
    this._doctorStore,
  );

  Future<Result<SignupResult>> signup(SignupRequest request) async {
    final result = await _signupService.signup(request);

    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      final data = response['data'];
      final message = _extractMessage(response['message']) ??
          'Account created successfully';
      User? user;
      String? token;

      if (data is Map<String, dynamic>) {
        try {
          final authResponse = AuthResponse.fromJson(data);
          user = authResponse.user;
          token = authResponse.token;
          await _tokenStore.setUserToken(authResponse.token);
          await _doctorStore.setDoctor(authResponse.user.toJson());
        } catch (_) {
          // Swallow parsing errors and fall back to message only
        }
      }

      return Result.success(
        SignupResult(
          user: user,
          token: token,
          message: message,
        ),
      );
    }

    return Result.failure(
      result.error ?? const Failure.unknown(),
    );
  }

  String? _extractMessage(dynamic message) {
    if (message is String) return message;
    if (message is Map) {
      final english = message['en'];
      if (english != null) return english.toString();
      final values = message.values;
      if (values is Iterable) {
        for (final value in values) {
          if (value != null) {
            return value.toString();
          }
        }
      }
    }
    return null;
  }
}

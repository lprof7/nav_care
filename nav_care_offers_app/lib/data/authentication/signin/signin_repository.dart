import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/storage/doctor_store.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'services/signin_service.dart';

class SigninRepository {
  final SigninService _signinService;
  final TokenStore _tokenStore;
  final DoctorStore _doctorStore;

  SigninRepository(
    this._signinService,
    this._tokenStore,
    this._doctorStore,
  );

  Future<Result<Doctor>> signin(Map<String, dynamic> body) async {
    final result = await _signinService.signin(body);

    if (!result.isSuccess || result.data == null) {
      return Result.failure(result.error ?? const Failure.unknown());
    }

    final responseData = result.data!;
    try {
      final payload = responseData['data'];
      if (payload is! Map<String, dynamic>) {
        return Result.failure(
          const Failure.server(message: 'Malformed login response'),
        );
      }
      final authResponse = AuthResponse.fromJson(payload);
      await _tokenStore.setToken(authResponse.token);
      final doctor = authResponse.doctor ??
          Doctor(
            id: authResponse.user.id,
            user: authResponse.user,
          );
      await _doctorStore.setDoctor(doctor.toJson());
      return Result.success(doctor);
    } on FormatException catch (error) {
      return Result.failure(
        Failure.server(message: error.message),
      );
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'Unable to parse login response'),
      );
    }
  }
}

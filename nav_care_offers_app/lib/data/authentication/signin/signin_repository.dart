import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/storage/doctor_store.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'services/signin_service.dart';

enum SigninResolution {
  doctorAuthenticated,
  requiresDoctorProfile,
}

class SigninOutcome {
  final SigninResolution resolution;
  final User user;
  final Doctor? doctor;

  const SigninOutcome._(
    this.resolution, {
    required this.user,
    this.doctor,
  });

  factory SigninOutcome.doctorAuthenticated(Doctor doctor) =>
      SigninOutcome._(
        SigninResolution.doctorAuthenticated,
        user: doctor.user,
        doctor: doctor,
      );

  factory SigninOutcome.requiresDoctorProfile(User user) =>
      SigninOutcome._(
        SigninResolution.requiresDoctorProfile,
        user: user,
      );
}

class SigninRepository {
  final SigninService _signinService;
  final TokenStore _tokenStore;
  final DoctorStore _doctorStore;

  SigninRepository(
    this._signinService,
    this._tokenStore,
    this._doctorStore,
  );

  Future<Result<SigninOutcome>> signin(Map<String, dynamic> body) async {
    final userLogin = await _signinService.loginUser(body);
    if (!userLogin.isSuccess || userLogin.data == null) {
      final failure = userLogin.error ?? const Failure.unknown();
      if (failure.type == FailureType.unauthorized) {
        return Result.failure(
          const Failure.unauthorized(message: 'signin_account_not_found'),
        );
      }
      return Result.failure(failure);
    }

    try {
      final userPayload = _extractPayload(userLogin.data!);
      final userAuth = AuthResponse.fromJson(userPayload);

      final doctorLogin = await _signinService.loginDoctor(body);
      if (!doctorLogin.isSuccess || doctorLogin.data == null) {
        final failure = doctorLogin.error ?? const Failure.unknown();
        if (failure.type == FailureType.unauthorized) {
          await _tokenStore.setToken(userAuth.token);
          final placeholder = Doctor(
            id: userAuth.user.id,
            user: userAuth.user,
          );
          await _doctorStore.setDoctor(placeholder.toJson());
          return Result.success(
            SigninOutcome.requiresDoctorProfile(userAuth.user),
          );
        }
        return Result.failure(failure);
      }

      final doctorPayload = _extractPayload(doctorLogin.data!);
      final doctorAuth = AuthResponse.fromJson(doctorPayload);
      await _tokenStore.setToken(doctorAuth.token);
      final doctor = doctorAuth.doctor ??
          Doctor(
            id: doctorAuth.user.id,
            user: doctorAuth.user,
          );
      await _doctorStore.setDoctor(doctor.toJson());

      return Result.success(SigninOutcome.doctorAuthenticated(doctor));
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

  Map<String, dynamic> _extractPayload(Map<String, dynamic> response) {
    final payload = response['data'];
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Malformed login response');
    }
    return payload;
  }
}

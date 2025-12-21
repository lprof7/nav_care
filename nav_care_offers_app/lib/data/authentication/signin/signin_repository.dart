import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/storage/doctor_store.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'services/signin_service.dart';

enum SigninResolution {
  authenticated,
}

class SigninOutcome {
  final SigninResolution resolution;
  final User user;
  final Doctor? doctor;
  final bool isDoctor;

  const SigninOutcome._(
    this.resolution, {
    required this.user,
    this.doctor,
    required this.isDoctor,
  });

  factory SigninOutcome.authenticated({
    required User user,
    Doctor? doctor,
    required bool isDoctor,
  }) =>
      SigninOutcome._(
        SigninResolution.authenticated,
        user: user,
        doctor: doctor,
        isDoctor: isDoctor,
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
    final loginCheck = await _signinService.loginCheck(body);
    if (!loginCheck.isSuccess || loginCheck.data == null) {
      final failure = loginCheck.error ?? const Failure.unknown();
      return Result.failure(failure);
    }

    try {
      final payload = loginCheck.data!;
      if (payload['success'] != true) {
        final message = _extractMessage(payload['message']) ??
            'signin_account_not_found';
        return Result.failure(
          Failure.unauthorized(message: message),
        );
      }

      final data = _extractPayload(payload);
      final isDoctor = data['isDoctor'] == true;
      final token = data['token']?.toString();
      if (token == null || token.isEmpty) {
        return Result.failure(
          const Failure.server(message: 'Missing authentication token'),
        );
      }

      final userJson = data['user'];
      if (userJson is! Map<String, dynamic>) {
        return Result.failure(
          const Failure.server(message: 'Missing user data'),
        );
      }
      final user = User.fromJson(userJson);

      Doctor? doctor;
      final doctorJson = data['doctor'];
      if (doctorJson is Map<String, dynamic>) {
        doctor = Doctor.fromJson(doctorJson);
      }

      if (isDoctor) {
        await _tokenStore.setDoctorToken(token);
        await _tokenStore.clearUserToken();
      } else {
        await _tokenStore.setUserToken(token);
        await _tokenStore.clearDoctorToken();
      }
      await _tokenStore.setIsDoctor(isDoctor);
      await _doctorStore.setDoctor(user.toJson());

      return Result.success(
        SigninOutcome.authenticated(
          user: user,
          doctor: doctor,
          isDoctor: isDoctor,
        ),
      );
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

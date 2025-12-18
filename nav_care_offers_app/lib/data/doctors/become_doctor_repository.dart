import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/storage/doctor_store.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'package:nav_care_offers_app/data/doctors/services/become_doctor_service.dart';

class BecomeDoctorRepository {
  BecomeDoctorRepository(
    this._service,
    this._tokenStore,
    this._doctorStore,
  );

  final BecomeDoctorService _service;
  final TokenStore _tokenStore;
  final DoctorStore _doctorStore;

  static const _fallbackAvailability =
      '[{"day":"monday","start":"09:00","end":"17:00"}]';
  static const _fallbackSpecialty = 'General';

  Future<Result<Doctor>> becomeDoctor({
    required String bioEn,
    String? bioFr,
    String? bioAr,
    XFile? image,
    String? specialty,
    String? availabilityJson,
  }) async {
    final normalizedBio = bioEn.trim();
    final normalizedSpecialty = (specialty?.trim().isNotEmpty ?? false)
        ? specialty!.trim()
        : _fallbackSpecialty;
    final normalizedAvailability =
        (availabilityJson?.trim().isNotEmpty ?? false)
            ? availabilityJson!.trim()
            : _fallbackAvailability;

    final formMap = <String, dynamic>{
      'bio_en': normalizedBio,
      if (bioFr != null && bioFr.isNotEmpty) 'bio_fr': bioFr,
      if (bioAr != null && bioAr.isNotEmpty) 'bio_ar': bioAr,
      'specialty': normalizedSpecialty,
      'availability': normalizedAvailability,
    };

    if (image != null) {
      formMap['image'] = await MultipartFile.fromFile(
        image.path,
        filename: image.name,
      );
    }

    final formData = FormData.fromMap(formMap);
    final response = await _service.becomeDoctor(formData);
    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final payload = _extractPayload(response.data!);
      final token = payload['token']?.toString();
      if (token == null || token.isEmpty) {
        return Result.failure(
          const Failure.server(message: 'Missing token in response'),
        );
      }

      User? user = _safeUser(payload['user']);
      final doctor = _safeDoctor(payload['doctor'], user) ??
          _buildFallbackDoctor(
            user,
            specialty: normalizedSpecialty,
            bioEn: normalizedBio,
          );
      user ??= doctor.user;
      await _tokenStore.setUserToken(token);
      await _doctorStore.setDoctor(doctor.toJson());
      return Result.success(doctor);
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'Unable to parse become doctor response'),
      );
    }
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return response;
  }

  User? _safeUser(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      try {
        return User.fromJson(raw);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Doctor _buildFallbackDoctor(
    User? user, {
    required String specialty,
    required String bioEn,
  }) {
    final fallbackUser = user ??
        const User(
          id: '',
          name: '',
          email: '',
        );
    return Doctor(
      id: fallbackUser.id,
      user: fallbackUser,
      specialty: specialty,
      bioEn: bioEn,
    );
  }

  Doctor? _safeDoctor(dynamic raw, User? fallbackUser) {
    if (raw is! Map<String, dynamic>) return null;
    final doctorJson = Map<String, dynamic>.from(raw);
    final embeddedUser = _safeUser(doctorJson['user']) ?? fallbackUser;
    if (embeddedUser != null) {
      doctorJson['user'] = embeddedUser.toJson();
    } else {
      doctorJson.remove('user');
    }
    try {
      return Doctor.fromJson(doctorJson);
    } catch (_) {
      return null;
    }
  }
}

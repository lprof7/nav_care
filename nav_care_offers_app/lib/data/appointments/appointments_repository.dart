import 'package:intl/intl.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart'
    as core_pagination;
import 'package:nav_care_offers_app/data/appointments/models/appointment_model.dart';
import 'package:nav_care_offers_app/data/appointments/services/appointments_service.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';

class AppointmentsRepository {
  AppointmentsRepository(this._service);

  final AppointmentsService _service;
  List<AppointmentModel> _cache = const [];
  core_pagination.Pagination? _lastPagination;

  List<AppointmentModel> get cachedAppointments => List.unmodifiable(_cache);
  core_pagination.Pagination? get lastPagination => _lastPagination;

  Future<Result<AppointmentListModel>> getMyDoctorAppointments() async {
    final response = await _service.getMyDoctorAppointments();

    return response.fold(
      onSuccess: (data) {
        final appointmentListData = _asMap(data['data'])?['appointments'] ?? [];
        final paginationData = _asMap(data['data'])?['pagination'];

        final List<AppointmentModel> appointments =
            (appointmentListData as List)
                .whereType<Map>()
                .map((appointmentJson) => AppointmentModel.fromJson(
                    _normalizeAppointment(appointmentJson)))
                .toList();

        final pagination = _parsePagination(paginationData);

        _cache = appointments;
        _lastPagination = pagination;

        return Result.success(AppointmentListModel(
          appointments: appointments,
          pagination: pagination,
        ));
      },
      onFailure: (failure) {
        return Result.failure(failure);
      },
    );
  }

  Future<Result<AppointmentListModel>> getMyHospitalAppointments() async {
    final response = await _service.getMyHospitalAppointments();
    return response.fold(
      onSuccess: (data) {
        final container = _asMap(data['data']) ?? _asMap(data);
        final appointmentListData = container?['appointments'] ?? [];
        final paginationData = container?['pagination'];

        final List<AppointmentModel> appointments =
            (appointmentListData as List)
                .whereType<Map>()
                .map((appointmentJson) => AppointmentModel.fromJson(
                    _normalizeAppointment(appointmentJson)))
                .toList();

        final pagination = _parsePagination(paginationData);

        _cache = appointments;
        _lastPagination = pagination;

        return Result.success(AppointmentListModel(
          appointments: appointments,
          pagination: pagination,
        ));
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }

  Future<Result<AppointmentModel>> updateAppointment({
    required String appointmentId,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    bool useHospitalToken = false,
  }) async {
    final payload = <String, dynamic>{};
    if (startTime != null) {
      payload['start_time'] = startTime.toIso8601String();
    }
    if (endTime != null) {
      payload['end_time'] = endTime.toIso8601String();
    }
    if (status != null) {
      payload['status'] = status;
    }

    if (payload.isEmpty) {
      return Result.failure(
        const Failure.validation(message: 'invalidData'),
      );
    }

    final response = await _service.updateAppointment(
      appointmentId: appointmentId,
      payload: payload,
      useHospitalToken: useHospitalToken,
    );

    return response.fold(
      onSuccess: (data) {
        final appointmentJson = _extractAppointmentMap(data);
        if (appointmentJson == null) {
          return Result.failure(const Failure.unknown());
        }

        final sanitizedAppointmentJson = _mergeWithCachedAppointment(
          appointmentId: appointmentId,
          appointmentJson: appointmentJson,
        );
        final updatedAppointment =
            AppointmentModel.fromJson(sanitizedAppointmentJson);

        _cache = _cache
            .map((appointment) => appointment.id == updatedAppointment.id
                ? updatedAppointment
                : appointment)
            .toList(growable: false);

        if (_lastPagination != null) {
          _lastPagination = _lastPagination!.copyWith(
            total: _cache.length,
          );
        }

        return Result.success(updatedAppointment);
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }

  Map<String, dynamic>? _extractAppointmentMap(Map<String, dynamic> source) {
    dynamic potential = source['data'];
    if (potential is Map<String, dynamic>) {
      final nested = potential['appointment'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return potential;
    }

    potential = source['appointment'];
    if (potential is Map<String, dynamic>) {
      return potential;
    }

    return null;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  core_pagination.Pagination _parsePagination(dynamic source) {
    final map = _asMap(source);
    if (map == null) {
      return core_pagination.Pagination(
        total: _cache.length,
        page: 1,
        limit: _cache.length,
        pages: 1,
        hasNextPage: false,
        hasPrevPage: false,
        nextPage: null,
        prevPage: null,
      );
    }
    return core_pagination.Pagination.fromJson(map);
  }

  Map<String, dynamic> _mergeWithCachedAppointment({
    required String appointmentId,
    required Map<String, dynamic> appointmentJson,
  }) {
    final cachedAppointment = _findCachedAppointment(appointmentId);
    if (cachedAppointment == null) {
      return appointmentJson;
    }

    final fallbackJson = _appointmentToRaw(cachedAppointment);
    return _deepMergeMaps(fallbackJson, appointmentJson);
  }

  AppointmentModel? _findCachedAppointment(String id) {
    for (final appointment in _cache) {
      if (appointment.id == id) {
        return appointment;
      }
    }
    return null;
  }

  Map<String, dynamic> _appointmentToRaw(AppointmentModel appointment) => {
        '_id': appointment.id,
        'patient': _patientToRaw(appointment.patient),
        'provider': _providerToRaw(appointment.provider),
        'service': _serviceToRaw(appointment.service),
        'status': appointment.status,
        'start_time': appointment.startTime,
        'end_time': appointment.endTime,
        'price': appointment.price,
      };

  Map<String, dynamic> _patientToRaw(Patient patient) => {
        '_id': patient.id,
        'phone': patient.phone,
        'name': patient.name,
        'email': patient.email,
        'profilePicture': patient.profilePicture,
      };

  Map<String, dynamic> _providerToRaw(Provider provider) {
    final raw = <String, dynamic>{
      '_id': provider.id,
      'user': _userToRaw(provider.user),
      'specialty': provider.specialty,
      'rating': provider.rating,
      'cover': provider.cover,
      'bio_en': provider.bioEn,
      'bio_fr': provider.bioFr,
      'bio_ar': provider.bioAr,
      'bio_sp': provider.bioSp,
      'boost': provider.boost,
      'boostType': provider.boostType,
      'boostExpiresAt': provider.boostExpiresAt,
    };

    raw.removeWhere((_, value) => value == null);
    return raw;
  }

  Map<String, dynamic> _serviceToRaw(Service service) => {
        'name': service.name,
        'provider': service.provider,
        'providerType': service.providerType,
      };

  Map<String, dynamic> _userToRaw(User user) => {
        '_id': user.id,
        'phone': user.phone,
        'name': user.name,
        'email': user.email,
        'profilePicture': user.profilePicture,
      };

  Map<String, dynamic> _deepMergeMaps(
    Map<String, dynamic> base,
    Map<String, dynamic> overlay,
  ) {
    final result = Map<String, dynamic>.from(base);

    overlay.forEach((key, value) {
      if (value == null) {
        return;
      }

      if (value is Map<String, dynamic>) {
        final baseValue = result[key];
        if (baseValue is Map<String, dynamic>) {
          result[key] = _deepMergeMaps(baseValue, value);
        } else {
          result[key] = Map<String, dynamic>.from(value);
        }
      } else {
        result[key] = value;
      }
    });

    return result;
  }

  Map<String, dynamic> _normalizeAppointment(Map appointmentJson) {
    final map =
        appointmentJson.map((key, value) => MapEntry(key.toString(), value));

    Map<String, dynamic> normalizeProvider(Map? provider) {
      final p = (provider ?? const <String, dynamic>{})
          .map((k, v) => MapEntry(k.toString(), v));
      p['_id'] = p['_id']?.toString() ?? '';

      final images = (p['images'] is List)
          ? (p['images'] as List).whereType<dynamic>().toList()
          : const [];

      final user = _asMap(p['user']) ??
          {
            '_id': p['_id']?.toString() ?? '',
            'phone': '',
            'name': p['name']?.toString() ?? '',
            'email': '',
            'profilePicture': images.isNotEmpty ? images.first.toString() : '',
          };

      p['user'] = user;
      p['specialty'] ??= p['facility_type']?.toString() ?? '';
      p['rating'] = _toDouble(p['rating']) ?? 0.0;
      p['cover'] ??= images.isNotEmpty ? images.first.toString() : '';

      return p;
    }

    Map<String, dynamic> normalizePatient(Map? patient) {
      final p = (patient ?? const <String, dynamic>{})
          .map((k, v) => MapEntry(k.toString(), v));
      return {
        '_id': p['_id']?.toString() ?? '',
        'phone': p['phone']?.toString() ?? '',
        'name': p['name']?.toString() ?? '',
        'email': p['email']?.toString() ?? '',
        'profilePicture': p['profilePicture']?.toString() ?? '',
      };
    }

    Map<String, dynamic> normalizeService(Map? service) {
      final s = (service ?? const <String, dynamic>{})
          .map((k, v) => MapEntry(k.toString(), v));
      return {
        'name': _extractLocalizedName(s['name']) ?? s['name']?.toString() ?? '',
        'provider': s['provider']?.toString() ?? '',
        'providerType': s['providerType']?.toString() ?? '',
      };
    }

    map['provider'] = normalizeProvider(_asMap(map['provider']));
    map['patient'] = normalizePatient(_asMap(map['patient']));
    map['service'] = normalizeService(
        _asMap(map['service']) ?? _asMap(map['service_offering']));
    return map;
  }

  String? _extractLocalizedName(dynamic value) {
    final map = _asMap(value);
    if (map == null) return null;
    final locale = Intl.getCurrentLocale();
    final code = locale.split('_').first.toLowerCase();
    final primaryKey = code == 'es' ? 'sp' : code;
    final primary = map[primaryKey];
    if (primary is String && primary.trim().isNotEmpty) {
      return primary;
    }
    for (final key in ['en', 'fr', 'ar', 'sp']) {
      final v = map[key];
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

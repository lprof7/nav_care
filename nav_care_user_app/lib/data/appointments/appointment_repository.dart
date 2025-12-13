import 'package:intl/intl.dart';

import '../../core/responses/failure.dart';
import '../../core/responses/pagination.dart';
import '../../core/responses/result.dart';
import 'models/appointment_model.dart';
import 'models/user_appointment_model.dart';
import 'remote_appointment_service.dart';

class AppointmentRepository {
  final RemoteAppointmentService _remoteService;

  AppointmentRepository({required RemoteAppointmentService remoteService})
      : _remoteService = remoteService;

  Future<Result<String>> createAppointment(AppointmentModel appointment) async {
    final response = await _remoteService.createAppointment(appointment);
    return response.fold(
      onSuccess: (data) {
        final map = _asMap(data);
        final message =
            _localizedMessage(map?['message']) ?? 'appointment_created_success';
        return Result.success(message);
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }

  Future<Result<UserAppointmentList>> getMyAppointments({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _remoteService.getMyAppointments(
      page: page,
      limit: limit,
    );

    return response.fold(
      onSuccess: (data) {
        final container = _asMap(data['data']) ?? _asMap(data);
        final appointmentsSource = container?['appointments'] ??
            container?['items'] ??
            container?['data'];
        final appointments = _mapList(appointmentsSource)
            .map(UserAppointmentModel.fromJson)
            .toList(growable: false);

        final paginationSource =
            _asMap(container?['pagination']) ?? _asMap(data['pagination']);
        final pagination = _parsePagination(paginationSource);

        return Result.success(UserAppointmentList(
          appointments: appointments,
          pagination: pagination,
        ));
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }

  Future<Result<UserAppointmentModel>> updateAppointment({
    required String appointmentId,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
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

    final response = await _remoteService.updateAppointment(
      appointmentId: appointmentId,
      payload: payload,
    );

    return response.fold(
      onSuccess: (data) {
        final appointmentJson = _extractAppointmentMap(data);
        if (appointmentJson == null) {
          return Result.failure(const Failure.unknown());
        }

        return Result.success(
          UserAppointmentModel.fromJson(appointmentJson),
        );
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  List<Map<String, dynamic>> _mapList(dynamic source) {
    if (source is List) {
      return source
          .whereType<Map>()
          .map((entry) => entry
              .map((key, dynamic value) => MapEntry(key.toString(), value)))
          .toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }

  PageMeta? _parsePagination(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;

    int? toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return PageMeta(
      page: toInt(json['page']) ?? 1,
      pageSize: toInt(json['limit']) ?? toInt(json['pageSize']) ?? 10,
      total: toInt(json['total']) ?? 0,
      totalPages: toInt(json['pages']) ?? toInt(json['totalPages']) ?? 1,
    );
  }

  Map<String, dynamic>? _extractAppointmentMap(Map<String, dynamic> source) {
    final data = _asMap(source['data']);
    if (data != null) {
      final nested = _asMap(data['appointment']);
      if (nested != null) {
        return nested;
      }
      return data;
    }

    final appointment = _asMap(source['appointment']);
    if (appointment != null) {
      return appointment;
    }

    return null;
  }

  String? _localizedMessage(dynamic message) {
    if (message is String) return message;
    if (message is Map) {
      final localeCode = Intl.getCurrentLocale().split('_').first;
      if (message[localeCode] is String &&
          (message[localeCode] as String).isNotEmpty) {
        return message[localeCode];
      }
      if (message['en'] is String && (message['en'] as String).isNotEmpty) {
        return message['en'];
      }
      for (final value in message.values) {
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return null;
  }
}

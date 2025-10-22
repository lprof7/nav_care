import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';

import 'models/doctor_service.dart';
import 'models/pagination.dart';
import 'services/doctor_services_service.dart';

class DoctorServicesRepository {
  DoctorServicesRepository(this._service);

  final DoctorServicesService _service;

  Future<Result<DoctorServicesResult>> fetchServices({
    int? page,
    int? limit,
    bool? active,
  }) async {
    final response = await _service.fetchServices(
      page: page,
      limit: limit,
      active: active,
    );

    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final data = response.data!;
      final payload = data['data'];
      if (payload is! Map<String, dynamic>) {
        return Result.failure(
          const Failure.server(message: 'Malformed services response'),
        );
      }

      final servicesJson = payload['services'];
      final paginationJson = payload['pagination'];
      if (servicesJson is! List) {
        return Result.failure(
          const Failure.server(message: 'Services data missing'),
        );
      }

      final services = servicesJson
          .whereType<Map<String, dynamic>>()
          .map(DoctorService.fromJson)
          .toList();
      final pagination = paginationJson is Map<String, dynamic>
          ? Pagination.fromJson(paginationJson)
          : null;

      return Result.success(
        DoctorServicesResult(
          services: services,
          pagination: pagination,
        ),
      );
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'Unable to parse services response'),
      );
    }
  }
}

class DoctorServicesResult {
  final List<DoctorService> services;
  final Pagination? pagination;

  DoctorServicesResult({
    required this.services,
    this.pagination,
  });
}

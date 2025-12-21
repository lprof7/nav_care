import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_catalog_payload.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';

import 'models/doctor_service.dart';
import 'models/pagination.dart';
import 'services/doctor_services_service.dart';

class DoctorServicesRepository {
  DoctorServicesRepository(this._service);

  final DoctorServicesService _service;
  List<ServiceCategory> _catalogCache = const [];

  List<ServiceCategory> get catalog => List.unmodifiable(_catalogCache);

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

  Future<Result<List<ServiceCategory>>> fetchServicesCatalog({
    bool useHospitalToken = true,
  }) async {
    final response =
        await _service.fetchServicesCatalog(useHospitalToken: useHospitalToken);
    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final data = response.data!;
      final payload = data['data'] ?? data;
      final rawServices = payload is Map<String, dynamic>
          ? payload['services'] ?? payload['data']
          : null;
      if (rawServices is! List) {
        return Result.failure(
          const Failure.server(
              message: 'service_offerings.errors.parse_catalog'),
        );
      }
      final services = rawServices
          .whereType<Map<String, dynamic>>()
          .map(ServiceCategory.fromJson)
          .toList();
      _catalogCache = services;
      return Result.success(services);
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'service_offerings.errors.parse_catalog'),
      );
    }
  }

  Future<Result<ServiceCategory>> createService(
    ServiceCatalogPayload payload, {
    bool useHospitalToken = true,
  }) async {
    final response = await _service.createService(
      payload,
      useHospitalToken: useHospitalToken,
    );
    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final data = response.data!;
      final payloadData = data['data'] ?? data;
      final raw = payloadData is Map<String, dynamic>
          ? payloadData['service'] ?? payloadData['data'] ?? payloadData
          : payloadData;
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Missing service payload');
      }
      final service = ServiceCategory.fromJson(raw);
      _catalogCache = _upsertService(_catalogCache, service);
      return Result.success(service);
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'service_offerings.errors.parse_catalog'),
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

List<ServiceCategory> _upsertService(
  List<ServiceCategory> source,
  ServiceCategory service,
) {
  final list = List<ServiceCategory>.from(source);
  final index = list.indexWhere((element) => element.id == service.id);
  if (index >= 0) {
    list[index] = service;
  } else {
    list.insert(0, service);
  }
  return list;
}

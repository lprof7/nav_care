import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering_payload.dart';
import 'package:nav_care_offers_app/data/service_offerings/services/service_offerings_service.dart';

class ServiceOfferingsRepository {
  ServiceOfferingsRepository(this._service);

  final ServiceOfferingsService _service;

  List<ServiceOffering> _cache = const [];
  Pagination? _lastPagination;
  List<ServiceCategory> _catalogCache = const [];

  List<ServiceOffering> get offerings => List.unmodifiable(_cache);
  Pagination? get pagination => _lastPagination;
  List<ServiceCategory> get catalog => List.unmodifiable(_catalogCache);

  ServiceOffering? findById(String id) {
    try {
      return _cache.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Result<ServiceOfferingsResult>> fetchMyOfferings({
    int? page,
    int? limit,
  }) async {
    final response =
        await _service.fetchMyOfferings(page: page, limit: limit ?? 20);
    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final parsed = _parseOfferingsResponse(response.data!);
      _cache = parsed.offerings;
      _lastPagination = parsed.pagination;
      return Result.success(parsed);
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'service_offerings.errors.parse_list'),
      );
    }
  }

  Future<Result<ServiceOffering>> fetchOfferingById(String offeringId) async {
    final cached = findById(offeringId);
    if (cached != null) {
      return Result.success(cached);
    }
    final response = await _service.fetchOfferingById(offeringId);
    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final data = _extractDataMap(response.data!);
      final rawOffering = data['offering'] ?? data['data'] ?? data;
      if (rawOffering is! Map<String, dynamic>) {
        throw const FormatException('Missing offering data');
      }
      final offering = ServiceOffering.fromJson(rawOffering);
      _cache = _upsert(_cache, offering);
      return Result.success(offering);
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'service_offerings.errors.parse_detail'),
      );
    }
  }

  Future<Result<ServiceOffering>> createOffering(
      ServiceOfferingPayload payload) async {
    final response = await _service.createOffering(payload);
    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final data = _extractDataMap(response.data!);
      final raw = data['offering'] ?? data['data'] ?? data;
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Missing offering payload');
      }
      final offering = ServiceOffering.fromJson(raw);
      _cache = _upsert(_cache, offering);
      return Result.success(offering);
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'service_offerings.errors.parse_submit'),
      );
    }
  }

  Future<Result<ServiceOffering>> updateOffering(
    String offeringId,
    ServiceOfferingPayload payload,
  ) async {
    final response = await _service.updateOffering(offeringId, payload);
    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final data = _extractDataMap(response.data!);
      final raw = data['offering'] ?? data['data'] ?? data;
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Missing offering payload');
      }
      final offering = ServiceOffering.fromJson(raw);
      _cache = _upsert(_cache, offering);
      return Result.success(offering);
    } catch (_) {
      return Result.failure(
        const Failure.server(message: 'service_offerings.errors.parse_submit'),
      );
    }
  }

  Future<Result<List<ServiceCategory>>> fetchServicesCatalog() async {
    final response = await _service.fetchServicesCatalog();
    if (!response.isSuccess || response.data == null) {
      return Result.failure(response.error ?? const Failure.unknown());
    }

    try {
      final data = _extractDataMap(response.data!);
      final rawServices = data['services'] ?? data['data'];
      if (rawServices is! List) {
        return Result.failure(
          const Failure.server(message: 'service_offerings.errors.parse_catalog'),
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

  ServiceOfferingsResult _parseOfferingsResponse(Map<String, dynamic> json) {
    final data = _extractDataMap(json);
    final rawOfferings = data['offerings'] ?? data['data'] ?? const [];
    final offerings = <ServiceOffering>[];
    if (rawOfferings is Iterable) {
      for (final item in rawOfferings) {
        if (item is Map<String, dynamic>) {
          offerings.add(ServiceOffering.fromJson(item));
        }
      }
    } else if (rawOfferings is Map<String, dynamic>) {
      offerings.add(ServiceOffering.fromJson(rawOfferings));
    }
    final paginationJson = data['pagination'];
    final pagination = paginationJson is Map<String, dynamic>
        ? Pagination.fromJson(paginationJson)
        : _lastPagination;
    return ServiceOfferingsResult(
      offerings: offerings,
      pagination: pagination,
    );
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> json) {
    const candidates = ['data', 'payload', 'result'];
    for (final key in candidates) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }
    return json;
  }

  List<ServiceOffering> _upsert(
    List<ServiceOffering> source,
    ServiceOffering offering,
  ) {
    final list = List<ServiceOffering>.from(source);
    final index = list.indexWhere((element) => element.id == offering.id);
    if (index >= 0) {
      list[index] = offering;
    } else {
      list.add(offering);
    }
    return list;
  }
}

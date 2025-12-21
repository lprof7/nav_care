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

  List<ServiceOffering> get offerings => List.unmodifiable(_cache);
  Pagination? get pagination => _lastPagination;

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
    bool useHospitalToken = true,
  }) async {
    final response = await _service.fetchMyOfferings(
      page: page,
      limit: limit ?? 20,
      useHospitalToken: useHospitalToken,
    );
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

  Future<Result<ServiceOffering>> fetchOfferingById(
    String offeringId, {
    bool useHospitalToken = true,
  }) async {
    final cached = findById(offeringId);
    if (cached != null) {
      return Result.success(cached);
    }
    final response = await _service.fetchOfferingById(
      offeringId,
      useHospitalToken: useHospitalToken,
    );
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
    ServiceOfferingPayload payload, {
    bool useHospitalToken = true,
  }) async {
    final response = await _service.createOffering(
      payload,
      useHospitalToken: useHospitalToken,
    );
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
    ServiceOfferingPayload payload, {
    bool useHospitalToken = true,
  }) async {
    final response = await _service.updateOffering(
      offeringId,
      payload,
      useHospitalToken: useHospitalToken,
    );
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

  Future<Result<bool>> deleteOffering(
    String offeringId, {
    bool useHospitalToken = true,
  }) async {
    final response = await _service.deleteOffering(
      offeringId,
      useHospitalToken: useHospitalToken,
    );
    if (!response.isSuccess) {
      return Result.failure(response.error ?? const Failure.unknown());
    }
    _cache = _cache.where((element) => element.id != offeringId).toList();
    return Result.success(true);
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

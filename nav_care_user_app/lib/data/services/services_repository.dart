import 'package:nav_care_user_app/core/responses/pagination.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';

import '../../core/responses/result.dart';
import '../../core/responses/failure.dart';
import 'models/service_model.dart';
import 'services_remote_service.dart';

class ServicesRepository {
  final ServicesRemoteService remoteService;

  ServicesRepository({required this.remoteService});

  Future<Paged<ServiceModel>> getServices({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await remoteService.listServices(page: page, limit: limit);
    return _mapServicesResponse(response);
  }

  Future<Paged<ServiceOfferingModel>> getServiceOfferings({
    required String serviceId,
    int page = 1,
    int limit = 20,
    String? providerId,
  }) async {
    final response = await remoteService.listServiceOfferings(
      serviceId: serviceId,
      page: page,
      limit: limit,
      providerId: providerId,
    );
    return _mapOfferingsResponse(response);
  }

  Paged<ServiceModel> _mapServicesResponse(
    Result<Map<String, dynamic>> response,
  ) {
    if (!response.isSuccess || response.data == null) {
      throw Exception(_extractMessage(response.error));
    }

    final payload = response.data!;
    final success = payload['success'];
    if (success is bool && !success) {
      throw Exception(_extractMessage(payload['message']));
    }

    final data = _asMap(payload['data']);
    final servicesSource = _mapList(data?['services']);
    final services = servicesSource
        .map(ServiceModel.fromJson)
        .where((service) => service.id.isNotEmpty)
        .toList(growable: false);

    final pagination = _parsePagination(
          _asMap(payload['pagination']) ?? _asMap(data?['pagination']),
        ) ??
        const PageMeta(page: 1, pageSize: 20, total: 0, totalPages: 1);

    return Paged<ServiceModel>(items: services, meta: pagination);
  }

  Paged<ServiceOfferingModel> _mapOfferingsResponse(
    Result<Map<String, dynamic>> response,
  ) {
    if (!response.isSuccess || response.data == null) {
      throw Exception(_extractMessage(response.error));
    }
    final payload = response.data!;
    final success = payload['success'];
    if (success is bool && !success) {
      throw Exception(_extractMessage(payload['message']));
    }

    final data = _asMap(payload['data']);
    final offeringsSource =
        _mapList(data?['offerings']).isNotEmpty ? _mapList(data?['offerings']) : _mapList(data?['items']);
    final offerings = offeringsSource
        .map(ServiceOfferingModel.fromJson)
        .toList(growable: false);

    final pagination = _parsePagination(
      _asMap(payload['pagination']) ?? _asMap(data?['pagination']),
    );

    return Paged<ServiceOfferingModel>(
      items: offerings,
      meta: pagination,
    );
  }

  Map<String, dynamic>? _asMap(dynamic source) {
    if (source is Map<String, dynamic>) return source;
    if (source is Map) {
      return source.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  List<Map<String, dynamic>> _mapList(dynamic source) {
    if (source is List) {
      return source
          .whereType<Map>()
          .map((entry) =>
              entry.map((key, value) => MapEntry(key.toString(), value)))
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
      pageSize: toInt(json['limit']) ?? toInt(json['pageSize']) ?? 20,
      total: toInt(json['total']) ?? 0,
      totalPages: toInt(json['pages']) ?? toInt(json['totalPages']) ?? 1,
    );
  }

  String _extractMessage(dynamic message) {
    if (message is Failure) {
      return _extractMessage(message.message);
    }
    if (message is String && message.isNotEmpty) return message;
    if (message is Map<String, dynamic>) {
      final localized = [
        message['ar'],
        message['fr'],
        message['en'],
        message['sp'],
      ].whereType<String>().firstWhere(
            (value) => value.isNotEmpty,
            orElse: () => '',
          );
      if (localized.isNotEmpty) return localized;
    }
    return 'Unable to load data. Please try again.';
  }
}

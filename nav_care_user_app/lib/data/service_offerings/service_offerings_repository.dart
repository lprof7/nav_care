import 'package:nav_care_user_app/core/responses/pagination.dart';

import 'models/service_offering_model.dart';
import 'service_offerings_remote_service.dart';

class ServiceOfferingsRepository {
  ServiceOfferingsRepository({required ServiceOfferingsRemoteService remote})
      : _remote = remote;

  final ServiceOfferingsRemoteService _remote;

  Future<Paged<ServiceOfferingModel>> getRecentServiceOfferings({
    int page = 1,
    int limit = 10,
    String? providerId,
  }) async {
    final response = await _remote.listServiceOfferings(
      page: page,
      limit: limit,
      providerId: providerId,
    );

    if (!response.isSuccess || response.data == null) {
      final message = _extractMessage(response.error?.message) ??
          'Failed to load service offerings.';
      throw Exception(message);
    }

    final payload = response.data!;
    final success = payload['success'];
    if (success is bool && !success) {
      throw Exception(
        _extractMessage(payload['message']) ??
            'Failed to load service offerings.',
      );
    }

    final data = _asMap(payload['data']);
    final List<Map<String, dynamic>> rawOfferings = _extractOfferings(data);
    final offerings =
        rawOfferings.map(ServiceOfferingModel.fromJson).toList(growable: false);

    final paginationSource =
        _asMap(payload['pagination']) ?? _asMap(data?['pagination']);
    final pagination = _parsePagination(paginationSource);

    return Paged<ServiceOfferingModel>(
      items: offerings,
      meta: pagination,
    );
  }

  Map<String, dynamic>? _asMap(dynamic source) {
    if (source is Map<String, dynamic>) {
      return source;
    }
    if (source is Map) {
      return source.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  List<Map<String, dynamic>> _extractOfferings(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return const <Map<String, dynamic>>[];
    }
    final candidates = [
      data['offerings'],
      data['items'],
      data['results'],
      data['data'],
    ];

    for (final candidate in candidates) {
      final list = _mapList(candidate);
      if (list.isNotEmpty) {
        return list;
      }
    }

    for (final value in data.values) {
      final nested = _mapList(value);
      if (nested.isNotEmpty) {
        return nested;
      }
    }

    return const <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _mapList(dynamic source) {
    if (source is List) {
      return source
          .whereType<Map>()
          .map((e) => e.map((key, value) => MapEntry(key.toString(), value)))
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

    final page = toInt(json['page']) ?? 1;
    final limit = toInt(json['limit']) ?? toInt(json['pageSize']) ?? 10;
    final total = toInt(json['total']) ?? 0;
    final pages = toInt(json['pages']) ?? toInt(json['totalPages']) ?? 1;

    return PageMeta(
      page: page,
      pageSize: limit,
      total: total,
      totalPages: pages,
    );
  }

  String? _extractMessage(dynamic message) {
    if (message is String && message.isNotEmpty) {
      return message;
    }
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
      if (localized.isNotEmpty) {
        return localized;
      }
    }
    return null;
  }
}

import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/responses/result.dart';

import 'models/search_models.dart';
import 'search_remote_service.dart';

class SearchRepository {
  SearchRepository({required SearchRemoteService remoteService})
      : _remoteService = remoteService;

  final SearchRemoteService _remoteService;

  Future<Result<SearchResponse>> search(
      {required Map<String, dynamic> query}) async {
    final result = await _remoteService.globalSearch(query);

    return result.fold(
      onFailure: (failure) => Result.failure(failure),
      onSuccess: (json) {
        try {
          if (json['success'] == false) {
            final errorBlock = json['error'];
            final message = (errorBlock is Map &&
                    errorBlock['message'] != null &&
                    errorBlock['message'].toString().isNotEmpty)
                ? errorBlock['message'].toString()
                : 'Unable to complete search.';
            return Result.failure(Failure.server(message: message));
          }
          final response = SearchResponse.fromJson(json);
          return Result.success(response);
        } catch (error) {
          return Result.failure(
            Failure.unknown(message: error.toString()),
          );
        }
      },
    );
  }

  Future<Result<List<SearchSuggestion>>> getSuggestions(
      {required String query, int limit = 15}) async {
    final params = {
      'query': query,
      'limit': limit,
    };
    final result = await _remoteService.suggestions(params);
    return result.fold(
      onFailure: (failure) => Result.failure(failure),
      onSuccess: (json) {
        try {
          if (json['success'] == false) {
            final errorBlock = json['error'];
            final message = (errorBlock is Map &&
                    errorBlock['message'] != null &&
                    errorBlock['message'].toString().isNotEmpty)
                ? errorBlock['message'].toString()
                : 'Unable to fetch suggestions.';
            return Result.failure(Failure.server(message: message));
          }
          final data = json['data'];
          final suggestions = <SearchSuggestion>[];

          SearchSuggestion mapSuggestion(String type, dynamic raw, int index) {
            if (raw is Map<String, dynamic>) {
              final id = raw['id']?.toString() ?? '${type}_$index';
              final value =
                  raw['value']?.toString() ?? raw['name']?.toString() ?? '';
              final displayText = raw['displayText']?.toString() ??
                  raw['label']?.toString() ??
                  value;
              return SearchSuggestion(
                id: id,
                type: type,
                value: value,
                displayText: displayText,
                extra: raw,
              );
            }
            final text = raw?.toString() ?? '';
            return SearchSuggestion(
              id: text.isNotEmpty ? text : '${type}_$index',
              type: type,
              value: text,
              displayText: text,
            );
          }

          void addSuggestions(String type, dynamic payload) {
            if (payload is List) {
              for (var i = 0; i < payload.length; i++) {
                suggestions.add(mapSuggestion(type, payload[i], i));
                if (suggestions.length >= limit) return;
              }
            }
          }

          if (data is Map<String, dynamic>) {
            final mapping = {
              'doctors': 'doctor',
              'hospitals': 'hospital',
              'services': 'service',
            };
            for (final entry in mapping.entries) {
              if (suggestions.length >= limit) break;
              addSuggestions(entry.value, data[entry.key]);
            }
          } else if (data is List) {
            addSuggestions('result', data);
          } else if (json['suggestions'] is List) {
            addSuggestions('result', json['suggestions'] as List<dynamic>);
          }

          final limitedSuggestions =
              suggestions.take(limit).toList(growable: false);
          return Result.success(List.unmodifiable(limitedSuggestions));
        } catch (error) {
          return Result.failure(
            Failure.unknown(message: error.toString()),
          );
        }
      },
    );
  }
}

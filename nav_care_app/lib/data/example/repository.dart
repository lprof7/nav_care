import '../../core/responses/result.dart';
import '../../core/responses/failure.dart';
import '../../core/responses/pagination.dart';
import 'model.dart';
import 'services/remote_service.dart';

class ExampleRepository {
  final RemoteExampleService remote;

  ExampleRepository({required this.remote});

  Future<Result<Paged<Example>>> list(
      {int page = 1, int pageSize = 20, String? q}) async {
    final r = await remote.list(query: {
      'page': page,
      'pageSize': pageSize,
      if (q != null && q.isNotEmpty) 'q': q,
    });

    return r.fold(
      onFailure: (f) => Result.failure(f),
      onSuccess: (json) {
        final items = ((json['items'] ?? []) as List)
            .map((e) => Example.fromJson(e as Map<String, dynamic>))
            .toList();
        final m = json['meta'];
        final paged = Paged<Example>(
          items: items,
          meta: m == null
              ? null
              : PageMeta(
                  page: m['page'] ?? page,
                  pageSize: m['pageSize'] ?? pageSize,
                  total: m['total'] ?? items.length,
                  totalPages: m['totalPages'] ?? page,
                ),
        );
        return Result.success(paged);
      },
    );
  }

  Future<Result<Example>> getById(String id) async {
    final r = await remote.getById(id);
    return r.fold(
      onFailure: (f) => Result.failure(f),
      onSuccess: (json) =>
          Result.success(Example.fromJson(json as Map<String, dynamic>)),
    );
  }

  Future<Result<Example>> create(Example payload) async {
    final r = await remote.create(payload.toJson());
    return r.fold(
      onFailure: (f) => Result.failure(f),
      onSuccess: (json) =>
          Result.success(Example.fromJson(json as Map<String, dynamic>)),
    );
  }

  Future<Result<Example>> update(String id, Example payload) async {
    final r = await remote.update(id, payload.toJson());
    return r.fold(
      onFailure: (f) => Result.failure(f),
      onSuccess: (json) =>
          Result.success(Example.fromJson(json as Map<String, dynamic>)),
    );
  }

  Future<Result<bool>> delete(String id) async {
    final r = await remote.delete(id);
    return r.fold(
      onFailure: (f) => Result.failure(f),
      onSuccess: (_) => Result.success(true),
    );
  }
}

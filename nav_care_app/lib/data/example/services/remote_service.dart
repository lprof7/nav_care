import '../../../core/network/api_client.dart';
import '../../../core/responses/result.dart';
import 'service.dart';

class RemoteExampleService implements ExampleService {
  final ApiClient _api;
  RemoteExampleService(this._api);

  @override
  Future<Result<Map<String, dynamic>>> list({Map<String, dynamic>? query}) =>
      _api.get<Map<String, dynamic>>('/example',
          query: query, parser: (j) => j as Map<String, dynamic>);

  @override
  Future<Result<Map<String, dynamic>>> getById(String id) =>
      _api.get<Map<String, dynamic>>('/example/$id',
          parser: (j) => j as Map<String, dynamic>);

  @override
  Future<Result<Map<String, dynamic>>> create(Map<String, dynamic> body) =>
      _api.post<Map<String, dynamic>>('/example',
          body: body, parser: (j) => j as Map<String, dynamic>);

  @override
  Future<Result<Map<String, dynamic>>> update(
          String id, Map<String, dynamic> body) =>
      _api.put<Map<String, dynamic>>('/example/$id',
          body: body, parser: (j) => j as Map<String, dynamic>);

  @override
  Future<Result<Map<String, dynamic>>> delete(String id) =>
      _api.delete<Map<String, dynamic>>('/example/$id',
          parser: (j) => j as Map<String, dynamic>);
}

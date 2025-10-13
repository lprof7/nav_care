import '../../../core/responses/result.dart';

abstract class ExampleService {
  Future<Result<Map<String, dynamic>>> list({Map<String, dynamic>? query});
  Future<Result<Map<String, dynamic>>> getById(String id);
  Future<Result<Map<String, dynamic>>> create(Map<String, dynamic> body);
  Future<Result<Map<String, dynamic>>> update(
      String id, Map<String, dynamic> body);
  Future<Result<Map<String, dynamic>>> delete(String id);
}

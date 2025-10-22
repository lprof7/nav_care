import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/responses/result.dart';
import '../../../core/responses/failure.dart';
import 'service.dart';

class LocalExampleService implements ExampleService {
  static const _kToken = 'auth_token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
  }

  // Local ops not supported by default (you can add caching later)
  @override
  Future<Result<Map<String, dynamic>>> list({Map<String, dynamic>? query}) =>
      Future.value(Result.failure(
          const Failure.unknown(message: 'Local not supported')));

  @override
  Future<Result<Map<String, dynamic>>> getById(String id) => Future.value(
      Result.failure(const Failure.unknown(message: 'Local not supported')));

  @override
  Future<Result<Map<String, dynamic>>> create(Map<String, dynamic> body) =>
      Future.value(Result.failure(
          const Failure.unknown(message: 'Local not supported')));

  @override
  Future<Result<Map<String, dynamic>>> update(
          String id, Map<String, dynamic> body) =>
      Future.value(Result.failure(
          const Failure.unknown(message: 'Local not supported')));

  @override
  Future<Result<Map<String, dynamic>>> delete(String id) => Future.value(
      Result.failure(const Failure.unknown(message: 'Local not supported')));
}

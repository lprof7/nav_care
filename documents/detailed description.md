

## 0) Overview

- **App type:** Generic health app scaffold (domain kept neutral as `example`).
    
- **Language:** Dart (Flutter).
    
- **Architecture:** `core`, `data`, `presentation`.
    
- **State:** BLoC (`flutter_bloc`).
    
- **Networking:** Simple Dio wrapper + unified `ApiClient`.
    
- **Routing:** `go_router`.
    
- **DI:** `get_it`.
    
- **i18n:** `easy_localization` (e.g., `en`, `ar`, `fr`).
    
- **Theme & UI:** Atomic Design under `presentation/shared/ui` (**no `pages`**).
    
- **ENV:** `flutter_dotenv` with provided sample content.
    
- **Responses:** `Result<T>` & `Failure` (+ optional `Paged<T>` helper).
    

---

## 1) Tech Stack

- Flutter (stable)
    
- dio, get_it, go_router
    
- flutter_dotenv
    
- easy_localization
    
- flutter_bloc
    
- shared_preferences (or Hive)
    
- equatable, intl
    
- (optional) json_serializable/build_runner
    

---

## 2) Folder Structure

```
lib/
  core/
    config/
      env.dart
      api_config.dart
      app_config.dart
      config_loader.dart
    di/
      di.dart
    routing/
      app_router.dart
    network/
      dio_client.dart
      api_client.dart
    responses/
      result.dart
      failure.dart
      pagination.dart

  data/
    example/
      model.dart
      services/
        service.dart          // abstract
        remote_service.dart   // implements Service
        local_service.dart    // implements Service (cache/prefs)
      repository.dart         // concrete only, no abstract repo

  presentation/
    shared/
      i18n/                   // assets/translations (JSON)
      theme/
        app_theme.dart
        colors.dart
        spacing.dart
        typography.dart
      ui/                     // Atomic Design (no pages here)
        atoms/
        molecules/
        organisms/
        templates/
      constants/
        ui_constants.dart
        assets.gen.dart       // optional, if using flutter_gen
    features/
      example/
        view/
          example_page.dart
          widgets/
            example_card.dart
        viewmodel/
          example_cubit.dart

  app.dart
  main.dart
  main_staging.dart
  main_prod.dart

assets/
  translations/
    en.json
    ar.json
    fr.json
  env/
    .env.development
    .env.staging
    .env.production
```

> **Note:** The **data layer is partitioned by entities**. Each entity folder contains: `model.dart`, `services/` (with abstract `service.dart`, plus `remote_service.dart` & `local_service.dart`), and a concrete `repository.dart`.

---

## 3) ENV & Config

### `pubspec.yaml` (assets section)

```yaml
flutter:
  assets:
    - assets/translations/
    - assets/env/.env.development
    - assets/env/.env.staging
    - assets/env/.env.production
```

### Sample `.env.*` content (as provided)

> Place this content in one of your env files (e.g., `.env.production`).  
> (If using `flutter_dotenv`, prefer `#` for comments; inline `//` comments may be ignored by some parsers.)

```env
# Vps -------------------------------
VPSMain = 'https://example.com'; //local
VpsChat = 'https://example.com'; //local
SocketMain = 'wss://example.com/ws/'; //local
SocketChat = 'wss://example.com/ws/'; //local
MAPS_API_KEY = 'AIzaSyBHfr0dbOjIOxMil_2hp_P38E7giivM2Sg';
sentryDns = 'https://f7f5b2504a46d6b54d31553072a60468@o4508386548449280.ingest.us.sentry.io/4509939191119872';

# Local-------------------------------
# VPSMain = 'http://192.168.0.100:4000'; //local
# VpsChat = 'http://192.168.0.100:4001'; //local
# SocketMain = 'ws://192.168.0.100:4000/ws/'; //local
# MAPS_API_KEY = 'AIzaSyBHfr0dbOjIOxMil_2hp_P38E7giivM2Sg';
```

### `config_loader.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnv { development, staging, production }

class ConfigLoader {
  static Future<void> load(AppEnv env) async {
    final file = switch (env) {
      AppEnv.development => 'assets/env/.env.development',
      AppEnv.production => 'assets/env/.env.production',
    };
    await dotenv.load(fileName: file);
  }
}
```

### `env.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get vpsMain => _get('VPSMain');
  static String get vpsChat => _get('VpsChat');
  static String get socketMain => _get('SocketMain');
  static String get socketChat => _get('SocketChat');
  static String get mapsApiKey => _get('MAPS_API_KEY');
  static String get sentryDns => _get('sentryDns');

  static String _get(String key) {
    final v = dotenv.env[key];
    if (v == null || v.isEmpty) {
      throw Exception('Missing env key: $key');
    }
    return v;
  }
}
```

### `api_config.dart`

```dart
class ApiConfig {
  final String baseUrl;
  const ApiConfig({required this.baseUrl});

  // Example endpoints
  String get exampleList => '$baseUrl/example';
  String exampleById(String id) => '$baseUrl/example/$id';
}
```

### `app_config.dart`

```dart
import 'env.dart';
import 'api_config.dart';

class AppConfig {
  final ApiConfig api;
  final String mapsKey;
  final String sentryDns;

  AppConfig._(this.api, this.mapsKey, this.sentryDns);

  factory AppConfig.fromEnv() => AppConfig._(
        ApiConfig(baseUrl: Env.vpsMain),
        Env.mapsApiKey,
        Env.sentryDns,
      );
}
```

---

## 4) DI (get_it)

`core/di/di.dart`

```dart
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/api_client.dart';

// example entity wires:
import '../../data/example/services/remote_service.dart';
import '../../data/example/services/local_service.dart';
import '../../data/example/services/service.dart';
import '../../data/example/repository.dart';

final sl = GetIt.instance;

Future<void> configureDependencies(AppConfig config) async {
  sl.registerSingleton<AppConfig>(config);

  // Local service (token/cache)
  final localExample = LocalExampleService();
  sl.registerSingleton<LocalExampleService>(localExample);

  final dio = DioClient(
    baseUrl: config.api.baseUrl,
    timeout: const Duration(milliseconds: 20000),
    tokenProvider: localExample.getToken,
  ).build();
  sl.registerSingleton<ApiClient>(ApiClient(dio));

  // Remote service
  sl.registerSingleton<RemoteExampleService>(RemoteExampleService(sl<ApiClient>()));

  // Bind abstract service to remote by default
  sl.registerSingleton<ExampleService>(sl<RemoteExampleService>());

  // Repository (concrete)
  sl.registerLazySingleton<ExampleRepository>(() => ExampleRepository(
        remote: sl<RemoteExampleService>(),
        local: sl<LocalExampleService>(),
      ));
}
```

---

## 5) Routing (go_router)

`core/routing/app_router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/features/example/view/example_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const ExamplePage()),
  ],
);
```

---

## 6) Networking (Simple)

`core/network/dio_client.dart`

```dart
import 'package:dio/dio.dart';

typedef TokenProvider = Future<String?> Function();

class DioClient {
  final String baseUrl;
  final Duration timeout;
  final TokenProvider? tokenProvider;

  DioClient({required this.baseUrl, required this.timeout, this.tokenProvider});

  Dio build() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {'Accept': 'application/json'},
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = tokenProvider == null ? null : await tokenProvider!();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
    return dio;
  }
}
```

`core/network/api_client.dart`

```dart
import 'package:dio/dio.dart';
import '../responses/result.dart';
import '../responses/failure.dart';

typedef FromJson<T> = T Function(dynamic json);

class ApiClient {
  final Dio _dio;
  ApiClient(this._dio);

  Future<Result<T>> get<T>(String path, {Map<String, dynamic>? query, required FromJson<T> parser}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return Result.success(parser(res.data));
    } on DioException catch (e) {
      return Result.failure(_mapDio(e));
    }
  }

  Future<Result<T>> post<T>(String path, {Object? body, required FromJson<T> parser}) async {
    try {
      final res = await _dio.post(path, data: body);
      return Result.success(parser(res.data));
    } on DioException catch (e) {
      return Result.failure(_mapDio(e));
    }
  }

  Future<Result<T>> put<T>(String path, {Object? body, required FromJson<T> parser}) async {
    try {
      final res = await _dio.put(path, data: body);
      return Result.success(parser(res.data));
    } on DioException catch (e) {
      return Result.failure(_mapDio(e));
    }
  }

  Future<Result<T>> delete<T>(String path, {Object? body, required FromJson<T> parser}) async {
    try {
      final res = await _dio.delete(path, data: body);
      return Result.success(parser(res.data));
    } on DioException catch (e) {
      return Result.failure(_mapDio(e));
    }
  }

  Failure _mapDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const Failure.timeout();
      case DioExceptionType.badResponse:
        final sc = e.response?.statusCode;
        final msg = (e.response?.data is Map) ? (e.response?.data['message']?.toString() ?? '') : '';
        if (sc == 401) return const Failure.unauthorized();
        if (sc == 422) return Failure.validation(message: msg.isEmpty ? 'Validation error' : msg);
        return Failure.server(message: msg.isEmpty ? 'Server error' : msg, statusCode: sc);
      case DioExceptionType.cancel:
        return const Failure.cancelled();
      case DioExceptionType.connectionError:
        return const Failure.network();
      case DioExceptionType.unknown:
      default:
        return const Failure.unknown();
    }
  }
}
```

---

## 7) Responses (Minimal) + Pagination Explanation

`core/responses/result.dart`

```dart
import 'failure.dart';

class Result<T> {
  final T? data;
  final Failure? error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.failure(Failure error) => Result._(error: error, isSuccess: false);

  R fold<R>({required R Function(Failure) onFailure, required R Function(T) onSuccess}) {
    return isSuccess && data != null ? onSuccess(data as T) : onFailure(error ?? const Failure.unknown());
  }
}
```

`core/responses/failure.dart`

```dart
class Failure {
  final String message;
  final String? code;
  final int? statusCode;
  final FailureType type;

  const Failure._(this.type, {required this.message, this.code, this.statusCode});

  const Failure.network({String message = 'Network error', int? statusCode})
      : this._(FailureType.network, message: message, statusCode: statusCode);

  const Failure.server({String message = 'Server error', String? code, int? statusCode})
      : this._(FailureType.server, message: message, code: code, statusCode: statusCode);

  const Failure.unauthorized({String message = 'Unauthorized'})
      : this._(FailureType.unauthorized, message: message);

  const Failure.validation({String message = 'Validation error'})
      : this._(FailureType.validation, message: message);

  const Failure.timeout({String message = 'Request timeout'})
      : this._(FailureType.timeout, message: message);

  const Failure.cancelled({String message = 'Request cancelled'})
      : this._(FailureType.cancelled, message: message);

  const Failure.unknown({String message = 'Unknown error'})
      : this._(FailureType.unknown, message: message);
}

enum FailureType { network, server, unauthorized, validation, timeout, cancelled, unknown }
```

`core/responses/pagination.dart` (helper)

```dart
class PageMeta {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  const PageMeta({required this.page, required this.pageSize, required this.total, required this.totalPages});
}

class Paged<T> {
  final List<T> items;
  final PageMeta? meta;     // page/pageSize format
  final int? offset;        // for offset/limit format
  final int? limit;
  final String? nextCursor; // for cursor-based format
  const Paged({required this.items, this.meta, this.offset, this.limit, this.nextCursor});
}
```

### Pagination in practice (concise):

- **Page/PageSize**: request `?page=1&pageSize=20`, response includes `items` + `meta { page, pageSize, total, totalPages }`.
    
- **Offset/Limit**: request `?offset=0&limit=20`, response includes `items` + `total`.
    
- **Cursor**: request `?cursor=XYZ&limit=20`, response includes `items` + `nextCursor` (null if no more).
    

Your **repository** tracks current pagination state and returns a `Paged<T>` that the BLoC consumes.

---

## 8) Data Layer — Entity-Scoped Example

### `data/example/model.dart`

```dart
class Example {
  final String id;
  final String title;
  final String? description;

  Example({required this.id, required this.title, this.description});

  factory Example.fromJson(Map<String, dynamic> json) => Example(
        id: json['id'].toString(),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
      };
}
```

### `data/example/services/service.dart` (abstract)

```dart
import '../../../core/responses/result.dart';

abstract class ExampleService {
  Future<Result<Map<String, dynamic>>> list({Map<String, dynamic>? query});
  Future<Result<Map<String, dynamic>>> getById(String id);
  Future<Result<Map<String, dynamic>>> create(Map<String, dynamic> body);
  Future<Result<Map<String, dynamic>>> update(String id, Map<String, dynamic> body);
  Future<Result<Map<String, dynamic>>> delete(String id);
}
```

### `data/example/services/remote_service.dart`

```dart
import '../../../core/network/api_client.dart';
import '../../../core/responses/result.dart';
import 'service.dart';

class RemoteExampleService implements ExampleService {
  final ApiClient _api;
  RemoteExampleService(this._api);

  @override
  Future<Result<Map<String, dynamic>>> list({Map<String, dynamic>? query}) =>
      _api.get<Map<String, dynamic>>('/example', query: query, parser: (j) => j as Map<String, dynamic>);

  @override
  Future<Result<Map<String, dynamic>>> getById(String id) =>
      _api.get<Map<String, dynamic>>('/example/$id', parser: (j) => j as Map<String, dynamic>);

  @override
  Future<Result<Map<String, dynamic>>> create(Map<String, dynamic> body) =>
      _api.post<Map<String, dynamic>>('/example', body: body, parser: (j) => j as Map<String, dynamic>);

  @override
  Future<Result<Map<String, dynamic>>> update(String id, Map<String, dynamic> body) =>
      _api.put<Map<String, dynamic>>('/example/$id', body: body, parser: (j) => j as Map<String, dynamic>);

  @override
  Future<Result<Map<String, dynamic>>> delete(String id) =>
      _api.delete<Map<String, dynamic>>('/example/$id', parser: (j) => j as Map<String, dynamic>);
}
```

### `data/example/services/local_service.dart` (cache/token sketch)

```dart
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
      Future.value(Result.failure(const Failure.unknown(message: 'Local not supported')));

  @override
  Future<Result<Map<String, dynamic>>> getById(String id) =>
      Future.value(Result.failure(const Failure.unknown(message: 'Local not supported')));

  @override
  Future<Result<Map<String, dynamic>>> create(Map<String, dynamic> body) =>
      Future.value(Result.failure(const Failure.unknown(message: 'Local not supported')));

  @override
  Future<Result<Map<String, dynamic>>> update(String id, Map<String, dynamic> body) =>
      Future.value(Result.failure(const Failure.unknown(message: 'Local not supported')));

  @override
  Future<Result<Map<String, dynamic>>> delete(String id) =>
      Future.value(Result.failure(const Failure.unknown(message: 'Local not supported')));
}
```

### `data/example/repository.dart` (concrete)

```dart
import '../../core/responses/result.dart';
import '../../core/responses/failure.dart';
import '../../core/responses/pagination.dart';
import 'model.dart';
import 'services/remote_service.dart';
import 'services/local_service.dart';

class ExampleRepository {
  final RemoteExampleService remote;
  final LocalExampleService local;

  ExampleRepository({required this.remote, required this.local});

  Future<Result<Paged<Example>>> list({int page = 1, int pageSize = 20, String? q}) async {
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
          meta: m == null ? null : PageMeta(
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
      onSuccess: (json) => Result.success(Example.fromJson(json as Map<String, dynamic>)),
    );
  }

  Future<Result<Example>> create(Example payload) async {
    final r = await remote.create(payload.toJson());
    return r.fold(
      onFailure: (f) => Result.failure(f),
      onSuccess: (json) => Result.success(Example.fromJson(json as Map<String, dynamic>)),
    );
  }

  Future<Result<Example>> update(String id, Example payload) async {
    final r = await remote.update(id, payload.toJson());
    return r.fold(
      onFailure: (f) => Result.failure(f),
      onSuccess: (json) => Result.success(Example.fromJson(json as Map<String, dynamic>)),
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
```

---

## 9) Presentation (Feature-first, no shared UI/pages)

- `presentation/shared/ui`: **atoms/molecules/organisms/templates** (no `pages`).
    
- `presentation/features/example`:
    
    - `view/` holds screens/widgets (e.g., `ExamplePage`, `ExampleCard`).
        
    - `viewmodel/` holds Cubits/BLoCs.
        

### `example_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/example/repository.dart';
import '../../../core/responses/pagination.dart';
import '../../../core/responses/result.dart';
import '../../../data/example/model.dart';

class ExampleState {
  final bool loading;
  final String? error;
  final List<Example> items;
  final int page;
  final bool canLoadMore;
  final String query;

  ExampleState({
    required this.loading,
    required this.error,
    required this.items,
    required this.page,
    required this.canLoadMore,
    required this.query,
  });

  factory ExampleState.initial() => ExampleState(
    loading: false, error: null, items: const [], page: 1, canLoadMore: true, query: '',
  );

  ExampleState copyWith({
    bool? loading,
    String? error,
    List<Example>? items,
    int? page,
    bool? canLoadMore,
    String? query,
  }) => ExampleState(
    loading: loading ?? this.loading,
    error: error,
    items: items ?? this.items,
    page: page ?? this.page,
    canLoadMore: canLoadMore ?? this.canLoadMore,
    query: query ?? this.query,
  );
}

class ExampleCubit extends Cubit<ExampleState> {
  final ExampleRepository repo;
  ExampleCubit(this.repo) : super(ExampleState.initial());

  Future<void> refresh({String? q}) async {
    emit(state.copyWith(loading: true, error: null, items: [], page: 1, canLoadMore: true, query: q ?? ''));
    await _load(page: 1);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.loading) return;
    emit(state.copyWith(loading: true, error: null));
    await _load(page: state.page + 1);
  }

  Future<void> _load({required int page}) async {
    final r = await repo.list(page: page, pageSize: 20, q: state.query.isEmpty ? null : state.query);
    r.fold(
      onFailure: (f) => emit(state.copyWith(loading: false, error: f.message)),
      onSuccess: (Paged<Example> paged) {
        final newItems = [...state.items, ...paged.items];
        final totalPages = paged.meta?.totalPages ?? page;
        emit(state.copyWith(
          loading: false,
          items: newItems,
          page: page,
          canLoadMore: page < totalPages,
        ));
      },
    );
  }
}
```

---

## 10) i18n & Theme

- Initialize `easy_localization` in `main.dart`.
    
- Provide `en.json`, `ar.json`, `fr.json`.
    
- Theme tokens in `presentation/shared/theme/*`.
    
- Atomic components under `presentation/shared/ui/*` (no `pages`).
    

---

## 11) Bootstrap

- `main.dart`, `main_prod.dart` should:
    
    1. `WidgetsFlutterBinding.ensureInitialized();`
        
    2. `EasyLocalization.ensureInitialized();`
        
    3. `ConfigLoader.load(AppEnv.XXX);`
        
    4. `configureDependencies(AppConfig.fromEnv());`
        
    5. Run `MaterialApp.router` with `appRouter`.
        

---

## 12) What To Generate (Codegen Tasks)

1. Create folders exactly as listed.
    
2. Add dependencies: `dio`, `flutter_bloc`, `equatable`, `get_it`, `go_router`, `easy_localization`, `flutter_dotenv`, `shared_preferences`, `intl`.
    
3. Create **core** files verbatim (networking, responses, config, routing, di).
    
4. Create **data/example** entity: `model.dart` (with `fromJson` & `toJson`), `services/*` (abstract + remote + local), and `repository.dart` (concrete).
    
5. Create **presentation** feature `example` with `view` (`ExamplePage` & basic widgets) and `viewmodel` (`ExampleCubit`).
    
6. Implement **atomic UI** under `presentation/shared/ui` (**no pages**).
    
7. Add `assets/translations` JSON files and hook up `easy_localization`.
    
8. Ensure DI wiring registers `LocalExampleService`, `RemoteExampleService`, binds `ExampleService` to remote, and exposes `ExampleRepository`.
    
9. Ensure pagination flow in `ExampleCubit` with `list()` repository method.
    
10. Use env variables from `Env` & `AppConfig`.
    


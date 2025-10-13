import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/api_client.dart';
import '../storage/secure_token_store.dart';
import '../storage/token_store.dart';

// example entity wires:
import '../../data/example/services/remote_service.dart';
import '../../data/example/services/local_service.dart';
import '../../data/example/services/service.dart';
import '../../data/example/repository.dart';
import '../../data/authentication/signin/services/signin_service.dart';
import '../../data/authentication/signin/services/remote_signin_service.dart';
import '../../data/authentication/signin/signin_repository.dart';
import '../../presentation/features/authentication/signin/viewmodel/signin_cubit.dart';
import '../../presentation/features/authentication/signin/viewmodel/signin_cubit.dart';

final sl = GetIt.instance;
Future<void> configureDependencies(AppConfig config) async {
  sl.registerSingleton<AppConfig>(config);

  // Storage
  sl.registerLazySingleton<TokenStore>(() => SecureTokenStore());

  // Local service (token/cache)
  // sl.registerSingleton<LocalExampleService>(LocalExampleService());

  final dio = DioClient(
    baseUrl: config.api.baseUrl,
    timeout: const Duration(milliseconds: 20000),
    tokenStore: sl<TokenStore>(),
  ).build();
  sl.registerSingleton<ApiClient>(ApiClient(dio, sl<AppConfig>().api));

  // Remote service
  sl.registerSingleton<RemoteExampleService>(
      RemoteExampleService(sl<ApiClient>()));

  // Bind abstract service to remote by default
  sl.registerSingleton<ExampleService>(sl<RemoteExampleService>());

  // Repository (concrete)
  sl.registerLazySingleton<ExampleRepository>(() => ExampleRepository(
        remote: sl<RemoteExampleService>(),
      ));

  // Signin
  sl.registerLazySingleton<SigninService>(
      () => RemoteSigninService(sl<ApiClient>()));
  sl.registerLazySingleton<SigninRepository>(
      () => SigninRepository(sl<SigninService>(), sl<TokenStore>()));
  sl.registerFactory<SigninCubit>(() => SigninCubit(sl<SigninRepository>()));
}

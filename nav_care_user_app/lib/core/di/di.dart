import 'package:get_it/get_it.dart';
import 'package:nav_care_user_app/data/service_creation/service_creation_repository.dart';
import 'package:nav_care_user_app/data/service_creation/services/remote_service_creation_service.dart';
import 'package:nav_care_user_app/data/service_creation/services/service_creation_service.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/api_client.dart';
import '../storage/secure_token_store.dart';
import '../storage/token_store.dart';

// example entity wires:
import '../../data/example/services/remote_service.dart';
import '../../data/example/services/service.dart';
import '../../data/example/repository.dart';
import '../../data/authentication/signin/services/signin_service.dart';
import '../../data/authentication/signin/services/remote_signin_service.dart';
import '../../data/authentication/signin/signin_repository.dart';
import '../../presentation/features/authentication/signin/viewmodel/signin_cubit.dart';
import '../../data/authentication/signup/services/signup_service.dart';
import '../../data/authentication/signup/services/remote_signup_service.dart';
import '../../data/authentication/signup/signup_repository.dart';
import '../../presentation/features/authentication/signup/viewmodel/signup_cubit.dart';

import '../../data/hospitals/hospitals_remote_service.dart';
import '../../data/hospitals/hospitals_repository.dart';
import '../../presentation/features/home/sections/hospitals_choice/viewmodel/hospitals_choice_cubit.dart';
import '../../data/doctors/doctors_remote_service.dart';
import '../../data/doctors/doctors_repository.dart';
import '../../presentation/features/home/sections/doctors_choice/viewmodel/doctors_choice_cubit.dart';

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

  // Hospitals list
  sl.registerLazySingleton<HospitalsRemoteService>(
      () => HospitalsRemoteService(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<HospitalsRepository>(
      () => HospitalsRepository(remoteService: sl<HospitalsRemoteService>()));
  sl.registerFactory<HospitalsChoiceCubit>(
      () => HospitalsChoiceCubit(repository: sl<HospitalsRepository>()));
  sl.registerLazySingleton<DoctorsRemoteService>(
      () => DoctorsRemoteService(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<DoctorsRepository>(
      () => DoctorsRepository(remoteService: sl<DoctorsRemoteService>()));
  sl.registerFactory<DoctorsChoiceCubit>(
      () => DoctorsChoiceCubit(repository: sl<DoctorsRepository>()));

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

  // Signup
  sl.registerLazySingleton<SignupService>(
      () => RemoteSignupService(sl<ApiClient>()));
  sl.registerLazySingleton<SignupRepository>(
      () => SignupRepository(sl<SignupService>(), sl<TokenStore>()));
  sl.registerFactory<SignupCubit>(() => SignupCubit(sl<SignupRepository>()));

  // Service creation
  sl.registerLazySingleton<ServiceCreationService>(
      () => RemoteServiceCreationService(sl<ApiClient>()));
  sl.registerLazySingleton<ServiceCreationRepository>(
      () => ServiceCreationRepository(sl<ServiceCreationService>()));
}

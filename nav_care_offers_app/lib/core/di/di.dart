import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/api_client.dart';
import '../storage/doctor_store.dart';
import '../storage/secure_doctor_store.dart';
import '../storage/secure_token_store.dart';
import '../storage/token_store.dart';

import '../../data/authentication/signin/services/signin_service.dart';
import '../../data/authentication/signin/services/remote_signin_service.dart';
import '../../data/authentication/signin/signin_repository.dart';
import '../../presentation/features/authentication/signin/viewmodel/signin_cubit.dart';
import '../../data/authentication/signup/services/signup_service.dart';
import '../../data/authentication/signup/services/remote_signup_service.dart';
import '../../data/authentication/signup/signup_repository.dart';
import '../../presentation/features/authentication/signup/viewmodel/signup_cubit.dart';
import '../../data/services/services/doctor_services_service.dart';
import '../../data/services/services/remote_doctor_services_service.dart';
import '../../data/services/doctor_services_repository.dart';
import '../../presentation/features/home/viewmodel/doctor_services_cubit.dart';

final sl = GetIt.instance;
Future<void> configureDependencies(AppConfig config) async {
  sl.registerSingleton<AppConfig>(config);

  // Storage
  sl.registerLazySingleton<TokenStore>(() => SecureTokenStore());
  sl.registerLazySingleton<DoctorStore>(() => SecureDoctorStore());

  final dio = DioClient(
    baseUrl: config.api.baseUrl,
    timeout: const Duration(milliseconds: 20000),
    tokenStore: sl<TokenStore>(),
  ).build();
  sl.registerSingleton<ApiClient>(ApiClient(dio, sl<AppConfig>().api));

  // Signin
  sl.registerLazySingleton<SigninService>(
      () => RemoteSigninService(sl<ApiClient>()));
  sl.registerLazySingleton<SigninRepository>(() => SigninRepository(
        sl<SigninService>(),
        sl<TokenStore>(),
        sl<DoctorStore>(),
      ));
  sl.registerFactory<SigninCubit>(() => SigninCubit(sl<SigninRepository>()));

  // Signup
  sl.registerLazySingleton<SignupService>(
      () => RemoteSignupService(sl<ApiClient>()));
  sl.registerLazySingleton<SignupRepository>(() => SignupRepository(
        sl<SignupService>(),
        sl<TokenStore>(),
        sl<DoctorStore>(),
      ));
  sl.registerFactory<SignupCubit>(() => SignupCubit(sl<SignupRepository>()));

  // Doctor services
  sl.registerLazySingleton<DoctorServicesService>(
      () => RemoteDoctorServicesService(sl<ApiClient>()));
  sl.registerLazySingleton<DoctorServicesRepository>(
      () => DoctorServicesRepository(sl<DoctorServicesService>()));
  sl.registerFactory<DoctorServicesCubit>(
      () => DoctorServicesCubit(sl<DoctorServicesRepository>()));
}

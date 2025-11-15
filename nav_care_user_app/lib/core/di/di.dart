import 'package:get_it/get_it.dart';
import 'package:nav_care_user_app/data/service_creation/service_creation_repository.dart';
import 'package:nav_care_user_app/data/service_creation/services/remote_service_creation_service.dart';
import 'package:nav_care_user_app/data/service_creation/services/service_creation_service.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/api_client.dart';
import '../storage/secure_token_store.dart';
import '../storage/token_store.dart';
import '../storage/user_store.dart';

// example entity wires:
import '../../data/example/services/remote_service.dart';
import '../../data/example/services/service.dart';
import '../../data/example/repository.dart';
import '../../data/authentication/signin/services/signin_service.dart';
import '../../data/authentication/signin/services/remote_signin_service.dart';
import '../../data/authentication/signin/signin_repository.dart';
import '../../data/authentication/logout/logout_repository.dart';
import '../../presentation/features/authentication/signin/viewmodel/signin_cubit.dart';
import '../../presentation/features/authentication/logout/viewmodel/logout_cubit.dart';
import '../../data/authentication/signup/services/signup_service.dart';
import '../../data/authentication/signup/services/remote_signup_service.dart';
import '../../data/authentication/signup/signup_repository.dart';
import '../../presentation/features/authentication/signup/viewmodel/signup_cubit.dart';

import '../../presentation/features/services/service_creation/viewmodel/service_creation_cubit.dart';
import '../../data/appointments/remote_appointment_service.dart';
import '../../data/appointments/appointment_repository.dart';
import '../../presentation/features/appointments/appointment_creation/viewmodel/appointment_creation_cubit.dart';
import '../../presentation/features/appointments/my_appointments/viewmodel/my_appointments_cubit.dart';
import '../../data/hospitals/hospital_creation/services/hospital_creation_service.dart';
import '../../data/hospitals/hospital_creation/services/remote_hospital_creation_service.dart';
import '../../data/hospitals/hospital_creation/hospital_creation_repository.dart';
import '../../data/hospitals/hospitals_remote_service.dart';
import '../../data/hospitals/hospitals_repository.dart';
import '../../presentation/features/home/sections/hospitals_choice/viewmodel/hospitals_choice_cubit.dart';
import '../../presentation/features/home/sections/featured_hospitals/viewmodel/featured_hospitals_cubit.dart';
import '../../data/doctors/doctors_remote_service.dart';
import '../../data/doctors/doctors_repository.dart';
import '../../presentation/features/home/sections/doctors_choice/viewmodel/doctors_choice_cubit.dart';
import '../../presentation/features/home/sections/featured_doctors/viewmodel/featured_doctors_cubit.dart';
import '../../data/search/search_remote_service.dart';
import '../../data/search/search_repository.dart';
import '../../presentation/features/search/viewmodel/search_cubit.dart';
import '../../data/advertising/services/advertising_remote_service.dart';
import '../../data/advertising/advertising_repository.dart';
import '../../data/service_offerings/service_offerings_remote_service.dart';
import '../../data/service_offerings/service_offerings_repository.dart';
import '../../presentation/features/home/sections/recent_service_offerings/viewmodel/recent_service_offerings_cubit.dart';

import '../../presentation/features/home/sections/ads/viewmodel/ads_section_cubit.dart';
import '../../data/users/user_remote_service.dart';
import '../../data/users/user_repository.dart';
import '../../presentation/features/profile/viewmodel/user_profile_cubit.dart';

final sl = GetIt.instance;
Future<void> configureDependencies(AppConfig config) async {
  sl.registerSingleton<AppConfig>(config);

  // Advertisings
  sl.registerLazySingleton<AdvertisingService>(
      () => AdvertisingRemoteService(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<AdvertisingRepository>(() =>
      AdvertisingRepositoryImpl(advertisingService: sl<AdvertisingService>()));
  sl.registerFactory<AdsSectionCubit>(() =>
      AdsSectionCubit(advertisingRepository: sl<AdvertisingRepository>()));

  // Storage
  sl.registerLazySingleton<TokenStore>(() => SecureTokenStore());
  sl.registerLazySingleton<UserStore>(() => SharedPrefsUserStore());

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
  sl.registerFactory<FeaturedHospitalsCubit>(
      () => FeaturedHospitalsCubit(repository: sl<HospitalsRepository>()));

  sl.registerLazySingleton<DoctorsRemoteService>(
      () => DoctorsRemoteService(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<DoctorsRepository>(
      () => DoctorsRepository(remoteService: sl<DoctorsRemoteService>()));
  sl.registerFactory<DoctorsChoiceCubit>(
      () => DoctorsChoiceCubit(repository: sl<DoctorsRepository>()));
  sl.registerFactory<FeaturedDoctorsCubit>(
      () => FeaturedDoctorsCubit(repository: sl<DoctorsRepository>()));
  sl.registerLazySingleton<SearchRemoteService>(
      () => SearchRemoteService(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<SearchRepository>(
      () => SearchRepository(remoteService: sl<SearchRemoteService>()));
  sl.registerFactory<SearchCubit>(
      () => SearchCubit(repository: sl<SearchRepository>()));
  sl.registerLazySingleton<ServiceOfferingsRemoteService>(
      () => ServiceOfferingsRemoteService(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<ServiceOfferingsRepository>(() =>
      ServiceOfferingsRepository(remote: sl<ServiceOfferingsRemoteService>()));
  sl.registerFactory<RecentServiceOfferingsCubit>(() =>
      RecentServiceOfferingsCubit(
          repository: sl<ServiceOfferingsRepository>()));
  sl.registerLazySingleton<UserRemoteService>(() => UserRemoteService(
      apiClient: sl<ApiClient>(), tokenStore: sl<TokenStore>()));
  sl.registerLazySingleton<UserRepository>(
      () => UserRepository(remoteService: sl<UserRemoteService>()));
  sl.registerFactory<UserProfileCubit>(() => UserProfileCubit(
      repository: sl<UserRepository>(), userStore: sl<UserStore>()));

  // Signin
  sl.registerLazySingleton<SigninService>(
      () => RemoteSigninService(sl<ApiClient>()));
  sl.registerLazySingleton<SigninRepository>(() =>
      SigninRepository(sl<SigninService>(), sl<TokenStore>(), sl<UserStore>()));
  sl.registerLazySingleton<LogoutRepository>(() => LogoutRepository(
      tokenStore: sl<TokenStore>(), userStore: sl<UserStore>()));
  sl.registerFactory<SigninCubit>(() => SigninCubit(sl<SigninRepository>()));
  sl.registerFactory<LogoutCubit>(() => LogoutCubit(sl<LogoutRepository>()));

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
  sl.registerFactory<ServiceCreationCubit>(
      () => ServiceCreationCubit(sl<ServiceCreationRepository>()));

  // Hospital creation
  sl.registerLazySingleton<HospitalCreationService>(
      () => RemoteHospitalCreationService(sl<ApiClient>()));
  sl.registerLazySingleton<HospitalCreationRepository>(
      () => HospitalCreationRepository(sl<HospitalCreationService>()));

  // Appointment creation
  sl.registerLazySingleton<RemoteAppointmentService>(
      () => RemoteAppointmentService(
            apiClient: sl<ApiClient>(),
            tokenStore: sl<TokenStore>(),
          ));

  sl.registerLazySingleton<AppointmentRepository>(() =>
      AppointmentRepository(remoteService: sl<RemoteAppointmentService>()));
  sl.registerFactory<AppointmentCreationCubit>(
      () => AppointmentCreationCubit(repository: sl<AppointmentRepository>()));
  sl.registerFactory<MyAppointmentsCubit>(
      () => MyAppointmentsCubit(sl<AppointmentRepository>()));
}

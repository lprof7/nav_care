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
import '../../data/services/services/doctor_services_service.dart';
import '../../data/services/services/remote_doctor_services_service.dart';
import '../../data/services/doctor_services_repository.dart';
import '../../presentation/features/home/viewmodel/doctor_services_cubit.dart';
import '../../data/hospitals/services/hospitals_service.dart';
import '../../data/hospitals/services/remote_hospitals_service.dart';
import '../../data/hospitals/hospitals_repository.dart';
import '../../data/hospitals/models/hospital.dart';
import '../../presentation/features/hospitals/viewmodel/hospital_list_cubit.dart';
import '../../presentation/features/hospitals/viewmodel/hospital_detail_cubit.dart';
import '../../presentation/features/hospitals/viewmodel/hospital_form_cubit.dart';
import '../../presentation/features/authentication/auth_cubit.dart'; // Import AuthCubit

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

  // Authentication
  sl.registerLazySingleton<SigninService>(
      () => RemoteSigninService(sl<ApiClient>()));
  sl.registerLazySingleton<SigninRepository>(() => SigninRepository(
        sl<SigninService>(),
        sl<TokenStore>(),
        sl<DoctorStore>(),
      ));
  sl.registerFactory<SigninCubit>(() => SigninCubit(sl<SigninRepository>()));
  sl.registerSingleton<AuthCubit>(AuthCubit(SecureDoctorStore())); // Register AuthCubit

  // Doctor services
  sl.registerLazySingleton<DoctorServicesService>(
      () => RemoteDoctorServicesService(sl<ApiClient>()));
  sl.registerLazySingleton<DoctorServicesRepository>(
      () => DoctorServicesRepository(sl<DoctorServicesService>()));
  sl.registerFactory<DoctorServicesCubit>(
      () => DoctorServicesCubit(sl<DoctorServicesRepository>()));

  // Hospitals
  sl.registerLazySingleton<HospitalsService>(
      () => RemoteHospitalsService(sl<ApiClient>()));
  sl.registerLazySingleton<HospitalsRepository>(
      () => HospitalsRepository(sl<HospitalsService>()));
  sl.registerFactory<HospitalListCubit>(
      () => HospitalListCubit(sl<HospitalsRepository>()));
  sl.registerFactoryParam<HospitalDetailCubit, Hospital, void>(
    (hospital, _) => HospitalDetailCubit(
      sl<HospitalsRepository>(),
      initialHospital: hospital,
    ),
  );
  sl.registerFactoryParam<HospitalFormCubit, Hospital?, void>(
    (hospital, _) => HospitalFormCubit(
      sl<HospitalsRepository>(),
      initialHospital: hospital,
    ),
  );
}

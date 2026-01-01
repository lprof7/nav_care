import 'package:get_it/get_it.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/viewmodel/clinics_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/viewmodel/doctors_cubit.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/api_client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/network_cubit.dart';
import '../storage/doctor_store.dart';
import '../storage/secure_doctor_store.dart';
import '../storage/secure_token_store.dart';
import '../storage/token_store.dart';
import '../translation/translation_service.dart';

import '../../data/authentication/signin/services/signin_service.dart';
import '../../data/authentication/signin/services/remote_signin_service.dart';
import '../../data/authentication/signin/signin_repository.dart';
import '../../presentation/features/authentication/signin/viewmodel/signin_cubit.dart';
import '../../data/authentication/signup/services/signup_service.dart';
import '../../data/authentication/signup/services/remote_signup_service.dart';
import '../../data/authentication/signup/signup_repository.dart';
import '../../presentation/features/authentication/signup/viewmodel/signup_cubit.dart';
import '../../data/authentication/reset_password/services/reset_password_service.dart';
import '../../data/authentication/reset_password/services/remote_reset_password_service.dart';
import '../../data/authentication/reset_password/reset_password_repository.dart';
import '../../presentation/features/authentication/reset_password/viewmodel/reset_password_cubit.dart';
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
import '../../presentation/features/clinics/viewmodel/clinic_detail_cubit.dart';
import '../../presentation/features/hospitals/viewmodel/hospital_form_cubit.dart';
import '../../presentation/features/hospitals/viewmodel/invite_doctor_cubit.dart';
import '../../data/clinics/services/clinics_service.dart';
import '../../data/clinics/services/remote_clinics_service.dart';
import '../../data/clinics/clinics_repository.dart';
import '../../presentation/features/clinics/clinic_creation/viewmodel/clinic_creation_cubit.dart'; // Import ClinicCreationCubit
import '../../data/doctors/services/doctors_service.dart';
import '../../data/doctors/services/remote_doctors_service.dart';
import '../../data/doctors/doctors_repository.dart';
import '../../presentation/features/authentication/auth_cubit.dart'; // Import AuthCubit
import '../../data/doctors/become_doctor_repository.dart';
import '../../data/doctors/services/become_doctor_service.dart';
import '../../data/doctors/services/remote_become_doctor_service.dart';
import '../../presentation/features/authentication/become_doctor/viewmodel/become_doctor_cubit.dart';
import '../../presentation/features/authentication/logout/viewmodel/logout_cubit.dart';
import '../../data/appointments/services/appointments_service.dart';
import '../../data/appointments/services/remote_appointments_service.dart';
import '../../data/appointments/appointments_repository.dart';
import '../../presentation/features/appointments/viewmodel/appointments_cubit.dart';
import '../../data/service_offerings/services/service_offerings_service.dart';
import '../../data/service_offerings/services/remote_service_offerings_service.dart';
import '../../data/service_offerings/service_offerings_repository.dart';
import '../../presentation/features/service_offerings/viewmodel/service_offerings_cubit.dart';
import '../../data/reviews/service_offering_reviews/service_offering_reviews_remote_service.dart';
import '../../data/reviews/service_offering_reviews/service_offering_reviews_repository.dart';
import '../../presentation/features/service_offerings/viewmodel/service_offering_reviews_cubit.dart';
import '../../data/reviews/hospital_reviews/hospital_reviews_remote_service.dart';
import '../../data/reviews/hospital_reviews/hospital_reviews_repository.dart';
import '../../presentation/features/hospitals/viewmodel/hospital_reviews_cubit.dart';
import '../../data/reviews/doctor_reviews/doctor_reviews_remote_service.dart';
import '../../data/reviews/doctor_reviews/doctor_reviews_repository.dart';
import '../../presentation/features/doctors/viewmodel/doctor_reviews_cubit.dart';
import '../../data/invitations/hospital_invitations_repository.dart';
import '../../data/invitations/hospital_invitations_service.dart';
import '../../data/invitations/remote_hospital_invitations_service.dart';
import '../../data/invitations/doctor_invitations_repository.dart';
import '../../data/invitations/doctor_invitations_service.dart';
import '../../data/invitations/remote_doctor_invitations_service.dart';
import '../../data/users/user_remote_service.dart';
import '../../data/users/user_repository.dart';
import '../../presentation/features/profile/viewmodel/user_profile_cubit.dart';
import '../../data/feedback/feedback_remote_service.dart';
import '../../data/feedback/feedback_repository.dart';
import '../../presentation/features/feedback/viewmodel/feedback_cubit.dart';
import '../../data/faq/faq_service.dart';
import '../../data/faq/remote_faq_service.dart';
import '../../data/faq/faq_repository.dart';
import '../../presentation/features/faq/viewmodel/faq_cubit.dart';
import '../../presentation/features/invitations/viewmodel/doctor_invitations_cubit.dart';
import '../../data/chat/chat_remote_service.dart';
import '../../data/chat/chat_repository.dart';
import '../../presentation/features/messages/viewmodel/conversations_cubit.dart';
import '../../presentation/features/messages/viewmodel/doctor_search_cubit.dart';
import '../../presentation/features/messages/viewmodel/chat_messages_cubit.dart';

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
    doctorStore: sl<DoctorStore>(),
    onUnauthorized: () async {
      if (sl.isRegistered<AuthCubit>()) {
        await sl<AuthCubit>().logout();
      }
    },
  ).build();
  sl.registerSingleton<ApiClient>(ApiClient(dio, sl<AppConfig>().api));
  sl.registerLazySingleton<TranslationService>(
      () => TranslationService(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<AuthCubit>(
      () => AuthCubit(sl<DoctorStore>(), sl<TokenStore>(), sl<ApiClient>()));
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerSingleton<NetworkCubit>(NetworkCubit(
    connectivity: sl<Connectivity>(),
    appConfig: sl<AppConfig>(),
  ));

  // Authentication
  sl.registerLazySingleton<SigninService>(
      () => RemoteSigninService(sl<ApiClient>()));
  sl.registerLazySingleton<SigninRepository>(() => SigninRepository(
        sl<SigninService>(),
        sl<TokenStore>(),
        sl<DoctorStore>(),
      ));
  sl.registerFactory<SigninCubit>(() => SigninCubit(sl<SigninRepository>()));
  sl.registerLazySingleton<SignupService>(
      () => RemoteSignupService(sl<ApiClient>()));
  sl.registerLazySingleton<SignupRepository>(() => SignupRepository(
        sl<SignupService>(),
        sl<TokenStore>(),
        sl<DoctorStore>(),
      ));
  sl.registerFactory<SignupCubit>(() => SignupCubit(sl<SignupRepository>()));
  sl.registerLazySingleton<ResetPasswordService>(
      () => RemoteResetPasswordService(sl<ApiClient>()));
  sl.registerLazySingleton<ResetPasswordRepository>(
      () => ResetPasswordRepository(service: sl<ResetPasswordService>()));
  sl.registerFactory<ResetPasswordCubit>(
      () => ResetPasswordCubit(sl<ResetPasswordRepository>()));
  sl.registerFactory<LogoutCubit>(() => LogoutCubit(sl<AuthCubit>()));
  sl.registerLazySingleton<UserRemoteService>(() => UserRemoteService(
      apiClient: sl<ApiClient>(), tokenStore: sl<TokenStore>()));
  sl.registerLazySingleton<UserRepository>(
      () => UserRepository(remoteService: sl<UserRemoteService>()));
  sl.registerFactory<UserProfileCubit>(() => UserProfileCubit(
        repository: sl<UserRepository>(),
        doctorStore: sl<DoctorStore>(),
        authCubit: sl<AuthCubit>(),
      ));

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

  // Service offerings
  sl.registerLazySingleton<ServiceOfferingsService>(
      () => RemoteServiceOfferingsService(sl<ApiClient>()));
  sl.registerLazySingleton<ServiceOfferingsRepository>(
      () => ServiceOfferingsRepository(sl<ServiceOfferingsService>()));
  sl.registerFactory<ServiceOfferingsCubit>(
      () => ServiceOfferingsCubit(sl<ServiceOfferingsRepository>()));
  sl.registerLazySingleton<ServiceOfferingReviewsRemoteService>(
      () => ServiceOfferingReviewsRemoteService(
            apiClient: sl<ApiClient>(),
            tokenStore: sl<TokenStore>(),
          ));
  sl.registerLazySingleton<ServiceOfferingReviewsRepository>(
      () => ServiceOfferingReviewsRepository(
            remote: sl<ServiceOfferingReviewsRemoteService>(),
          ));
  sl.registerFactory<ServiceOfferingReviewsCubit>(
      () => ServiceOfferingReviewsCubit(
            repository: sl<ServiceOfferingReviewsRepository>(),
          ));
  sl.registerLazySingleton<HospitalReviewsRemoteService>(
      () => HospitalReviewsRemoteService(
            apiClient: sl<ApiClient>(),
            tokenStore: sl<TokenStore>(),
          ));
  sl.registerLazySingleton<HospitalReviewsRepository>(() =>
      HospitalReviewsRepository(remote: sl<HospitalReviewsRemoteService>()));
  sl.registerFactory<HospitalReviewsCubit>(
      () => HospitalReviewsCubit(repository: sl<HospitalReviewsRepository>()));
  sl.registerLazySingleton<DoctorReviewsRemoteService>(
      () => DoctorReviewsRemoteService(
            apiClient: sl<ApiClient>(),
            tokenStore: sl<TokenStore>(),
          ));
  sl.registerLazySingleton<DoctorReviewsRepository>(
      () => DoctorReviewsRepository(remote: sl<DoctorReviewsRemoteService>()));
  sl.registerFactory<DoctorReviewsCubit>(
      () => DoctorReviewsCubit(repository: sl<DoctorReviewsRepository>()));

  // Invitations
  sl.registerLazySingleton<HospitalInvitationsService>(
      () => RemoteHospitalInvitationsService(sl<ApiClient>()));
  sl.registerLazySingleton<HospitalInvitationsRepository>(
      () => HospitalInvitationsRepository(sl<HospitalInvitationsService>()));
  sl.registerLazySingleton<DoctorInvitationsService>(
      () => RemoteDoctorInvitationsService(sl<ApiClient>()));
  sl.registerLazySingleton<DoctorInvitationsRepository>(
      () => DoctorInvitationsRepository(sl<DoctorInvitationsService>()));
  sl.registerFactory<DoctorInvitationsCubit>(
      () => DoctorInvitationsCubit(sl<DoctorInvitationsRepository>()));

  // Clinics
  sl.registerLazySingleton<ClinicsService>(
      () => RemoteClinicsService(sl<ApiClient>()));
  sl.registerLazySingleton<ClinicsRepository>(
      () => ClinicsRepository(sl<ClinicsService>()));
  sl.registerFactory<ClinicsCubit>(
    () => ClinicsCubit(sl<ClinicsRepository>()),
  );
  sl.registerFactory<ClinicCreationCubit>(() => ClinicCreationCubit(
        sl<ClinicsRepository>(),
        sl<TranslationService>(),
      )); // Register ClinicCreationCubit

  // Appointments
  sl.registerLazySingleton<AppointmentsService>(
      () => RemoteAppointmentsService(sl<ApiClient>()));
  sl.registerLazySingleton<AppointmentsRepository>(
      () => AppointmentsRepository(sl<AppointmentsService>()));
  sl.registerFactory<AppointmentsCubit>(
      () => AppointmentsCubit(sl<AppointmentsRepository>()));

  // Doctors
  sl.registerLazySingleton<DoctorsService>(
      () => RemoteDoctorsService(sl<ApiClient>()));
  sl.registerLazySingleton<DoctorsRepository>(
      () => DoctorsRepository(sl<DoctorsService>()));
  sl.registerFactory<DoctorsCubit>(() => DoctorsCubit(sl<DoctorsRepository>()));
  sl.registerFactory<InviteDoctorCubit>(
      () => InviteDoctorCubit(sl<DoctorsRepository>()));
  sl.registerLazySingleton<BecomeDoctorService>(
      () => RemoteBecomeDoctorService(sl<ApiClient>()));
  sl.registerLazySingleton<BecomeDoctorRepository>(() => BecomeDoctorRepository(
        sl<BecomeDoctorService>(),
        sl<TokenStore>(),
        sl<DoctorStore>(),
      ));
  sl.registerFactory<BecomeDoctorCubit>(() => BecomeDoctorCubit(
        sl<BecomeDoctorRepository>(),
        sl<AuthCubit>(),
        sl<TranslationService>(),
      ));
  sl.registerFactoryParam<HospitalDetailCubit, Hospital, void>(
    (hospital, _) => HospitalDetailCubit(
      sl<HospitalsRepository>(),
      sl<TokenStore>(),
      initialHospital: hospital,
      clinicsRepository: sl<ClinicsRepository>(),
      doctorsRepository: sl<DoctorsRepository>(),
      offeringsRepository: sl<ServiceOfferingsRepository>(),
      invitationsRepository: sl<HospitalInvitationsRepository>(),
    ),
  );
  sl.registerFactoryParam<ClinicDetailCubit, Hospital, void>(
    (hospital, _) => ClinicDetailCubit(
      sl<HospitalsRepository>(),
      sl<TokenStore>(),
      initialHospital: hospital,
      clinicsRepository: sl<ClinicsRepository>(),
      doctorsRepository: sl<DoctorsRepository>(),
      offeringsRepository: sl<ServiceOfferingsRepository>(),
      invitationsRepository: sl<HospitalInvitationsRepository>(),
    ),
  );
  sl.registerFactoryParam<HospitalFormCubit, Hospital?, void>(
    (hospital, _) => HospitalFormCubit(
      sl<HospitalsRepository>(),
      translationService: sl<TranslationService>(),
      initialHospital: hospital,
    ),
  );

  // Feedback
  sl.registerLazySingleton<FeedbackRemoteService>(() => FeedbackRemoteService(
      apiClient: sl<ApiClient>(), tokenStore: sl<TokenStore>()));
  sl.registerLazySingleton<FeedbackRepository>(
      () => FeedbackRepository(remoteService: sl<FeedbackRemoteService>()));
  sl.registerFactory<FeedbackCubit>(
      () => FeedbackCubit(repository: sl<FeedbackRepository>()));
  sl.registerLazySingleton<FaqService>(() => RemoteFaqService(sl<ApiClient>()));
  sl.registerLazySingleton<FaqRepository>(
      () => FaqRepository(sl<FaqService>()));
  sl.registerFactory<FaqCubit>(() => FaqCubit(sl<FaqRepository>()));

  // Chat
  sl.registerLazySingleton<ChatRemoteService>(() => ChatRemoteService(
        apiClient: sl<ApiClient>(),
        tokenStore: sl<TokenStore>(),
      ));
  sl.registerLazySingleton<ChatRepository>(
      () => ChatRepository(remoteService: sl<ChatRemoteService>()));
  sl.registerLazySingleton<ConversationsCubit>(
      () => ConversationsCubit(repository: sl<ChatRepository>()));
  sl.registerFactory<DoctorSearchCubit>(
      () => DoctorSearchCubit(repository: sl<DoctorsRepository>()));
  sl.registerFactory<ChatMessagesCubit>(
      () => ChatMessagesCubit(repository: sl<ChatRepository>()));
}

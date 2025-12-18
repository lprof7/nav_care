import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/data/authentication/models.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/become_doctor/view/become_doctor_page.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/signin/view/signin_page.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/hospital_detail_page.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/hospital_form_page.dart';
import 'package:nav_care_offers_app/presentation/features/shell/view/nav_shell_page.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/clinic_creation/view/clinic_form_page.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/clinic_creation/viewmodel/clinic_creation_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/view/clinics_list_page.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/viewmodel/clinics_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/view/doctor_detail_page.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/view/doctors_list_page.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/viewmodel/doctors_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/view/service_offerings_page.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/view/service_offering_form_page.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/view/service_offering_detail_page.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offerings_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/reset_password/view/reset_password_code_page.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/reset_password/view/reset_password_email_page.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/reset_password/view/reset_password_new_password_page.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/reset_password/viewmodel/reset_password_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/hospital_shell_page.dart';
import 'package:nav_care_offers_app/presentation/features/profile/view/edit_user_profile_page.dart';
import 'package:nav_care_offers_app/presentation/features/profile/view/forgot_password_page.dart';
import 'package:nav_care_offers_app/presentation/features/profile/view/update_password_page.dart';
import 'package:nav_care_offers_app/presentation/features/profile/viewmodel/user_profile_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/signup/view/signup_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/presentation/features/faq/view/faq_page.dart';
import 'package:nav_care_offers_app/presentation/features/contact/view/contact_page.dart';
import 'package:nav_care_offers_app/presentation/features/about/view/about_page.dart';

enum AppRoute {
  root('/'),
  signIn('/signin'),
  signUp('/signup'),
  becomeDoctor('/become-doctor'),
  resetPasswordEmail('/reset-password/email'),
  resetPasswordCode('/reset-password/code'),
  resetPasswordNewPassword('/reset-password/new-password'),
  home('/home'),
  profileEdit('/profile/edit'),
  profilePassword('/profile/password'),
  profileForgotPassword('/profile/forgot-password'),
  faq('/faq'),
  contact('/contact'),
  about('/about'),
  hospitalNew('/hospitals/new'),
  hospitalDetail('/hospitals/:id'),
  hospitalEdit('/hospitals/:id/edit'),
  hospitalShell('/hospitals/:id/app'),
  hospitalClinics('/hospitals/:hospitalId/clinics'),
  hospitalClinicsNew('/hospitals/:hospitalId/clinics/new'),
  hospitalDoctors('/hospitals/:hospitalId/doctors'),
  doctorDetail('/doctors/:doctorId/detail'),
  hospitalServiceOfferings('/hospitals/:hospitalId/service-offerings'),
  hospitalServiceOfferingsNew('/hospitals/:hospitalId/service-offerings/new'),
  hospitalServiceOfferingsEdit('/hospitals/:hospitalId/service-offerings/:offeringId/edit'),
  hospitalServiceOfferingsDetail('/hospitals/:hospitalId/service-offerings/:offeringId/detail');

  const AppRoute(this.path);

  final String path;
}

GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoute.root.path,
        builder: (ctx, st) => const SigninPage(),
      ),
      GoRoute(
        path: AppRoute.signIn.path,
        builder: (ctx, st) => const SigninPage(),
      ),
      GoRoute(
        path: AppRoute.signUp.path,
        builder: (ctx, st) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoute.becomeDoctor.path,
        builder: (ctx, st) => BecomeDoctorPage(user: st.extra as User?),
      ),
      GoRoute(
        path: AppRoute.home.path,
        builder: (ctx, st) => const NavShellPage(),
      ),
      GoRoute(
        path: AppRoute.resetPasswordEmail.path,
        builder: (ctx, st) => BlocProvider(
          create: (_) => sl<ResetPasswordCubit>(),
          child: const ResetPasswordEmailPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.resetPasswordCode.path,
        builder: (ctx, st) {
          final extra = st.extra;
          if (extra is ResetPasswordCubit) {
            return BlocProvider.value(
              value: extra,
              child: const ResetPasswordCodePage(),
            );
          }
          return BlocProvider(
            create: (_) => sl<ResetPasswordCubit>(),
            child: const ResetPasswordEmailPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoute.resetPasswordNewPassword.path,
        builder: (ctx, st) {
          final extra = st.extra;
          if (extra is ResetPasswordCubit) {
            return BlocProvider.value(
              value: extra,
              child: const ResetPasswordNewPasswordPage(),
            );
          }
          return BlocProvider(
            create: (_) => sl<ResetPasswordCubit>(),
            child: const ResetPasswordEmailPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoute.profileEdit.path,
        builder: (ctx, st) {
          final extraCubit = st.extra;
          if (extraCubit is UserProfileCubit) {
            return BlocProvider<UserProfileCubit>.value(
              value: extraCubit,
              child: const EditUserProfilePage(),
            );
          }
          return BlocProvider(
            create: (_) => sl<UserProfileCubit>()
              ..loadProfile()
              ..listenToAuth(),
            child: const EditUserProfilePage(),
          );
        },
      ),
      GoRoute(
        path: AppRoute.profilePassword.path,
        builder: (ctx, st) {
          final extraCubit = st.extra;
          if (extraCubit is UserProfileCubit) {
            return BlocProvider<UserProfileCubit>.value(
              value: extraCubit,
              child: const UpdatePasswordPage(),
            );
          }
          return BlocProvider(
            create: (_) => sl<UserProfileCubit>()
              ..loadProfile()
              ..listenToAuth(),
            child: const UpdatePasswordPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoute.profileForgotPassword.path,
        builder: (ctx, st) {
          final extraCubit = st.extra;
          if (extraCubit is UserProfileCubit) {
            return BlocProvider<UserProfileCubit>.value(
              value: extraCubit,
              child: const ForgotPasswordPage(),
            );
          }
          return BlocProvider(
            create: (_) => sl<UserProfileCubit>()
              ..loadProfile()
              ..listenToAuth(),
            child: const ForgotPasswordPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoute.faq.path,
        builder: (ctx, st) => const FaqPage(),
      ),
      GoRoute(
        path: AppRoute.contact.path,
        builder: (ctx, st) => const ContactPage(),
      ),
      GoRoute(
        path: AppRoute.about.path,
        builder: (ctx, st) => const AboutPage(),
      ),
      GoRoute(
        path: AppRoute.hospitalNew.path,
        builder: (ctx, st) => const HospitalFormPage(),
      ),
      GoRoute(
        path: AppRoute.hospitalDetail.path,
        builder: (ctx, st) {
          final id = st.pathParameters['id'] ?? '';
          final passed = st.extra;
          final hospital = passed is Hospital
              ? passed
              : sl<HospitalsRepository>().findById(id);
          return HospitalDetailPage(
            hospitalId: id,
            initial: hospital,
          );
        },
      ),
      GoRoute(
        path: AppRoute.hospitalShell.path,
        builder: (ctx, st) {
          final id = st.pathParameters['id'] ?? '';
          final passed = st.extra;
          final hospital = passed is Hospital
              ? passed
              : sl<HospitalsRepository>().findById(id);
          if (hospital == null) {
            return HospitalDetailPage(hospitalId: id);
          }
          return HospitalShellPage(hospital: hospital);
        },
      ),
      GoRoute(
        path: AppRoute.hospitalEdit.path,
        builder: (ctx, st) {
          final id = st.pathParameters['id'] ?? '';
          final passed = st.extra;
          final hospital = passed is Hospital
              ? passed
              : sl<HospitalsRepository>().findById(id);
          return HospitalFormPage(initial: hospital);
        },
      ),
      GoRoute(
        path: AppRoute.hospitalClinics.path,
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          return BlocProvider(
            create: (context) => sl<ClinicsCubit>(),
            child: ClinicsListPage(hospitalId: hospitalId),
          );
        },
      ),
      GoRoute(
        path: AppRoute.hospitalClinicsNew.path,
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          return BlocProvider(
            create: (context) => sl<ClinicCreationCubit>(),
            child: ClinicFormPage(hospitalId: hospitalId),
          );
        },
      ),
      GoRoute(
        path: AppRoute.hospitalDoctors.path,
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          return BlocProvider(
            create: (context) => sl<DoctorsCubit>(),
            child: DoctorsListPage(hospitalId: hospitalId),
          );
        },
      ),
      GoRoute(
        path: AppRoute.doctorDetail.path,
        name: AppRoute.doctorDetail.name, // Add name for named routing
        builder: (ctx, st) {
          final doctorId = st.pathParameters['doctorId'] ?? '';
          final extra = st.extra;
          DoctorModel? doctor;
          String? hospitalId;
          List<DoctorModel>? hospitalDoctors;
          List<HospitalInvitation>? invitations;
          if (extra is DoctorModel) {
            doctor = extra;
          } else if (extra is Map) {
            final map = extra.cast<dynamic, dynamic>();
            final doc = map['doctor'];
            if (doc is DoctorModel) doctor = doc;
            hospitalId = map['hospitalId']?.toString();
            hospitalDoctors = (map['hospitalDoctors'] as List?)
                ?.whereType<DoctorModel>()
                .toList();
            invitations = (map['invitations'] as List?)
                ?.whereType<HospitalInvitation>()
                .toList();
          }
          return DoctorDetailPage(
            doctorId: doctorId,
            initial: doctor,
            hospitalId: hospitalId,
            hospitalDoctors: hospitalDoctors,
            invitations: invitations,
          );
        },
      ),
      GoRoute(
        path: AppRoute.hospitalServiceOfferings.path,
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          return BlocProvider(
            create: (context) => sl<ServiceOfferingsCubit>(),
            child: ServiceOfferingsPage(hospitalId: hospitalId),
          );
        },
      ),
      GoRoute(
        path: AppRoute.hospitalServiceOfferingsNew.path,
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          return ServiceOfferingFormPage(hospitalId: hospitalId);
        },
      ),
      GoRoute(
        path: AppRoute.hospitalServiceOfferingsEdit.path,
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          final offering = st.extra;
          return ServiceOfferingFormPage(
            hospitalId: hospitalId,
            initial: offering is ServiceOffering ? offering : null,
          );
        },
      ),
      GoRoute(
        path: AppRoute.hospitalServiceOfferingsDetail.path,
        builder: (ctx, st) {
          final hospitalId = st.pathParameters['hospitalId'] ?? '';
          final offeringId = st.pathParameters['offeringId'] ?? '';
          final offering = st.extra;
          return ServiceOfferingDetailPage(
            hospitalId: hospitalId,
            offeringId: offeringId,
            initial: offering is ServiceOffering ? offering : null,
            allowDelete: true,
          );
        },
      ),
    ],
  );
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/presentation/features/authentication/signin/view/signin_page.dart';
import 'package:nav_care_user_app/presentation/features/faq/view/faq_page.dart';
import 'package:nav_care_user_app/presentation/features/about/view/about_page.dart';
import 'package:nav_care_user_app/presentation/features/contact/view/contact_page.dart';
import 'package:nav_care_user_app/presentation/features/shell/view/nav_shell_page.dart';
import 'package:nav_care_user_app/presentation/features/profile/view/edit_user_profile_page.dart';
import 'package:nav_care_user_app/presentation/features/profile/view/forgot_password_page.dart';
import 'package:nav_care_user_app/presentation/features/profile/view/update_password_page.dart';
import 'package:nav_care_user_app/presentation/features/profile/view/user_profile_page.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_cubit.dart';
import 'package:nav_care_user_app/presentation/features/authentication/session/auth_session_cubit.dart';
import 'package:nav_care_user_app/presentation/features/authentication/reset_password/view/reset_password_code_page.dart';
import 'package:nav_care_user_app/presentation/features/authentication/reset_password/view/reset_password_email_page.dart';
import 'package:nav_care_user_app/presentation/features/authentication/reset_password/view/reset_password_new_password_page.dart';
import 'package:nav_care_user_app/presentation/features/authentication/reset_password/viewmodel/reset_password_cubit.dart';
import 'package:nav_care_user_app/presentation/features/authentication/social/view/social_complete_profile_page.dart';
import 'package:nav_care_user_app/data/authentication/google/google_user.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/view/service_offering_detail_page.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';

import '../../presentation/features/authentication/signup/view/signup_page.dart';
import '../../presentation/features/appointments/appointment_creation/view/add_appointment_page.dart';
import '../../presentation/features/doctors/view/doctor_detail_page.dart';
import '../../presentation/features/hospitals/view/hospital_detail_page.dart';
import '../../presentation/features/notifications/view/notifications_page.dart';
import '../di/di.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const NavShellPage()),
    GoRoute(path: '/signin', builder: (ctx, st) => const SigninPage()),
    GoRoute(path: '/signup', builder: (ctx, st) => const SignupPage()),
    GoRoute(
      path: '/reset-password/email',
      builder: (ctx, st) => BlocProvider(
        create: (_) => sl<ResetPasswordCubit>(),
        child: const ResetPasswordEmailPage(),
      ),
    ),
    GoRoute(
      path: '/reset-password/code',
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
      path: '/reset-password/new-password',
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
      path: '/signup/social',
      builder: (ctx, st) {
        final extra = st.extra;
        if (extra is GoogleAccount) {
          return SocialCompleteProfilePage(account: extra);
        }
        return const SigninPage();
      },
    ),
    GoRoute(path: '/home', builder: (ctx, st) => const NavShellPage()),
    GoRoute(path: '/appointments', builder: (ctx, st) => const NavShellPage(initialIndex: 1)),
    GoRoute(path: '/faq', builder: (ctx, st) => const FaqPage()),
    GoRoute(path: '/about', builder: (ctx, st) => const AboutPage()),
    GoRoute(path: '/contact', builder: (ctx, st) => const ContactPage()),
    GoRoute(
      path: '/notifications',
      builder: (ctx, st) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/doctors/:id',
      builder: (ctx, st) {
        final doctorId = st.pathParameters['id'] ?? '';
        return DoctorDetailPage(doctorId: doctorId);
      },
    ),
    GoRoute(
        path: '/appointments/create',
        builder: (ctx, st) {
          final serviceOfferingId = st.extra as String;
          return AddAppointmentPage(serviceOfferingId: serviceOfferingId);
        }),
    GoRoute(
      path: '/hospitals/:id',
      builder: (ctx, st) {
        final hospitalId = st.pathParameters['id'] ?? '';
        return HospitalDetailPage(hospitalId: hospitalId);
      },
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (ctx, st) {
        final cubit = sl<UserProfileCubit>();
        if (sl<AuthSessionCubit>().state.isAuthenticated) {
          cubit.loadProfile();
        }
        return BlocProvider.value(
          value: cubit,
          child: const EditUserProfilePage(),
        );
      },
    ),
    GoRoute(
      path: '/profile/password',
      builder: (ctx, st) {
        final cubit = sl<UserProfileCubit>();
        if (sl<AuthSessionCubit>().state.isAuthenticated) {
          cubit.loadProfile();
        }
        return BlocProvider.value(
          value: cubit,
          child: const UpdatePasswordPage(),
        );
      },
    ),
    GoRoute(
      path: '/profile/forgot-password',
      builder: (ctx, st) {
        final cubit = sl<UserProfileCubit>();
        return BlocProvider.value(
          value: cubit,
          child: const ForgotPasswordPage(),
        );
      },
    ),
    GoRoute(
      path: '/service-offering/:id',
      builder: (ctx, st) {
        final id = st.pathParameters['id'] ?? '';
        SearchResultItem? item;
        String? baseUrl;
        final extra = st.extra;
        if (extra is Map) {
          final map =
              extra.map((key, value) => MapEntry(key.toString(), value));
          if (map['item'] is SearchResultItem) {
            item = map['item'] as SearchResultItem;
          }
          if (map['baseUrl'] is String) {
            baseUrl = map['baseUrl'] as String;
          }
        }
        final resolvedItem = item ??
            SearchResultItem(
              id: id,
              type: SearchResultType.serviceOffering,
              title: '',
            );
        final resolvedBaseUrl = baseUrl ?? sl<AppConfig>().api.baseUrl;
        return ServiceOfferingDetailPage(
          item: resolvedItem,
          baseUrl: resolvedBaseUrl,
          offeringId: id,
        );
      },
    ),
  ],
);

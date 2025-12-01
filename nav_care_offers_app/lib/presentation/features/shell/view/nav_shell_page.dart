import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/users/models/user_profile_model.dart';
import 'package:nav_care_offers_app/presentation/features/appointments/view/appointments_page.dart';
import 'package:nav_care_offers_app/presentation/features/home/view/home_page.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/hospitals_feature_screen.dart';
import 'package:nav_care_offers_app/presentation/features/profile/view/user_profile_page.dart';
import 'package:nav_care_offers_app/presentation/features/profile/viewmodel/user_profile_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/profile/viewmodel/user_profile_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_app_bar.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_destination.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_drawer.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_nav_bar.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/logout/viewmodel/logout_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';

import '../viewmodel/nav_shell_cubit.dart';

class NavShellPage extends StatelessWidget {
  const NavShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavShellCubit()),
        BlocProvider(create: (_) => sl<LogoutCubit>()),
        BlocProvider<UserProfileCubit>(
          create: (_) => sl<UserProfileCubit>()
            ..loadProfile()
            ..listenToAuth(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LogoutCubit, LogoutState>(
            listener: (context, state) {
              if (state is LogoutSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('logout_success_message'.tr()),
                  ),
                );
              } else if (state is LogoutFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'logout_error_message'.tr(
                        namedArgs: {'message': state.message},
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          BlocListener<AuthCubit, AuthState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) {
              final profileCubit = context.read<UserProfileCubit>();
              if (state.status == AuthStatus.authenticated) {
                profileCubit.loadProfile();
              } else if (state.status == AuthStatus.unauthenticated) {
                profileCubit.resetProfile();
              }
            },
          ),
        ],
        child: BlocBuilder<NavShellCubit, NavShellState>(
          builder: (context, state) {
            final cubit = context.read<NavShellCubit>();
            final destinations = _buildDestinations(context);
            final logoutState = context.watch<LogoutCubit>().state;
            final isLogoutLoading = logoutState is LogoutInProgress;
            final profileState = context.watch<UserProfileCubit>().state;
            final UserProfileModel? profile =
                profileState.loadStatus == ProfileLoadStatus.success ||
                        profileState.updateStatus == ProfileUpdateStatus.success
                    ? profileState.profile
                    : null;
            final authState = context.watch<AuthCubit>().state;
            final isAuthenticated = authState.status == AuthStatus.authenticated;
            final sessionUser = authState.user;
            final appConfig = sl<AppConfig>();
            final avatarPath = profile?.avatarUrl(appConfig.api.baseUrl) ?? sessionUser?.profilePicture;
            final userName = profile?.name ?? sessionUser?.name;
            final userEmail = profile?.email ?? sessionUser?.email;
            final userPhone = profile?.phone ?? sessionUser?.phone;

            return Scaffold(
              appBar: const NavShellAppBar(
                notificationCount: 0,
              ),
              drawer: NavShellDrawer(
                selectedIndex: state.currentIndex,
                destinations: destinations,
                onDestinationSelected: cubit.setTab,
                onVerifyTap: () {},
                currentLocale: context.locale,
                supportedLocales: context.supportedLocales,
                onLocaleChanged: (locale) async {
                  if (locale == context.locale) return;
                  await context.setLocale(locale);
                },
                onLogoutTap: () => context.read<LogoutCubit>().logout(),
                isLogoutLoading: isLogoutLoading,
                userName: userName,
                userEmail: userEmail,
                userPhone: userPhone,
                userAvatar: avatarPath,
                isProfileLoading: profileState.loadStatus == ProfileLoadStatus.loading,
                profileError: profileState.loadStatus == ProfileLoadStatus.failure
                    ? profileState.errorMessage
                    : null,
                onProfileRetry: () => context.read<UserProfileCubit>().loadProfile(),
                onProfileTap: () {
                  Navigator.of(context).pop();
                  cubit.setTab(destinations.length - 1);
                },
                isAuthenticated: isAuthenticated,
                onSignInTap: () => context.go('/signin'),
                onFaqTap: () => context.push('/faq'),
                onContactTap: () => context.push('/contact'),
                onSettingsTap: () {},
                onAboutTap: () => context.push('/about'),
                onFeedbackTap: () {},
                onSupportTap: () {},
              ),
              body: IndexedStack(
                index: state.currentIndex,
                children: destinations.map((destination) => destination.content).toList(),
              ),
              bottomNavigationBar: NavShellNavBar(
                currentIndex: state.currentIndex,
                destinations: destinations,
                onTap: cubit.setTab,
              ),
            );
          },
        ),
      ),
    );
  }

  List<NavShellDestination> _buildDestinations(BuildContext context) {
    return [
      NavShellDestination(
        label: 'shell.nav_home'.tr(),
        icon: Icons.home_rounded,
        content: const HomePage(),
        badgeLabel: 'shell.badge_new'.tr(),
      ),
      NavShellDestination(
        label: 'shell.nav_appointments'.tr(),
        icon: Icons.calendar_today_rounded,
        content: const AppointmentsPage(),
      ),
      NavShellDestination(
        label: 'shell.nav_hospitals'.tr(),
        icon: Icons.local_hospital_rounded,
        content: const HospitalsFeatureScreen(),
      ),
      NavShellDestination(
        label: 'shell.nav_profile'.tr(),
        icon: Icons.person_rounded,
        content: const UserProfilePage(),
      ),
    ];
  }
}

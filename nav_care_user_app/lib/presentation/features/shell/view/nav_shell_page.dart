import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/presentation/features/appointments/my_appointments/view/my_appointments_page.dart';
import 'package:nav_care_user_app/presentation/features/authentication/logout/viewmodel/logout_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/view/home_page.dart';
import 'package:nav_care_user_app/presentation/features/profile/view/user_profile_page.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_cubit.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_state.dart';
import 'package:nav_care_user_app/presentation/features/search/view/search_page.dart';
import 'package:nav_care_user_app/presentation/shared/ui/shell/nav_shell_app_bar.dart';
import 'package:nav_care_user_app/presentation/shared/ui/shell/nav_shell_destination.dart';
import 'package:nav_care_user_app/presentation/shared/ui/shell/nav_shell_drawer.dart';
import 'package:nav_care_user_app/presentation/shared/ui/shell/nav_shell_nav_bar.dart';

import '../viewmodel/nav_shell_cubit.dart';

class NavShellPage extends StatelessWidget {
  const NavShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavShellCubit()),
        BlocProvider(create: (_) => sl<LogoutCubit>()),
        BlocProvider(create: (_) => sl<UserProfileCubit>()..loadProfile()),
      ],
      child: BlocListener<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            context.go('/signin');
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
        child: BlocBuilder<NavShellCubit, NavShellState>(
          builder: (context, state) {
            final cubit = context.read<NavShellCubit>();
            final destinations = _buildDestinations(context);
            final logoutState = context.watch<LogoutCubit>().state;
            final isLogoutLoading = logoutState is LogoutInProgress;
            final profileState = context.watch<UserProfileCubit>().state;
            final profile = profileState.profile;
            final appConfig = sl<AppConfig>();
            final avatarPath = profile?.avatarUrl(appConfig.api.baseUrl);

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
                userName: profile?.name,
                userEmail: profile?.email,
                userPhone: profile?.phone,
                userAvatar: avatarPath,
                isProfileLoading:
                    profileState.status == UserProfileStatus.loading ||
                        profileState.status == UserProfileStatus.initial,
                profileError: profileState.status == UserProfileStatus.failure
                    ? profileState.errorMessage
                    : null,
                onProfileRetry: () =>
                    context.read<UserProfileCubit>().loadProfile(),
                onProfileTap: () {
                  Navigator.of(context).pop();
                  cubit.setTab(destinations.length - 1);
                },
              ),
              body: IndexedStack(
                index: state.currentIndex,
                children: destinations
                    .map((destination) => destination.content)
                    .toList(),
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
        content: const MyAppointmentsPage(),
      ),
      NavShellDestination(
        label: 'shell.nav_services'.tr(),
        icon: Icons.monitor_heart,
        content: const _PlaceholderSection(titleKey: 'shell.nav_services'),
      ),
      NavShellDestination(
        label: 'shell.nav_search'.tr(),
        icon: Icons.search_rounded,
        content: const SearchPage(),
      ),
      NavShellDestination(
        label: 'shell.nav_profile'.tr(),
        icon: Icons.person_rounded,
        content: const UserProfilePage(),
      ),
    ];
  }
}

class _PlaceholderSection extends StatelessWidget {
  final String titleKey;
  const _PlaceholderSection({required this.titleKey});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        titleKey.tr(),
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

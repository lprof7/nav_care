import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/users/models/user_profile_model.dart';
import 'package:nav_care_offers_app/presentation/features/appointments/view/appointments_page.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/view/hospitals_feature_screen.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/view/my_service_offerings_page.dart';
import 'package:nav_care_offers_app/presentation/features/profile/view/user_profile_page.dart';
import 'package:nav_care_offers_app/presentation/features/profile/viewmodel/user_profile_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/profile/viewmodel/user_profile_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_app_bar.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_destination.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_drawer.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/logout/viewmodel/logout_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/theme_mode_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/feedback/viewmodel/feedback_cubit.dart';
import 'package:feedback/feedback.dart';

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
        BlocProvider(create: (_) => sl<FeedbackCubit>()),
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
          BlocListener<AuthCubit, AuthState>(
            listenWhen: (prev, curr) =>
                prev.status != curr.status &&
                curr.status == AuthStatus.unauthenticated,
            listener: (context, state) {
              context.go('/signin');
            },
          ),
        ],
        child: BlocBuilder<NavShellCubit, NavShellState>(
          builder: (context, state) {
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
            final themeMode = context.watch<ThemeModeCubit>().state;

            return Scaffold(
              appBar: const NavShellAppBar(
                notificationCount: 0,
              ),
              drawer: NavShellDrawer(
                selectedIndex: state.currentIndex,
                destinations: destinations,
                onDestinationSelected: (index) =>
                    _onDestinationSelected(context, index),
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
                  _onDestinationSelected(context, destinations.length - 1);
                },
                isAuthenticated: isAuthenticated,
                onSignInTap: () => context.go('/signin'),
                onFaqTap: () => context.push('/faq'),
                onContactTap: () => context.push('/contact'),
                onSettingsTap: () {},
                onAboutTap: () => context.push('/about'),
                onFeedbackTap: () => _onFeedbackTap(context),
                onSupportTap: () => context.push('/contact'),
                themeMode: themeMode,
                onThemeToggle: () => context.read<ThemeModeCubit>().toggle(),
              ),
              body: IndexedStack(
                index: state.currentIndex,
                children: destinations.map((destination) => destination.content).toList(),
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
        label: 'shell.nav_hospitals'.tr(),
        icon: Icons.local_hospital_rounded,
        content: const HospitalsFeatureScreen(),
      ),
      NavShellDestination(
        label: 'service_offerings.list.title'.tr(),
        icon: Icons.medical_services_rounded,
        content: const MyServiceOfferingsPage(),
      ),
      NavShellDestination(
        label: 'shell.nav_appointments'.tr(),
        icon: Icons.calendar_today_rounded,
        content: const AppointmentsPage(),
      ),
      NavShellDestination(
        label: 'shell.nav_profile'.tr(),
        icon: Icons.person_rounded,
        content: const UserProfilePage(),
      ),
    ];
  }

  Future<void> _onDestinationSelected(
    BuildContext context,
    int index,
  ) async {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state.status == AuthStatus.authenticated) {
      await authCubit.verifyTokenValidity();
      if (authCubit.state.status != AuthStatus.authenticated) return;
    }
    context.read<NavShellCubit>().setTab(index);
  }

  Future<void> _onFeedbackTap(BuildContext context) async {
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    final authCubit = context.read<AuthCubit>();
    await authCubit.verifyTokenValidity();
    if (!context.mounted) return;
    final authState = authCubit.state;
    if (authState.status != AuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('feedback.auth_required'.tr())),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    BetterFeedback.of(context).show((userFeedback) async {
      final comment = userFeedback.text.trim();
      if (comment.isEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('feedback.comment_required'.tr()),
          ),
        );
        return;
      }

      _showFeedbackLoader(context);
      final success = await context.read<FeedbackCubit>().submit(
            comment: comment,
            screenshot: userFeedback.screenshot,
          );
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      final feedbackState = context.read<FeedbackCubit>().state;
      final successText =
          feedbackState.message ?? 'feedback.submit_success'.tr();
      final errorText = 'feedback.submit_error'
          .tr(namedArgs: {'message': feedbackState.errorMessage ?? ''});

      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(successText),
          ),
        );
        context.read<FeedbackCubit>().reset();
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorText),
          ),
        );
      }
    });
  }

  void _showFeedbackLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

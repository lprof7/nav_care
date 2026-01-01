import 'package:easy_localization/easy_localization.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/users/models/user_profile_model.dart';
import 'package:nav_care_user_app/presentation/features/appointments/my_appointments/view/my_appointments_page.dart';
import 'package:nav_care_user_app/presentation/features/authentication/signin/view/signin_page.dart';
import 'package:nav_care_user_app/presentation/features/authentication/logout/viewmodel/logout_cubit.dart';
import 'package:nav_care_user_app/presentation/features/authentication/session/auth_session_cubit.dart';
import 'package:nav_care_user_app/presentation/features/home/view/home_page.dart';
import 'package:nav_care_user_app/presentation/features/messages/view/messages_page.dart';
import 'package:nav_care_user_app/presentation/features/profile/view/user_profile_page.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_cubit.dart';
import 'package:nav_care_user_app/presentation/features/profile/viewmodel/user_profile_state.dart';
import 'package:nav_care_user_app/presentation/features/search/view/search_page.dart';
import 'package:nav_care_user_app/presentation/shared/ui/shell/nav_shell_app_bar.dart';
import 'package:nav_care_user_app/presentation/features/feedback/viewmodel/feedback_cubit.dart';
import 'package:nav_care_user_app/presentation/shared/ui/shell/nav_shell_destination.dart';
import 'package:nav_care_user_app/presentation/shared/ui/shell/nav_shell_drawer.dart';
import 'package:nav_care_user_app/presentation/shared/ui/shell/nav_shell_nav_bar.dart';
import 'package:nav_care_user_app/presentation/shared/theme/theme_mode_cubit.dart';

import '../viewmodel/nav_shell_cubit.dart';

class NavShellPage extends StatelessWidget {
  final int initialIndex;
  const NavShellPage({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavShellCubit(initialIndex: initialIndex)),
        BlocProvider(create: (_) => sl<LogoutCubit>()),
        BlocProvider(create: (_) => sl<FeedbackCubit>()),
        BlocProvider<UserProfileCubit>(
          create: (context) => sl<UserProfileCubit>()
            ..loadProfile()
            ..listenToAuth(context.read<AuthSessionCubit>()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LogoutCubit, LogoutState>(
            listener: (context, state) {
              if (state is LogoutSuccess) {
                context.read<AuthSessionCubit>().clearSession();
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
          ),
          BlocListener<AuthSessionCubit, AuthSessionState>(
            listenWhen: (previous, current) =>
                previous.status != current.status &&
                current.status == AuthSessionStatus.unauthenticated,
            listener: (context, state) {
              context.go('/signin');
            },
          ),
          BlocListener<AuthSessionCubit, AuthSessionState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              // Use read here to avoid establishing a listener inside a callback.
              final profileCubit = context.read<UserProfileCubit>();
              if (state.status == AuthSessionStatus.authenticated) {
                profileCubit.loadProfile();
              } else if (state.status == AuthSessionStatus.unauthenticated) {
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
            final authState = context.watch<AuthSessionCubit>().state;
            final isAuthenticated = authState.isAuthenticated;
            final sessionUser = authState.user;
            final appConfig = sl<AppConfig>();
            final avatarPath = profile?.avatarUrl(appConfig.api.baseUrl) ??
                sessionUser?.profilePicture;
            final userName = profile?.name ?? sessionUser?.name;
            final userEmail = profile?.email ?? sessionUser?.email;
            final themeMode = context.watch<ThemeModeCubit>().state;

            return Scaffold(
              appBar: NavShellAppBar(
                notificationCount: 0,
                onNotificationsTap: () => context.push('/notifications'),
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
                userPhone: profile?.phone,
                userAvatar: avatarPath,
                isProfileLoading:
                    profileState.loadStatus == ProfileLoadStatus.loading,
                profileError:
                    profileState.loadStatus == ProfileLoadStatus.failure
                        ? profileState.errorMessage
                        : null,
                onProfileRetry: () =>
                    context.read<UserProfileCubit>().loadProfile(),
                onProfileTap: () {
                  Navigator.of(context).pop();
                  _onDestinationSelected(context, destinations.length - 1);
                },
                isAuthenticated: isAuthenticated,
                onSignInTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const SigninPage(),
                  );
                },
                onSignUpTap: () => context.go('/signup'),
                onGoogleSignInTap: () {},
                onFaqTap: () => context.push('/faq'),
                onContactTap: () => context.push('/contact'),
                onSettingsTap: () {},
                onAboutTap: () => context.push('/about'),
                onFeedbackTap: () => _onFeedbackTap(context),
                onSupportTap: () {},
                themeMode: themeMode,
                onThemeToggle: () => context.read<ThemeModeCubit>().toggle(),
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
                onTap: (index) => _onDestinationSelected(context, index),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onFeedbackTap(BuildContext context) async {
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    final authCubit = context.read<AuthSessionCubit>();
    await authCubit.verifyTokenValidity();
    if (!context.mounted) return;
    if (!authCubit.state.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('feedback.auth_required'.tr()),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    BetterFeedback.of(context).show((userFeedback) async {
      final comment = (userFeedback.text ?? '').trim();
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
            localeTag: context.locale.toLanguageTag(),
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
        label: 'shell.nav_search'.tr(),
        icon: Icons.search_rounded,
        content: const SearchPage(),
      ),
      NavShellDestination(
        label: 'shell.nav_messages'.tr(),
        icon: Icons.chat_bubble_outline_rounded,
        content: const MessagesPage(),
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
    final authCubit = context.read<AuthSessionCubit>();
    if (authCubit.state.isAuthenticated) {
      await authCubit.verifyTokenValidity();
      if (!authCubit.state.isAuthenticated) return;
    }
    context.read<NavShellCubit>().setTab(index);
  }
}

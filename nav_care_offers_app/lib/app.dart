import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:feedback/feedback.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/core/routing/app_router.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/app_theme.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/theme_mode_cubit.dart';

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(initialLocation: widget.initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<ThemeModeCubit>(
          create: (_) => ThemeModeCubit(initialMode: ThemeMode.system),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            _router.go('/signin');
          } else if (state.status == AuthStatus.authenticated) {
            _router.go('/home');
          }
        },
        child: BlocBuilder<ThemeModeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BetterFeedback(
              child: MaterialApp.router(
                title: 'Nav Care',
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                routerConfig: _router,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
              ),
            );
          },
        ),
      ),
    );
  }
}

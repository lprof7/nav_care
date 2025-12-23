import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:feedback/feedback.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/core/routing/app_router.dart';
import 'package:nav_care_offers_app/core/network/network_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/app_theme.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/theme_mode_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/network_gate.dart';

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = createAppRouter(initialLocation: widget.initialRoute);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      sl<NetworkCubit>().recheckConnectivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<ThemeModeCubit>(
          create: (_) => ThemeModeCubit(initialMode: ThemeMode.system),
        ),
        BlocProvider<NetworkCubit>(create: (_) => sl<NetworkCubit>()),
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
                builder: (context, child) {
                  return NetworkGate(
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

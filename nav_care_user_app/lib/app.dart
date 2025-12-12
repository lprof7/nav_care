import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feedback/feedback.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/core/routing/app_router.dart';
import 'package:nav_care_user_app/presentation/features/authentication/session/auth_session_cubit.dart';
import 'package:nav_care_user_app/presentation/shared/theme/app_theme.dart';
import 'package:nav_care_user_app/presentation/shared/theme/theme_mode_cubit.dart';
import 'package:nav_care_user_app/core/network/network_cubit.dart';

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check connectivity and show shimmer window instead of stale error
      context.read<NetworkCubit>().recheckConnectivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthSessionCubit>()),
        BlocProvider<ThemeModeCubit>(
            create: (_) => ThemeModeCubit(initialMode: ThemeMode.system)),
      ],
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BetterFeedback(
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Nav Care',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: appRouter,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
            ),
          );
        },
      ),
    );
  }
}

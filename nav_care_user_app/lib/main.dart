import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/app.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/config/config_loader.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/core/network/network_cubit.dart';
import 'package:nav_care_user_app/presentation/features/authentication/session/auth_session_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ConfigLoader.load(AppEnv.development);
  await configureDependencies(AppConfig.fromEnv());

  await sl<AuthSessionCubit>().refreshSession();
  final isAuthenticated = sl<AuthSessionCubit>().state.isAuthenticated;
  final initialRoute = isAuthenticated ? '/home' : '/signin';

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('fr'),
      ],
      path: 'assets/translations',
      startLocale: Locale('ar'),
      fallbackLocale: const Locale('ar'),
      child: BlocProvider<NetworkCubit>(
        create: (context) => sl<NetworkCubit>(),
        child: MyApp(initialRoute: initialRoute),
      ),
    ),
  );
}

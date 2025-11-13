import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/app.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/config/config_loader.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ConfigLoader.load(AppEnv.development);
  await configureDependencies(AppConfig.fromEnv());

  await sl<AuthCubit>().checkAuthStatus();
  final initialRoute = sl<AuthCubit>().state.status == AuthStatus.authenticated
      ? '/home'
      : '/signin';

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('fr'),
      ],
      path: 'assets/translations',
      startLocale: Locale('en'),
      fallbackLocale: const Locale('ar'),
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_app/app.dart';
import 'package:nav_care_app/core/config/app_config.dart';
import 'package:nav_care_app/core/config/config_loader.dart';
import 'package:nav_care_app/core/di/di.dart';
import 'package:nav_care_app/core/routing/app_router.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ConfigLoader.load(AppEnv.development);
  await configureDependencies(AppConfig.fromEnv());

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('fr'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(initialRoute: '/signin'),
    ),
  );
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/app.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/config/config_loader.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/core/storage/token_store.dart';
import 'package:nav_care_user_app/core/storage/user_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ConfigLoader.load(AppEnv.development);
  await configureDependencies(AppConfig.fromEnv());

  final tokenStore = sl<TokenStore>();
  final userStore = sl<UserStore>();

  String initialRoute = '/signin';
  if (await tokenStore.getToken() != null && await userStore.getUser() != null) {
    initialRoute = '/home';
  }

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
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

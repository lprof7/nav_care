import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/app.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/config/config_loader.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ConfigLoader.load(AppEnv.development);
  await configureDependencies(AppConfig.fromEnv());
  final token = await sl<TokenStore>().getToken();
  final initialRoute =
      (token != null && token.isNotEmpty) ? '/home' : '/signin';

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

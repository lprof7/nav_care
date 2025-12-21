import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/app.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'core/config/config_loader.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/authentication/signin/signin_repository.dart';

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
      child: const TestApp(),
    ),
  );
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test Signin'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final signinRepo = sl<SigninRepository>();
              final result = await signinRepo.signin({
                'identifier': 'john@example.com',
                'password': 'Password123!',
              });
            },
            child: const Text('Test'),
          ),
        ),
      ),
    );
  }
}

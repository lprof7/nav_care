import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnv { development, production }

class ConfigLoader {
  static Future<void> load(AppEnv env) async {
    final file = switch (env) {
      AppEnv.development => 'assets/env/.env.development',
      AppEnv.production => 'assets/env/.env.production',
    };
    await dotenv.load(fileName: file);
  }
}

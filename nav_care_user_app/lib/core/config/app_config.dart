import 'env.dart';
import 'api_config.dart';

class AppConfig {
  final ApiConfig api;
  final String mapsKey;
  final String sentryDns;

  AppConfig._(this.api, this.mapsKey, this.sentryDns);

  factory AppConfig.fromEnv() => AppConfig._(
        ApiConfig(baseUrl: Env.vpsMain),
        Env.mapsApiKey,
        Env.sentryDns,
      );
}

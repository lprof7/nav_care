import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get vpsMain => _get('VPSMain');
  static String get vpsChat => _get('VpsChat');
  static String get socketMain => _get('SocketMain');
  static String get socketChat => _get('SocketChat');
  static String get mapsApiKey => _get('MAPS_API_KEY');
  static String get sentryDns => _get('sentryDns');

  static String _get(String key) {
    final v = dotenv.env[key];
    if (v == null || v.isEmpty) {
      throw Exception('Missing env key: $key');
    }
    return v;
  }
}

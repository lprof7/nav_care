import 'package:intl/intl.dart';

String resolveLocalizedMessage(dynamic message, {String defaultLocale = 'en'}) {
  if (message is String) return message;
  if (message is Map) {
    final map = message.map((key, value) => MapEntry(key.toString(), value));
    final locale = _normalizeLocale(Intl.getCurrentLocale(), defaultLocale);

    final localized = _messageForLocale(map, locale);
    if (localized != null) return localized;

    if (defaultLocale.isNotEmpty) {
      final fallback = _messageForLocale(map, defaultLocale);
      if (fallback != null) return fallback;
    }

    for (final value in map.values) {
      final text = _stringValue(value);
      if (text != null) return text;
    }
  }
  return '';
}

String _normalizeLocale(String locale, String fallback) {
  final trimmed = locale.trim();
  if (trimmed.isEmpty) return fallback;
  return trimmed;
}

String? _messageForLocale(Map<String, dynamic> map, String locale) {
  final exact = _stringValue(map[locale]);
  if (exact != null) return exact;

  final languageCode = _languageCode(locale);
  if (languageCode.isNotEmpty && languageCode != locale) {
    final shortMatch = _stringValue(map[languageCode]);
    if (shortMatch != null) return shortMatch;
  }

  final aliases = _localeAliases[languageCode] ?? const [];
  for (final alias in aliases) {
    final aliased = _stringValue(map[alias]);
    if (aliased != null) return aliased;
  }

  return null;
}

String _languageCode(String locale) {
  final normalized = locale.split('@').first;
  final parts = normalized.split(RegExp(r'[-_]'));
  return parts.isNotEmpty ? parts.first.trim() : '';
}

String? _stringValue(dynamic value) {
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return null;
}

const Map<String, List<String>> _localeAliases = {
  'es': ['es', 'sp'],
  'sp': ['sp', 'es'],
};

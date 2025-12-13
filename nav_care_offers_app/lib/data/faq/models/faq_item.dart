class FaqItem {
  final Map<String, String> question;
  final Map<String, String> answer;

  const FaqItem({
    required this.question,
    required this.answer,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    Map<String, String> _mapStrings(dynamic value) {
      if (value is Map) {
        return value.map(
          (key, dynamic val) => MapEntry(key.toString(), val?.toString() ?? ''),
        );
      }
      return const {};
    }

    return FaqItem(
      question: _mapStrings(json['question']),
      answer: _mapStrings(json['answer']),
    );
  }

  String localizedQuestion(String locale) => _localizedText(question, locale);
  String localizedAnswer(String locale) => _localizedText(answer, locale);

  String _localizedText(Map<String, String> map, String locale) {
    final normalized = locale.split('_').first.toLowerCase();
    String? pick(String key) => map[key]?.trim().isNotEmpty == true
        ? map[key]!.trim()
        : null;

    return pick(normalized) ??
        (normalized == 'es' ? pick('sp') : null) ??
        pick('en') ??
        pick('fr') ??
        pick('ar') ??
        pick('sp') ??
        map.values.firstWhere(
          (v) => v.trim().isNotEmpty,
          orElse: () => '',
        );
  }
}

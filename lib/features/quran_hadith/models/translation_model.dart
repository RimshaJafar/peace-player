class Translation {
  final String language;
  final List<String> translators;
  final int totalTranslators;

  Translation({
    required this.language,
    required this.translators,
    required this.totalTranslators,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      language: json['language'] ?? '',
      translators: List<String>.from(json['translators'] ?? []),
      totalTranslators: json['total_translators'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'translators': translators,
      'total_translators': totalTranslators,
    };
  }
}

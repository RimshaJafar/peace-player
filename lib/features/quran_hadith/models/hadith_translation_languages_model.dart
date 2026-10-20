class HadithTranslationLanguages {
  final List<String> languages;
  final int totalLanguages;

  HadithTranslationLanguages({
    required this.languages,
    required this.totalLanguages,
  });

  factory HadithTranslationLanguages.fromJson(Map<String, dynamic> json) {
    return HadithTranslationLanguages(
      languages: List<String>.from(json['languages'] ?? []),
      totalLanguages: json['total_languages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languages': languages,
      'total_languages': totalLanguages,
    };
  }
}

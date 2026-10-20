class JuzTranslation {
  final int ayahNumber;
  final int juzNumber;
  final String language;
  final String translator;
  final String translationText;

  JuzTranslation({
    required this.ayahNumber,
    required this.juzNumber,
    required this.language,
    required this.translator,
    required this.translationText,
  });

  factory JuzTranslation.fromJson(Map<String, dynamic> json) {
    return JuzTranslation(
      ayahNumber: json['ayah_number'] ?? 0,
      juzNumber: json['juz_number'] ?? 0,
      language: json['language'] ?? '',
      translator: json['translator'] ?? '',
      translationText: json['translation_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah_number': ayahNumber,
      'juz_number': juzNumber,
      'language': language,
      'translator': translator,
      'translation_text': translationText,
    };
  }
}

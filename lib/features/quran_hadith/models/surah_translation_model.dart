class SurahTranslation {
  final int ayahNumber;
  final int surahNumber;
  final String language;
  final String translator;
  final String translationText;

  SurahTranslation({
    required this.ayahNumber,
    required this.surahNumber,
    required this.language,
    required this.translator,
    required this.translationText,
  });

  factory SurahTranslation.fromJson(Map<String, dynamic> json) {
    return SurahTranslation(
      ayahNumber: json['ayah_number'] ?? 0,
      surahNumber: json['surah_number'] ?? 0,
      language: json['language'] ?? '',
      translator: json['translator'] ?? '',
      translationText: json['translation_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah_number': ayahNumber,
      'surah_number': surahNumber,
      'language': language,
      'translator': translator,
      'translation_text': translationText,
    };
  }
}

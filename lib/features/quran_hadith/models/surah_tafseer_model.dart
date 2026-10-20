class SurahTafseer {
  final int ayahNumber;
  final int surahNumber;
  final String language;
  final String writer;
  final String tafseerText;

  SurahTafseer({
    required this.ayahNumber,
    required this.surahNumber,
    required this.language,
    required this.writer,
    required this.tafseerText,
  });

  factory SurahTafseer.fromJson(Map<String, dynamic> json) {
    return SurahTafseer(
      ayahNumber: json['ayah_number'] ?? 0,
      surahNumber: json['surah_number'] ?? 0,
      language: json['language'] ?? '',
      writer: json['writer'] ?? '',
      tafseerText: json['tafseer_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah_number': ayahNumber,
      'surah_number': surahNumber,
      'language': language,
      'writer': writer,
      'tafseer_text': tafseerText,
    };
  }
}

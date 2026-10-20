class SurahAyah {
  final int ayahNumber;
  final int surahNumber;
  final int juzNumber;
  final int ayahNumberInSurah;
  final String textArabic;

  /// Surah name is a flat Map<String,String>
  final Map<String, String> surahName;
  // final Map<String, dynamic> translations; // language -> map of writers
  // final Map<String, dynamic> audioUrls; // language -> map of qari
  // final Map<String, dynamic> tafseers; // language -> map of tafseer keys

  SurahAyah({
    required this.ayahNumber,
    required this.surahNumber,
    required this.juzNumber,
    required this.ayahNumberInSurah,
    required this.textArabic,
    required this.surahName,
    // required this.translations,
    // required this.audioUrls,
    // required this.tafseers,
  });

  factory SurahAyah.fromJson(Map<String, dynamic> json) {
    return SurahAyah(
      ayahNumber: json['ayah_number'] ?? 0,
      surahNumber: json['surah_number'] ?? 0,
      juzNumber: json['juz_number'] ?? 0,
      ayahNumberInSurah: json['ayah_number_in_surah'] ?? 0,
      textArabic: json['text_arabic'] ?? '',
      surahName: Map<String, String>.from(json['surah_name'] ?? {}),
      // translations: json['translations'] ?? {},
      // audioUrls: json['audio_urls'] ?? {},
      // tafseers: json['tafseers'] ?? {},
    );
  }
}

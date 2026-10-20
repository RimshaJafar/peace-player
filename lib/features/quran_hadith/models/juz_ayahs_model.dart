class JuzAyah {
  final int ayahNumber;
  final int ayahNumberInSurah;
  final int surahNumber;
  final int juzNumber;

  // main fields only (NOT nested extraction)
  final Map<String, dynamic> surahName;
  final Map<String, dynamic> juzName;

  final String arabicText;
  // final Map<String, dynamic> translations;
  // final Map<String, dynamic> audioUrls;
  // final Map<String, dynamic> tafseers;

  final int ruku;
  final bool sajda;

  JuzAyah({
    required this.ayahNumber,
    required this.ayahNumberInSurah,
    required this.surahNumber,
    required this.juzNumber,
    required this.surahName,
    required this.juzName,
    required this.arabicText,
    // required this.translations,
    // required this.audioUrls,
    // required this.tafseers,
    required this.ruku,
    required this.sajda,
  });

  factory JuzAyah.fromJson(Map<String, dynamic> json) {
    return JuzAyah(
      ayahNumber: json['ayah_number'],
      ayahNumberInSurah: json['ayah_number_in_surah'],
      surahNumber: json['surah_number'],
      juzNumber: json['juz_number'],

      surahName: json['surah_name'] ?? {},
      juzName: json['juz_name'] ?? {},

      arabicText: json['text_arabic'] ?? '',

      // translations: json['translations'] ?? {},
      // audioUrls: json['audio_urls'] ?? {},
      // tafseers: json['tafseers'] ?? {},

      ruku: json['ruku'] ?? 0,
      sajda: json['sajda'] ?? false,
    );
  }
}










// class JuzAyah {
//   final int number;
//   final String surahName;
//   final String juzName;
//   final String text;
//   final String textUrdu;
//   final int numberInSurah;

//   JuzAyah({
//     required this.number,
//     required this.surahName,
//     required this.juzName,
//     required this.text,
//     required this.textUrdu,
//     required this.numberInSurah,
//   });

//   factory JuzAyah.fromJson(Map<String, dynamic> json) {
//     return JuzAyah(
//       number: json['ayah_number'],
//       surahName: json['surah_name'],
//       juzName: json['juz_name'],
//       text: json['text_ar'],
//       textUrdu: json['text_ur'],
//       numberInSurah: json['ayah_number_in_surah'],
//     );
//   }
// }

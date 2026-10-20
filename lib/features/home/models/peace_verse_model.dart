class PeaceVerse {
  final int surahNumber;
  final int juzNumber;
  final int ayahNumberInSurah;
  final String textArabic;

  /// BASIC MAP FIELDS (kept)
  final Map<String, String> surahName;
  final Map<String, String> juzName;
  final Map<String, Map<String, String>> translations;
  final Map<String, Map<String, String>> audioUrls;
  final Map<String, String> tafsirs;

  PeaceVerse({
    required this.surahNumber,
    required this.juzNumber,
    required this.ayahNumberInSurah,
    required this.textArabic,
    required this.surahName,
    required this.juzName,
    required this.translations,
    required this.audioUrls,
    required this.tafsirs,
  });

  factory PeaceVerse.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;

    Map<String, String> toStringMap(dynamic v) {
      final map = <String, String>{};
      if (v is Map) {
        v.forEach((k, val) {
          map[k.toString()] = val?.toString() ?? '';
        });
      }
      return map;
    }

    Map<String, Map<String, String>> toMapOfMap(dynamic v) {
      final map = <String, Map<String, String>>{};
      if (v is Map) {
        v.forEach((k, val) {
          map[k.toString()] = toStringMap(val);
        });
      }
      return map;
    }

    return PeaceVerse(
      surahNumber: toInt(json['surah_number']),
      juzNumber: toInt(json['juz_number']),
      ayahNumberInSurah: toInt(json['ayah_number_in_surah']),
      textArabic: json['text_arabic']?.toString() ?? '',
      surahName: toStringMap(json['surah_name']),
      juzName: toStringMap(json['juz_name']),
      translations: toMapOfMap(json['translations']),
      audioUrls: toMapOfMap(json['audio_urls']),
      tafsirs: toStringMap(json['tafsirs'] ?? json['tafsir']),
    );
  }
}

// class PeaceVerse {
//   final int surahNumber;
//   final Map<String, String>
//       surahName; // e.g. {'en': 'Qaaf', 'ar': 'سُورَةُ قٓ', 'meaning': 'QAF'}
//   final int juzNumber;
//   final Map<String, String> juzName; // e.g. {'en': 'Ha'a Meem', 'ar': 'حمٓ'}
//   final String textArabic;
//   final int ayahNumberInSurah;

//   // keep full nested maps so UI can access translations['en']['default'] or translations['ur']['default']
//   final Map<String, Map<String, String>> translations;
//   final Map<String, Map<String, String>> audioUrls;
//   final Map<String, String> tafsirs;

//   PeaceVerse({
//     required this.surahNumber,
//     required this.surahName,
//     required this.juzNumber,
//     required this.juzName,
//     required this.textArabic,
//     required this.ayahNumberInSurah,
//     required this.translations,
//     required this.audioUrls,
//     required this.tafsirs,
//   });

//   factory PeaceVerse.fromJson(Map<String, dynamic> json) {
//     Map<String, String> _toStringMap(dynamic v) {
//       final out = <String, String>{};
//       if (v is Map) {
//         v.forEach((k, val) {
//           out[k.toString()] = val?.toString() ?? '';
//         });
//       }
//       return out;
//     }

//     Map<String, Map<String, String>> _toMapOfMap(dynamic v) {
//       final out = <String, Map<String, String>>{};
//       if (v is Map) {
//         v.forEach((k, inner) {
//           out[k.toString()] = _toStringMap(inner);
//         });
//       }
//       return out;
//     }

//     Map<String, String> _flattenTafsirs(dynamic v) {
//       final out = <String, String>{};
//       if (v is Map) {
//         v.forEach((lang, val) {
//           if (val is String) {
//             out[lang.toString()] = val;
//           } else if (val is Map) {
//             if (val['default'] != null) {
//               out[lang.toString()] = val['default'].toString();
//             } else {
//               out[lang.toString()] =
//                   val.values.map((e) => e?.toString() ?? '').join('\n\n');
//             }
//           }
//         });
//       }
//       return out;
//     }

//     final surahRaw = json['surah_name'];
//     final juzRaw = json['juz_name'];
//     final translationsRaw = json['translations'];
//     final audioRaw = json['audio_urls'] ?? json['audio'];
//     final tafsirRaw =
//         json['tafsir'] ?? json['tafsirs'] ?? json['tafsirs_by_lang'];

//     // surahName: prefer map from API, otherwise fallback to separate fields
//     final surahName = surahRaw is Map
//         ? _toStringMap(surahRaw)
//         : <String, String>{
//             'en': json['surah_name_en']?.toString() ?? '',
//             'ar': json['surah_name']?.toString() ?? ''
//           };

//     final juzName = juzRaw is Map
//         ? _toStringMap(juzRaw)
//         : <String, String>{
//             'en': json['juz_name_en']?.toString() ?? '',
//             'ar': json['juz_name']?.toString() ?? ''
//           };

//     return PeaceVerse(
//       surahNumber: (json['surah_number'] ?? 0) is int
//           ? (json['surah_number'] ?? 0) as int
//           : int.tryParse((json['surah_number'] ?? '0').toString()) ?? 0,
//       surahName: surahName,
//       juzNumber: (json['juz_number'] ?? json['juz'] ?? 0) is int
//           ? (json['juz_number'] ?? json['juz'] ?? 0) as int
//           : int.tryParse(
//                   (json['juz_number'] ?? json['juz'] ?? '0').toString()) ??
//               0,
//       juzName: juzName,
//       textArabic: (json['text_arabic'] ?? json['text_ar'] ?? '').toString(),
//       ayahNumberInSurah: (json['ayah_number_in_surah'] ?? 0) is int
//           ? (json['ayah_number_in_surah'] ?? 0) as int
//           : int.tryParse((json['ayah_number_in_surah'] ?? '0').toString()) ?? 0,
//       translations: _toMapOfMap(translationsRaw),
//       audioUrls: _toMapOfMap(audioRaw),
//       tafsirs: _flattenTafsirs(tafsirRaw),
//     );
//   }
// }

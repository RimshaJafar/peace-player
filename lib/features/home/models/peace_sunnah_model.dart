class PeaceSunnah {
  final int hadithNumber;
  final int bookId;
  final String textArabic;
  final String status;

  /// BASIC MAP FIELDS
  final Map<String, String> bookName;
  final Map<String, String> narratorName;
  final Map<String, String> translations;

  PeaceSunnah({
    required this.hadithNumber,
    required this.bookId,
    required this.textArabic,
    required this.status,
    required this.bookName,
    required this.narratorName,
    required this.translations,
  });

  factory PeaceSunnah.fromJson(Map<String, dynamic> json) {
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

    return PeaceSunnah(
      hadithNumber: toInt(json['hadith_number']),
      bookId: toInt(json['book_id']),
      textArabic: json['text_arabic']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      bookName: toStringMap(json['book_name']),
      narratorName: toStringMap(json['narrator_name']),
      translations: toStringMap(json['translations']),
    );
  }
}









// class PeaceSunnah {
//   final int hadithNumber;
//   final int bookId;
//   // Mirror API shape: language-keyed maps
//   final Map<String, String> bookName;
//   final Map<String, String> narratorName;
//   final Map<String, String> translations;
//   final String textArabic;
//   final String status;

//   PeaceSunnah({
//     required this.hadithNumber,
//     required this.bookId,
//     required this.bookName,
//     required this.narratorName,
//     required this.translations,
//     required this.textArabic,
//     required this.status,
//   });

//   factory PeaceSunnah.fromJson(Map<String, dynamic> json) {
//     Map<String, String> _toStringMap(dynamic v) {
//       final out = <String, String>{};
//       if (v is Map) {
//         v.forEach((k, val) {
//           out[k.toString()] = val?.toString() ?? '';
//         });
//       }
//       return out;
//     }

//     final bookRaw = json['book_name'] ?? json['bookName'] ?? json['book'];
//     final bookName = _toStringMap(bookRaw);

//     final narratorRaw = json['narrator_name'] ?? json['narratorName'];
//     final narratorName = _toStringMap(narratorRaw);

//     final translationsRaw = json['translations'] ?? json['translation'] ?? {};
//     final translations = _toStringMap(translationsRaw);

//     int _parseIntField(dynamic v) {
//       if (v is int) return v;
//       if (v == null) return 0;
//       return int.tryParse(v.toString()) ?? 0;
//     }

//     return PeaceSunnah(
//       hadithNumber:
//           _parseIntField(json['hadith_number'] ?? json['hadithNumber']),
//       bookId: _parseIntField(json['book_id'] ?? json['bookId']),
//       bookName: bookName,
//       narratorName: narratorName,
//       translations: translations,
//       textArabic:
//           (json['text_arabic'] ?? json['hadith_arabic'] ?? '').toString(),
//       status: (json['status'] ?? '').toString(),
//     );
//   }
// }

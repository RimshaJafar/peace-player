import 'package:ecommerce_app/features/quran_hadith/utils/quran_hadith_text_sanitizer.dart';

class HadithBooksChaptersHadiths {
  final int hadithNumber;
  final int bookId;
  final String bookSlug;

  final Map<String, dynamic> bookName;
  final int chapterId;
  final Map<String, dynamic> chapterName;

  final String status;
  final String textArabic;
  final Map<String, dynamic> translations;
  final Map<String, dynamic> narratorName;

  HadithBooksChaptersHadiths({
    required this.hadithNumber,
    required this.bookId,
    required this.bookSlug,
    required this.bookName,
    required this.chapterId,
    required this.chapterName,
    required this.status,
    required this.textArabic,
    required this.translations,
    required this.narratorName,
  });

  factory HadithBooksChaptersHadiths.fromJson(Map<String, dynamic> json) {
    return HadithBooksChaptersHadiths(
      hadithNumber: _asInt(json['hadith_number']),
      bookId: _asInt(json['book_id']),
      bookSlug: cleanQuranHadithText(json['book_slug']),
      bookName: cleanQuranHadithTextMap(json['book_name']),
      chapterId: _asInt(json['chapter_id']),
      chapterName: cleanQuranHadithTextMap(json['chapter_name']),
      status: cleanQuranHadithText(json['status']),
      textArabic: cleanQuranHadithText(json['text_arabic']),
      translations: cleanQuranHadithTextMap(json['translations']),
      narratorName: cleanQuranHadithTextMap(json['narrator_name']),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

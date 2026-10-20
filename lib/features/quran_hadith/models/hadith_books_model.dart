import 'package:ecommerce_app/features/quran_hadith/utils/quran_hadith_text_sanitizer.dart';

class HadithBooks {
  final int bookId;
  final String bookSlug;
  final Map<String, dynamic> bookName;
  final int chapterCount;
  final int hadithCount;

  HadithBooks({
    required this.bookId,
    required this.bookSlug,
    required this.bookName,
    required this.chapterCount,
    required this.hadithCount,
  });

  factory HadithBooks.fromJson(Map<String, dynamic> json) {
    return HadithBooks(
      bookId: _asInt(json['book_id']),
      bookSlug: cleanQuranHadithText(json['book_slug']),
      bookName: cleanQuranHadithTextMap(json['book_name']),
      chapterCount: _asInt(json['chapter_count']),
      hadithCount: _asInt(json['hadith_count']),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

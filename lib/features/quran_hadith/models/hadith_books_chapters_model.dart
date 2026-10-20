import 'package:ecommerce_app/features/quran_hadith/utils/quran_hadith_text_sanitizer.dart';

class HadithBooksChapters {
  final int bookId;
  final int chapterId;
  final Map<String, dynamic> chapterName;
  final int startHadithNumber;
  final int endHadithNumber;
  final int hadithCount;

  HadithBooksChapters({
    required this.bookId,
    required this.chapterId,
    required this.chapterName,
    required this.startHadithNumber,
    required this.endHadithNumber,
    required this.hadithCount,
  });

  factory HadithBooksChapters.fromJson(Map<String, dynamic> json) {
    return HadithBooksChapters(
      bookId: _asInt(json['book_id']),
      chapterId: _asInt(json['chapter_id']),
      chapterName: cleanQuranHadithTextMap(json['chapter_name']),
      startHadithNumber: _asInt(json['start_hadith_number']),
      endHadithNumber: _asInt(json['end_hadith_number']),
      hadithCount: _asInt(json['hadith_count']),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

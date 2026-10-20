import 'package:ecommerce_app/features/quran_hadith/utils/quran_hadith_text_sanitizer.dart';

class HadithTranslation {
  final int hadithNumber;
  final int bookId;
  final int chapterId;
  final String language;
  final String translation;

  HadithTranslation({
    required this.hadithNumber,
    required this.bookId,
    required this.chapterId,
    required this.language,
    required this.translation,
  });

  factory HadithTranslation.fromJson(Map<String, dynamic> json) {
    return HadithTranslation(
      hadithNumber: _asInt(json['hadith_number']),
      bookId: _asInt(json['book_id']),
      chapterId: _asInt(json['chapter_id']),
      language: cleanQuranHadithText(json['language']),
      translation: cleanQuranHadithText(json['translation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hadith_number': hadithNumber,
      'book_id': bookId,
      'chapter_id': chapterId,
      'language': language,
      'translation': translation,
    };
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

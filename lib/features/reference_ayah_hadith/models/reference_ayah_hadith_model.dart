int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, String> _toStringMap(dynamic value) {
  final map = <String, String>{};
  if (value is Map) {
    value.forEach((k, v) {
      map[k.toString()] = v?.toString() ?? '';
    });
  }
  return map;
}

Map<String, Map<String, String>> _toMapOfMap(dynamic value) {
  final map = <String, Map<String, String>>{};
  if (value is Map) {
    value.forEach((k, v) {
      map[k.toString()] = _toStringMap(v);
    });
  }
  return map;
}

class ReferenceAyahHadithResponse {
  final String featureKey;
  final List<QuranReference> quranReferences;
  final List<HadithReference> hadithReferences;
  final int totalDocuments;

  ReferenceAyahHadithResponse({
    required this.featureKey,
    required this.quranReferences,
    required this.hadithReferences,
    required this.totalDocuments,
  });

  factory ReferenceAyahHadithResponse.fromJson(Map<String, dynamic> json) {
    final quranList = json['quran_references'];
    final hadithList = json['hadith_references'];

    return ReferenceAyahHadithResponse(
      featureKey: json['feature_key']?.toString() ?? '',
      quranReferences: quranList is List
          ? quranList
              .map((e) => QuranReference.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <QuranReference>[],
      hadithReferences: hadithList is List
          ? hadithList
              .map(
                  (e) => HadithReference.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <HadithReference>[],
      totalDocuments: _toInt(json['total_documents']),
    );
  }
}

class QuranReference {
  final String text;
  final Map<String, Map<String, String>> translations;
  final QuranReferenceMeta reference;

  QuranReference({
    required this.text,
    required this.translations,
    required this.reference,
  });

  factory QuranReference.fromJson(Map<String, dynamic> json) {
    return QuranReference(
      text: json['text']?.toString() ?? '',
      translations: _toMapOfMap(json['translations']),
      reference: QuranReferenceMeta.fromJson(
          Map<String, dynamic>.from(json['reference'] ?? {})),
    );
  }
}

class QuranReferenceMeta {
  final int surahNumber;
  final Map<String, String> surahName;
  final int ayahNumberInSurah;

  QuranReferenceMeta({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumberInSurah,
  });

  factory QuranReferenceMeta.fromJson(Map<String, dynamic> json) {
    return QuranReferenceMeta(
      surahNumber: _toInt(json['surah_number']),
      surahName: _toStringMap(json['surah_name']),
      ayahNumberInSurah: _toInt(json['ayah_number_in_surah']),
    );
  }
}

class HadithReference {
  final String text;
  final Map<String, Map<String, String>> translations;
  final HadithReferenceMeta reference;

  HadithReference({
    required this.text,
    required this.translations,
    required this.reference,
  });

  factory HadithReference.fromJson(Map<String, dynamic> json) {
    return HadithReference(
      text: json['text']?.toString() ?? '',
      translations: _toMapOfMap(json['translations']),
      reference: HadithReferenceMeta.fromJson(
          Map<String, dynamic>.from(json['reference'] ?? {})),
    );
  }
}

class HadithReferenceMeta {
  final Map<String, String> bookName;
  final int hadithNumber;

  HadithReferenceMeta({
    required this.bookName,
    required this.hadithNumber,
  });

  factory HadithReferenceMeta.fromJson(Map<String, dynamic> json) {
    return HadithReferenceMeta(
      bookName: _toStringMap(json['book_name']),
      hadithNumber: _toInt(json['hadith_number']),
    );
  }
}

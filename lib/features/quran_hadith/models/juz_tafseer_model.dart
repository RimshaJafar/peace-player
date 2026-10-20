class JuzTafseer {
  final int ayahNumber;
  final int juzNumber;
  final String language;
  final String writer;
  final String tafseerText;

  JuzTafseer({
    required this.ayahNumber,
    required this.juzNumber,
    required this.language,
    required this.writer,
    required this.tafseerText,
  });

  factory JuzTafseer.fromJson(Map<String, dynamic> json) {
    return JuzTafseer(
      ayahNumber: json['ayah_number'] ?? 0,
      juzNumber: json['juz_number'] ?? 0,
      language: json['language'] ?? '',
      writer: json['writer'] ?? '',
      tafseerText: json['tafseer_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah_number': ayahNumber,
      'juz_number': juzNumber,
      'language': language,
      'writer': writer,
      'tafseer_text': tafseerText,
    };
  }
}

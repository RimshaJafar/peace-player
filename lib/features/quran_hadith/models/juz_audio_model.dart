class JuzAudio {
  final int ayahNumber;
  final int juzNumber;
  final String language;
  final String reciter;
  final String audioUrl;

  JuzAudio({
    required this.ayahNumber,
    required this.juzNumber,
    required this.language,
    required this.reciter,
    required this.audioUrl,
  });

  factory JuzAudio.fromJson(Map<String, dynamic> json) {
    return JuzAudio(
      ayahNumber: json['ayah_number'] ?? 0,
      juzNumber: json['juz_number'] ?? 0,
      language: json['language'] ?? '',
      reciter: json['reciter'] ?? '',
      audioUrl: json['audio_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah_number': ayahNumber,
      'juz_number': juzNumber,
      'language': language,
      'reciter': reciter,
      'audio_url': audioUrl,
    };
  }
}

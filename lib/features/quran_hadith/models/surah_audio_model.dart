   class SurahAudio {
  final int ayahNumber;
  final int surahNumber;
  final String language;
  final String reciter;
  final String audioUrl;

  SurahAudio({
    required this.ayahNumber,
    required this.surahNumber,
    required this.language,
    required this.reciter,
    required this.audioUrl,
  });

  factory SurahAudio.fromJson(Map<String, dynamic> json) {
    return SurahAudio(
      ayahNumber: json['ayah_number'] ?? 0,
      surahNumber: json['surah_number'] ?? 0,
      language: json['language'] ?? '',
      reciter: json['reciter'] ?? '',
      audioUrl: json['audio_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah_number': ayahNumber,
      'surah_number': surahNumber,
      'language': language,
      'reciter': reciter,
      'audio_url': audioUrl,
    };
  }
}

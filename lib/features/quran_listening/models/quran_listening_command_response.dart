class QuranListeningCommandResponse {
  final bool success;
  final String message;
  final String result;
  final double confidence;
  final String action;
  final int? surahNumber;
  final String? surahName;
  final int? verseNumber;
  final int? ayahNumber;
  final bool shouldPlay;

  QuranListeningCommandResponse({
    required this.success,
    required this.message,
    required this.result,
    required this.confidence,
    required this.action,
    this.surahNumber,
    this.surahName,
    this.verseNumber,
    this.ayahNumber,
    this.shouldPlay = false,
  });

  factory QuranListeningCommandResponse.fromJson(Map<String, dynamic> json) {
    return QuranListeningCommandResponse(
      success: json['success'] == true ||
          json['success']?.toString().toLowerCase() == 'true',
      message: json['message'] as String? ?? '',
      result: json['result'] as String? ?? '',
      confidence: json['confidence'] is num
          ? (json['confidence'] as num).toDouble()
          : (json['confidence'] != null
              ? double.tryParse(json['confidence'].toString()) ?? 0.0
              : 0.0),
      action: json['action'] as String? ?? '',
      surahNumber: json['surah_number'] is int
          ? json['surah_number'] as int
          : (json['surah_number'] != null
              ? int.tryParse(json['surah_number'].toString())
              : null),
      surahName: json['surah_name'] as String?,
      verseNumber: json['verse_number'] is int
          ? json['verse_number'] as int
          : (json['verse_number'] != null
              ? int.tryParse(json['verse_number'].toString())
              : null),
      ayahNumber: json['ayah_number'] is int
          ? json['ayah_number'] as int
          : (json['ayah_number'] != null
              ? int.tryParse(json['ayah_number'].toString())
              : null),
      shouldPlay: json['should_play'] == true ||
          json['should_play']?.toString().toLowerCase() == 'true',
    );
  }
}

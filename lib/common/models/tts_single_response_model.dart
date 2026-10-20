class TTSSingleResponse {
  final String audioData;
  final List<TTSSegment> segments;

  TTSSingleResponse({required this.audioData, required this.segments});

  factory TTSSingleResponse.fromJson(Map<String, dynamic> json) {
    final segs = <TTSSegment>[];
    if (json['segments'] is List) {
      for (final s in json['segments']) {
        segs.add(TTSSegment.fromJson(Map<String, dynamic>.from(s)));
      }
    }
    return TTSSingleResponse(
      audioData: json['audio_data'] as String? ?? '',
      segments: segs,
    );
  }
}

class TTSSegment {
  final int index;
  final String text;
  final String resolvedLanguage;
  final String detectedLanguage;
  final double confidence;

  TTSSegment({
    required this.index,
    required this.text,
    required this.resolvedLanguage,
    required this.detectedLanguage,
    required this.confidence,
  });

  factory TTSSegment.fromJson(Map<String, dynamic> json) {
    return TTSSegment(
      index: json['index'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      resolvedLanguage: json['resolved_language'] as String? ?? '',
      detectedLanguage: json['detected_language'] as String? ?? '',
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : 0.0,
    );
  }
}

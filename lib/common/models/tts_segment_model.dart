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
      index: json['index'] ?? 0,
      text: json['text'] ?? '',
      resolvedLanguage: json['resolved_language'] ?? '',
      detectedLanguage: json['detected_language'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'text': text,
        'resolved_language': resolvedLanguage,
        'detected_language': detectedLanguage,
        'confidence': confidence,
      };
}

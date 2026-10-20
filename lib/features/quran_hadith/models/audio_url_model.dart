class AudioUrl {
  final String language;
  final List<String> reciters;
  final int totalReciters;

  AudioUrl({
    required this.language,
    required this.reciters,
    required this.totalReciters,
  });

  factory AudioUrl.fromJson(Map<String, dynamic> json) {
    return AudioUrl(
      language: json['language'] ?? '',
      reciters: List<String>.from(json['reciters'] ?? []),
      totalReciters: json['total_reciters'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'reciters': reciters,
      'total_reciters': totalReciters,
    };
  }
}

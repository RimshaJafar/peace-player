class Tafseer {
  final String language;
  final List<String> tafseers;
  final int totalTafseers;

  Tafseer({
    required this.language,
    required this.tafseers,
    required this.totalTafseers,
  });

  factory Tafseer.fromJson(Map<String, dynamic> json) {
    return Tafseer(
      language: json['language'] ?? '',
      tafseers: List<String>.from(json['tafseers'] ?? []),
      totalTafseers: json['total_tafseers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'tafseers': tafseers,
      'total_tafseers': totalTafseers,
    };
  }
}

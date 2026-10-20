class IslamicTerm {
  final String id;
  final String textArabic;
  final Map<String, dynamic> translations;
  final String createdAt;

  IslamicTerm({
    required this.id,
    required this.textArabic,
    required this.translations,
    required this.createdAt,
  });

  factory IslamicTerm.fromJson(Map<String, dynamic> json) {
    return IslamicTerm(
      id: json['_id'] ?? '',
      textArabic: json['text_arabic'] ?? '',
      translations: json['translations'] ?? {},
      createdAt: json['created_at'] ?? '',
    );
  }
}

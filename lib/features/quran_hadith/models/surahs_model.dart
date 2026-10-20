class Surahs {
  final int surahNumber;
  final Map<String, dynamic> surahName;
  final int startAyahNumber;
  final int endAyahNumber;
  final int totalAyahs;

  Surahs({
    required this.surahNumber,
    required this.surahName,
    required this.startAyahNumber,
    required this.endAyahNumber,
    required this.totalAyahs,
  });

  factory Surahs.fromJson(Map<String, dynamic> json) {
    return Surahs(
      surahNumber: json['surah_number'],
      surahName: json['surah_name'] ?? {},
      startAyahNumber: json['start_ayah_number'],
      endAyahNumber: json['end_ayah_number'],
      totalAyahs: json['total_ayahs'],
    );
  }
}

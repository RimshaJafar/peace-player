class Juz {
  final int juzNumber;
  final Map<String, String> juzName; // ar / en
  final int startAyahNumber;
  final int endAyahNumber;
  final int totalAyahs;

  Juz({
    required this.juzNumber,
    required this.juzName,
    required this.startAyahNumber,
    required this.endAyahNumber,
    required this.totalAyahs,
  });

  factory Juz.fromJson(Map<String, dynamic> json) {
    Map<String, String> toStringMap(dynamic v) {
      final map = <String, String>{};
      if (v is Map) {
        v.forEach((key, value) {
          map[key.toString()] = value?.toString() ?? '';
        });
      }
      return map;
    }

    int toInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;

    return Juz(
      juzNumber: toInt(json['juz_number']),
      juzName: toStringMap(json['juz_name']),
      startAyahNumber: toInt(json['start_ayah_number']),
      endAyahNumber: toInt(json['end_ayah_number']),
      totalAyahs: toInt(json['total_ayahs']),
    );
  }
}

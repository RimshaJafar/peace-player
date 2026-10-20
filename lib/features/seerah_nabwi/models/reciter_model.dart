class Reciter {
  final String name;
  final int totalNaats;

  Reciter({
    required this.name,
    required this.totalNaats,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      name: json['reciter']?.toString() ?? '',
      totalNaats: json['total_naats'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reciter': name,
      'total_naats': totalNaats,
    };
  }
}

class ReciterListResponse {
  final List<Reciter> reciters;

  ReciterListResponse({required this.reciters});

  factory ReciterListResponse.fromJson(List<dynamic> json) {
    return ReciterListResponse(
      reciters: json
          .map((item) => Reciter.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  List<dynamic> toJson() {
    return reciters.map((reciter) => reciter.toJson()).toList();
  }
}

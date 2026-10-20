class Naat {
  final String id;
  final Map<String, String> title; // en, ur
  final Map<String, String> reciter; // en, ur

  Naat({
    required this.id,
    Map<String, String>? title,
    Map<String, String>? reciter,
  })  : title = title ?? const {},
        reciter = reciter ?? const {};

  factory Naat.fromJson(Map<String, dynamic> json) {
    return Naat(
      id: json['id']?.toString() ?? '',
      title: Map<String, String>.from(json['title'] ?? {}),
      reciter: Map<String, String>.from(json['reciter'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'reciter': reciter,
    };
  }
}

class NaatListResponse {
  final List<Naat> naats;

  NaatListResponse({required this.naats});

  factory NaatListResponse.fromJson(List<dynamic> json) {
    return NaatListResponse(
      naats: json
          .map((item) => Naat.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  List<dynamic> toJson() {
    return naats.map((naat) => naat.toJson()).toList();
  }
}

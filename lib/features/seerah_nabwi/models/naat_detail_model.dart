class NaatDetail {
  final String id;
  final Map<String, String> title; // en, ur
  final Map<String, String> reciter; // en, ur
  final Map<String, String?> writer; // en, ur
  final String audioUrl;
  final String createdAt; // ISO string

  NaatDetail({
    required this.id,
    Map<String, String>? title,
    Map<String, String>? reciter,
    Map<String, String?>? writer,
    required this.audioUrl,
    required this.createdAt,
  })  : title = title ?? const {},
        reciter = reciter ?? const {},
        writer = writer ?? const {};

  factory NaatDetail.fromJson(Map<String, dynamic> json) {
    return NaatDetail(
      id: json['id']?.toString() ?? '',
      title: Map<String, String>.from(json['title'] ?? {}),
      reciter: Map<String, String>.from(json['reciter'] ?? {}),
      writer: Map<String, String?>.from(json['writer'] ?? {}),
      audioUrl: json['audio_url']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'reciter': reciter,
      'writer': writer,
      'audio_url': audioUrl,
      'created_at': createdAt,
    };
  }
}

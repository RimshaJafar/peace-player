class LifeEventItem {
  final String id;
  final Map<String, String> tag; // main, sub
  final int? step;
  final Map<String, String> title; // en, ur
  final Map<String, String> text; // en, ur
  final String? createdAt; // ISO string

  LifeEventItem({
    required this.id,
    Map<String, String>? tag,
    this.step,
    Map<String, String>? title,
    Map<String, String>? text,
    this.createdAt,
  })  : tag = tag ?? const {},
        title = title ?? const {},
        text = text ?? const {};

  factory LifeEventItem.fromJson(Map<String, dynamic> json) {
    return LifeEventItem(
      id: json['_id']?.toString() ?? '',
      tag: Map<String, String>.from(json['tag'] ?? {}),
      step: json['step'] as int?,
      title: Map<String, String>.from(json['title'] ?? {}),
      text: Map<String, String>.from(json['text'] ?? {}),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class LifeEventListResponse {
  final List<LifeEventItem> items;

  LifeEventListResponse({required this.items});

  factory LifeEventListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List? ?? [])
        .map((e) => LifeEventItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return LifeEventListResponse(items: list);
  }
}

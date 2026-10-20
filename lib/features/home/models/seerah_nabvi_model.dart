class SeerahFeatureItem {
  final String id;
  final Map<String, String> tag; // main, sub
  final int? step;
  final Map<String, String> title; // en, ur
  final Map<String, String> text; // en, ur
  final String? category;
  final String? createdAt; // ISO string

  SeerahFeatureItem({
    required this.id,
    Map<String, String>? tag,
    this.step,
    Map<String, String>? title,
    Map<String, String>? text,
    this.category,
    this.createdAt,
  })  : tag = tag ?? const {},
        title = title ?? const {},
        text = text ?? const {};

  factory SeerahFeatureItem.fromJson(Map<String, dynamic> json) {
    return SeerahFeatureItem(
      id: json['_id']?.toString() ?? '',
      tag: Map<String, String>.from(json['tag'] ?? {}),
      step: json['step'] as int?,
      title: Map<String, String>.from(json['title'] ?? {}),
      text: Map<String, String>.from(json['text'] ?? {}),
      category: json['category']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tag': tag,
      'step': step,
      'title': title,
      'text': text,
      'category': category,
      'created_at': createdAt,
    };
  }
}

class SeerahFeatureListResponse {
  final List<SeerahFeatureItem> items;

  SeerahFeatureListResponse({required this.items});

  factory SeerahFeatureListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List? ?? [])
        .map((e) => SeerahFeatureItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return SeerahFeatureListResponse(items: list);
  }
}

class SeerahCategoryItem {
  final String category;
  final int totalFeatures;

  SeerahCategoryItem({
    required this.category,
    required this.totalFeatures,
  });

  factory SeerahCategoryItem.fromJson(Map<String, dynamic> json) {
    return SeerahCategoryItem(
      category: json['category']?.toString() ?? '',
      totalFeatures: json['total_features'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'total_features': totalFeatures,
    };
  }
}

class SeerahCategoryListResponse {
  final List<SeerahCategoryItem> items;

  SeerahCategoryListResponse({required this.items});

  factory SeerahCategoryListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List? ?? [])
        .map((e) => SeerahCategoryItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return SeerahCategoryListResponse(items: list);
  }
}

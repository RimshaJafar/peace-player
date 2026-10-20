class KidsStorySummary {
  final String id;
  final int storyId;
  final String categoryKey;
  final Map<String, dynamic> categoryTitle;
  final Map<String, dynamic> title;
  final String createdAt;

  const KidsStorySummary({
    required this.id,
    required this.storyId,
    required this.categoryKey,
    required this.categoryTitle,
    required this.title,
    required this.createdAt,
  });

  factory KidsStorySummary.fromJson(Map<String, dynamic> json) {
    return KidsStorySummary(
      id: json['_id'] ?? '',
      storyId: json['story_id'] ?? 0,
      categoryKey: json['category_key'] ?? '',
      categoryTitle: (json['category_title'] as Map<String, dynamic>?) ??
          <String, dynamic>{},
      title: (json['title'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      createdAt: json['created_at'] ?? '',
    );
  }
}

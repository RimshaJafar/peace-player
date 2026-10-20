class KidsStoryCategory {
  final String categoryKey;
  final Map<String, dynamic> categoryTitle;
  final int totalStories;

  const KidsStoryCategory({
    required this.categoryKey,
    required this.categoryTitle,
    required this.totalStories,
  });

  factory KidsStoryCategory.fromJson(Map<String, dynamic> json) {
    return KidsStoryCategory(
      categoryKey: json['category_key'] ?? '',
      categoryTitle: (json['category_title'] as Map<String, dynamic>?) ??
          <String, dynamic>{},
      totalStories: json['total_stories'] ?? 0,
    );
  }
}

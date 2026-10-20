class SeerahCategory {
  final String category;
  final int totalFeatures;

  SeerahCategory({
    required this.category,
    required this.totalFeatures,
  });

  factory SeerahCategory.fromJson(Map<String, dynamic> json) {
    return SeerahCategory(
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
  final List<SeerahCategory> items;

  SeerahCategoryListResponse({required this.items});

  factory SeerahCategoryListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List? ?? [])
        .map((e) => SeerahCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return SeerahCategoryListResponse(items: list);
  }
}

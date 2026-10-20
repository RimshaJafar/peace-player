class KidsStoryQuizAnalytics {
  final String categoryKey;
  final int storyId;
  final int totalAttempts;
  final int averageScore;
  final int bestScore;
  final int lastScore;
  final String lastAttemptAt;

  const KidsStoryQuizAnalytics({
    required this.categoryKey,
    required this.storyId,
    required this.totalAttempts,
    required this.averageScore,
    required this.bestScore,
    required this.lastScore,
    required this.lastAttemptAt,
  });

  factory KidsStoryQuizAnalytics.fromJson(Map<String, dynamic> json) {
    return KidsStoryQuizAnalytics(
      categoryKey: json['category_key'] ?? '',
      storyId: json['story_id'] ?? 0,
      totalAttempts: json['total_attempts'] ?? 0,
      averageScore: json['average_score'] ?? 0,
      bestScore: json['best_score'] ?? 0,
      lastScore: json['last_score'] ?? 0,
      lastAttemptAt: json['last_attempt_at'] ?? '',
    );
  }
}

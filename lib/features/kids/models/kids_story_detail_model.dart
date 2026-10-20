class KidsStoryMoral {
  final Map<String, dynamic> text;

  const KidsStoryMoral({required this.text});

  factory KidsStoryMoral.fromJson(Map<String, dynamic> json) {
    return KidsStoryMoral(text: json);
  }
}

class KidsStoryOption {
  final String key;
  final Map<String, dynamic> text;

  const KidsStoryOption({
    required this.key,
    required this.text,
  });
}

class KidsStoryQuestion {
  final int id;
  final Map<String, dynamic> question;
  final Map<String, KidsStoryOption> options;
  final String correctOption;

  const KidsStoryQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOption,
  });

  factory KidsStoryQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions =
        (json['options'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final parsedOptions = <String, KidsStoryOption>{};
    rawOptions.forEach((key, value) {
      parsedOptions[key] = KidsStoryOption(
        key: key,
        text: value is Map<String, dynamic> ? value : <String, dynamic>{},
      );
    });

    return KidsStoryQuestion(
      id: json['id'] ?? 0,
      question:
          (json['question'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      options: parsedOptions,
      correctOption: json['correct_option'] ?? '',
    );
  }

  List<KidsStoryOption> orderedOptions() {
    final keys = options.keys.toList()..sort();
    return keys.map((key) => options[key]!).toList();
  }
}

class KidsStoryDetail {
  final String id;
  final int storyId;
  final String categoryKey;
  final Map<String, dynamic> categoryTitle;
  final Map<String, dynamic> title;
  final List<KidsStoryMoral> morals;
  final List<KidsStoryQuestion> questions;
  final String createdAt;
  final String updatedAt;

  const KidsStoryDetail({
    required this.id,
    required this.storyId,
    required this.categoryKey,
    required this.categoryTitle,
    required this.title,
    required this.morals,
    required this.questions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KidsStoryDetail.fromJson(Map<String, dynamic> json) {
    final moralsJson = (json['morals'] as List<dynamic>?) ?? <dynamic>[];
    final questionsJson = (json['questions'] as List<dynamic>?) ?? <dynamic>[];

    return KidsStoryDetail(
      id: json['_id'] ?? '',
      storyId: json['story_id'] ?? 0,
      categoryKey: json['category_key'] ?? '',
      categoryTitle: (json['category_title'] as Map<String, dynamic>?) ??
          <String, dynamic>{},
      title: (json['title'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      morals: moralsJson
          .whereType<Map<String, dynamic>>()
          .map(KidsStoryMoral.fromJson)
          .toList(),
      questions: questionsJson
          .whereType<Map<String, dynamic>>()
          .map(KidsStoryQuestion.fromJson)
          .toList(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

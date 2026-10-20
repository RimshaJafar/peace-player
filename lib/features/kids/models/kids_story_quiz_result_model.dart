class KidsStoryQuizAnswer {
  final int questionId;
  final String selectedOption;

  const KidsStoryQuizAnswer({
    required this.questionId,
    required this.selectedOption,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'selected_option': selectedOption,
    };
  }
}

class KidsStoryQuizAnswerResult {
  final int questionId;
  final String selectedOption;
  final String correctOption;
  final bool isCorrect;

  const KidsStoryQuizAnswerResult({
    required this.questionId,
    required this.selectedOption,
    required this.correctOption,
    required this.isCorrect,
  });

  factory KidsStoryQuizAnswerResult.fromJson(Map<String, dynamic> json) {
    return KidsStoryQuizAnswerResult(
      questionId: _asInt(json['question_id'] ?? json['questionId']),
      selectedOption: _asString(
        json['selected_option'] ??
            json['selectedOption'] ??
            json['selected_answer'] ??
            json['selectedAnswer'],
      ),
      correctOption: _asString(
        json['correct_option'] ??
            json['correctOption'] ??
            json['correct_answer'] ??
            json['correctAnswer'],
      ),
      isCorrect: _asBool(json['is_correct'] ?? json['isCorrect']),
    );
  }
}

class KidsStoryQuizResult {
  final String resultId;
  final String categoryKey;
  final int storyId;
  final int totalQuestions;
  final int correctCount;
  final int scorePercent;
  final List<KidsStoryQuizAnswerResult> answers;

  const KidsStoryQuizResult({
    required this.resultId,
    required this.categoryKey,
    required this.storyId,
    required this.totalQuestions,
    required this.correctCount,
    required this.scorePercent,
    required this.answers,
  });

  factory KidsStoryQuizResult.fromJson(Map<String, dynamic> json) {
    final answersJson = _asList(json['answers'] ?? json['answer_results']);
    return KidsStoryQuizResult(
      resultId: _asString(json['result_id'] ?? json['resultId'] ?? json['_id']),
      categoryKey: _asString(json['category_key'] ?? json['categoryKey']),
      storyId: _asInt(json['story_id'] ?? json['storyId']),
      totalQuestions: _asInt(json['total_questions'] ??
          json['totalQuestions'] ??
          json['question_count'] ??
          json['questionCount']),
      correctCount: _asInt(json['correct_count'] ??
          json['correctCount'] ??
          json['correct_answers'] ??
          json['correctAnswers']),
      scorePercent: _asInt(json['score_percent'] ??
          json['scorePercent'] ??
          json['score_percentage'] ??
          json['scorePercentage'] ??
          json['score']),
      answers: answersJson
          .whereType<Map<String, dynamic>>()
          .map(KidsStoryQuizAnswerResult.fromJson)
          .toList(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0;
  }
  return 0;
}

bool _asBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'correct';
  }
  return false;
}

String _asString(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

List<dynamic> _asList(dynamic value) {
  if (value is List<dynamic>) {
    return value;
  }
  if (value is Map<String, dynamic>) {
    return value.values.toList();
  }
  return <dynamic>[];
}

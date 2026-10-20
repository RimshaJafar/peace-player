import 'dart:convert';

import 'package:ecommerce_app/features/kids/models/kids_story_category_model.dart';
import 'package:ecommerce_app/features/kids/models/kids_story_detail_model.dart';
import 'package:ecommerce_app/features/kids/models/kids_story_quiz_analytics_model.dart';
import 'package:ecommerce_app/features/kids/models/kids_story_quiz_result_model.dart';
import 'package:ecommerce_app/features/kids/models/kids_story_summary_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;

class KidsStoriesController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  final categories = <KidsStoryCategory>[].obs;
  final stories = <KidsStorySummary>[].obs;
  final storyDetail = Rxn<KidsStoryDetail>();
  final quizResult = Rxn<KidsStoryQuizResult>();
  final quizAnalytics = Rxn<KidsStoryQuizAnalytics>();

  final isCategoriesLoading = false.obs;
  final isStoriesLoading = false.obs;
  final isStoryDetailLoading = false.obs;
  final isQuizSubmitting = false.obs;
  final isQuizAnalyticsLoading = false.obs;

  final categoriesError = ''.obs;
  final storiesError = ''.obs;
  final storyDetailError = ''.obs;
  final quizError = ''.obs;
  final analyticsError = ''.obs;

  final Map<String, KidsStoryDetail> _detailCache = <String, KidsStoryDetail>{};

  Future<void> fetchCategories() async {
    final baseUrl = apisBaseUrl;
    if (baseUrl == null || baseUrl.isEmpty) {
      categoriesError.value = 'API base URL not configured';
      categories.clear();
      return;
    }

    isCategoriesLoading.value = true;
    categoriesError.value = '';

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/kids/stories/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        categories.value = data
            .whereType<Map<String, dynamic>>()
            .map(KidsStoryCategory.fromJson)
            .toList();
      } else {
        categoriesError.value =
            'Failed to fetch categories (${response.statusCode})';
      }
    } catch (e) {
      categoriesError.value = 'Failed to fetch categories';
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchStories(String categoryKey) async {
    final baseUrl = apisBaseUrl;
    if (baseUrl == null || baseUrl.isEmpty) {
      storiesError.value = 'API base URL not configured';
      stories.clear();
      return;
    }

    isStoriesLoading.value = true;
    storiesError.value = '';
    stories.clear();

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/kids/stories/$categoryKey'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        stories.value = data
            .whereType<Map<String, dynamic>>()
            .map(KidsStorySummary.fromJson)
            .toList();
      } else {
        storiesError.value = 'Failed to fetch stories (${response.statusCode})';
      }
    } catch (e) {
      storiesError.value = 'Failed to fetch stories';
    } finally {
      isStoriesLoading.value = false;
    }
  }

  Future<KidsStoryDetail?> fetchStoryDetail(
    String categoryKey,
    int storyId, {
    bool forceRefresh = false,
  }) async {
    final baseUrl = apisBaseUrl;
    if (baseUrl == null || baseUrl.isEmpty) {
      storyDetailError.value = 'API base URL not configured';
      return null;
    }

    final cacheKey = '$categoryKey:$storyId';
    if (!forceRefresh && _detailCache.containsKey(cacheKey)) {
      storyDetail.value = _detailCache[cacheKey];
      return storyDetail.value;
    }

    isStoryDetailLoading.value = true;
    storyDetailError.value = '';
    storyDetail.value = null;

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/kids/stories/$categoryKey/$storyId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final detail = KidsStoryDetail.fromJson(data);
        _detailCache[cacheKey] = detail;
        storyDetail.value = detail;
        return detail;
      }
      storyDetailError.value = 'Failed to fetch story (${response.statusCode})';
    } catch (e) {
      storyDetailError.value = 'Failed to fetch story';
    } finally {
      isStoryDetailLoading.value = false;
    }
    return null;
  }

  Future<KidsStoryQuizResult?> submitQuiz({
    required String categoryKey,
    required int storyId,
    required List<KidsStoryQuizAnswer> answers,
    required String userId,
  }) async {
    final baseUrl = apisBaseUrl;
    if (baseUrl == null || baseUrl.isEmpty) {
      quizError.value = 'API base URL not configured';
      return null;
    }

    isQuizSubmitting.value = true;
    quizError.value = '';
    quizResult.value = null;

    final payload = {
      'category_key': categoryKey,
      'story_id': storyId,
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'user_id': userId,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kids/stories/quiz-result'),
        headers: const {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body);
        final data = _extractQuizResultJson(decoded);
        if (data == null) {
          quizError.value = 'Quiz result format is invalid';
          return null;
        }

        final result = KidsStoryQuizResult.fromJson(data);
        quizResult.value = result;
        return result;
      }
      quizError.value = 'Quiz submission failed (${response.statusCode})';
    } catch (e) {
      quizError.value = 'Quiz submission failed';
    } finally {
      isQuizSubmitting.value = false;
    }
    return null;
  }

  Map<String, dynamic>? _extractQuizResultJson(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    const resultKeys = ['data', 'result', 'quiz_result', 'quizResult'];
    for (final key in resultKeys) {
      final value = decoded[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }

    return decoded;
  }

  Future<KidsStoryQuizAnalytics?> fetchQuizAnalytics({
    required String categoryKey,
    required int storyId,
    required String userId,
  }) async {
    final baseUrl = apisBaseUrl;
    if (baseUrl == null || baseUrl.isEmpty) {
      analyticsError.value = 'API base URL not configured';
      return null;
    }

    isQuizAnalyticsLoading.value = true;
    analyticsError.value = '';
    quizAnalytics.value = null;

    try {
      final uri = Uri.parse(
        '$baseUrl/kids/stories/$categoryKey/$storyId/quiz-analytics'
        '?user_id=${Uri.encodeComponent(userId)}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final analytics = KidsStoryQuizAnalytics.fromJson(data);
        quizAnalytics.value = analytics;
        return analytics;
      }
      analyticsError.value =
          'Failed to fetch quiz analytics (${response.statusCode})';
    } catch (e) {
      analyticsError.value = 'Failed to fetch quiz analytics';
    } finally {
      isQuizAnalyticsLoading.value = false;
    }
    return null;
  }
}

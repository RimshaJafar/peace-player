import 'dart:convert';

import 'package:ecommerce_app/data/services/authenticated_http_client.dart' as http;
import 'package:ecommerce_app/features/kids/models/learn_step_model.dart';
import 'package:ecommerce_app/features/kids/models/islamic_term_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class KidsController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  var learnSteps = <LearnStep>[].obs;
  var islamicTerms = <IslamicTerm>[].obs;

  var isLearnStepsLoading = false.obs;
  var isIslamicTermsLoading = false.obs;

  /// Fetch learn steps by topic (e.g. "namaz", "wudu")
  Future<void> fetchLearnSteps(String topic) async {
    isLearnStepsLoading.value = true;
    learnSteps.clear();
    try {
      final response = await http.get(
        Uri.parse("$apisBaseUrl/kids/learn/$topic"),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _debugLearnPayload(topic, data);

        final steps = data.map((e) => LearnStep.fromJson(e)).toList();
        _debugParsedLearnSteps(topic, steps);
        learnSteps.value = steps;
      }
    } catch (error, stackTrace) {
      _logDebug('Kids learn steps fetch error', error, stackTrace);
    } finally {
      isLearnStepsLoading.value = false;
    }
  }

  /// Fetch islamic terms (good words)
  Future<void> fetchIslamicTerms() async {
    isIslamicTermsLoading.value = true;
    islamicTerms.clear();
    try {
      final response = await http.get(
        Uri.parse("$apisBaseUrl/kids/islamic-terms"),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        islamicTerms.value = data.map((e) => IslamicTerm.fromJson(e)).toList();
      }
    } catch (error, stackTrace) {
      _logDebug('Kids islamic terms fetch error', error, stackTrace);
    } finally {
      isIslamicTermsLoading.value = false;
    }
  }

  void _debugLearnPayload(String topic, List<dynamic> data) {
    if (!kDebugMode) return;

    debugPrint(
      '[KidsController][$topic] raw learn payload items=${data.length}',
    );

    for (var index = 0; index < data.length && index < 5; index++) {
      final item = data[index];
      if (item is! Map<String, dynamic>) {
        debugPrint(
          '[KidsController][$topic] raw[$index] unexpected type '
          '${item.runtimeType}',
        );
        continue;
      }

      debugPrint(
        '[KidsController][$topic] raw[$index] step=${item['step']} '
        'keys=${item.keys.join(', ')} '
        'image_url=${_debugField(item['image_url'])}',
      );
    }
  }

  void _debugParsedLearnSteps(String topic, List<LearnStep> steps) {
    if (!kDebugMode) return;

    for (var index = 0; index < steps.length && index < 5; index++) {
      final step = steps[index];
      debugPrint(
        '[KidsController][$topic] parsed[$index] step=${step.step} '
        'image_url=${_debugField(step.imageUrl)}',
      );
    }
  }

  String _debugField(Object? value) {
    if (value == null) return 'null';

    final text = value.toString().trim();
    if (text.isEmpty) return 'empty';

    final uri = Uri.tryParse(text);
    final host = uri == null || uri.host.isEmpty ? 'no-host' : uri.host;
    return 'len=${text.length}, host=$host';
  }

  void _logDebug(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('$message: $error');
    debugPrint(stackTrace.toString());
  }
}

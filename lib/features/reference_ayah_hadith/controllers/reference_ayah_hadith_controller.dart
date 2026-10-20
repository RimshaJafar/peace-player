import 'dart:convert';

import 'package:ecommerce_app/features/reference_ayah_hadith/models/reference_ayah_hadith_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart' as http;

class ReferenceAyahHadithController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  final Map<String, ReferenceAyahHadithResponse> _featureCache = {};
  final Map<String, bool> _loadingStates = {};

  String buildId(String featureKey) => 'reference_ayah_hadith_$featureKey';

  bool isFeatureLoading(String featureKey) =>
      _loadingStates[featureKey] ?? false;

  ReferenceAyahHadithResponse? getFeatureData(String featureKey) =>
      _featureCache[featureKey];

  bool get _canCallApi => apisBaseUrl != null && apisBaseUrl!.isNotEmpty;

  Future<ReferenceAyahHadithResponse?> fetchByFeature(
    String featureKey, {
    bool forceRefresh = false,
  }) async {
    if (!_canCallApi) {
      if (kDebugMode) {
        debugPrint('Reference ayah/hadith: API base URL not configured');
      }
      return null;
    }

    if (!forceRefresh && _featureCache.containsKey(featureKey)) {
      return _featureCache[featureKey];
    }

    _loadingStates[featureKey] = true;
    update([buildId(featureKey)]);

    try {
      final safeKey = Uri.encodeComponent(featureKey);
      final url = Uri.parse('$apisBaseUrl/reference-ayah-hadith/$safeKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final result = ReferenceAyahHadithResponse.fromJson(data);
          _featureCache[featureKey] = result;
          return result;
        }
      }
    } catch (error, stackTrace) {
      _logDebug('Reference ayah/hadith fetch exception', error, stackTrace);
    } finally {
      _loadingStates[featureKey] = false;
      update([buildId(featureKey)]);
    }

    return null;
  }

  void _logDebug(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('$message: $error');
    debugPrint(stackTrace.toString());
  }
}

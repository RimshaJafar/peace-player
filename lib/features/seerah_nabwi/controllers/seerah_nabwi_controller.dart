import 'package:ecommerce_app/features/seerah_nabwi/models/seerah_feature_model.dart';
import 'package:ecommerce_app/features/seerah_nabwi/models/seerah_category_model.dart';
import 'package:ecommerce_app/features/seerah_nabwi/models/naat_model.dart';
import 'package:ecommerce_app/features/seerah_nabwi/models/naat_detail_model.dart';
import 'package:ecommerce_app/features/seerah_nabwi/models/reciter_model.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SeerahNabwiController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  // Loading states
  final Map<String, bool> _featureLoadingStates = {};
  final Map<String, bool> _categoryLoadingStates = {};
  bool _naatsLoading = false;
  bool _recitersLoading = false;
  bool _naatsByReciterLoading = false;
  bool _naatDetailLoading = false;

  // Data storage - features by main/sub tag combination
  final Map<String, List<SeerahFeatureItem>> _featureItems = {};

  // Data storage - categories by main/sub tag combination
  final Map<String, List<SeerahCategory>> _categoryItems = {};

  // Data storage - naats
  List<Naat> _naats = [];
  List<Reciter> _reciters = [];
  List<Naat> _naatsByReciter = [];
  NaatDetail? _currentNaatDetail;

  bool isFeatureLoading(String key) => _featureLoadingStates[key] ?? false;
  List<SeerahFeatureItem> getFeatureItems(String key) =>
      _featureItems[key] ?? [];

  bool isCategoryLoading(String key) => _categoryLoadingStates[key] ?? false;
  List<SeerahCategory> getCategoryItems(String key) =>
      _categoryItems[key] ?? [];

  // Getters for Naat data
  bool get naatsLoading => _naatsLoading;
  List<Naat> get naats => _naats;

  bool get recitersLoading => _recitersLoading;
  List<Reciter> get reciters => _reciters;

  bool get naatsByReciterLoading => _naatsByReciterLoading;
  List<Naat> get naatsByReciter => _naatsByReciter;

  bool get naatDetailLoading => _naatDetailLoading;
  NaatDetail? get currentNaatDetail => _currentNaatDetail;

  bool get _canCallApi => apisBaseUrl != null;

  /// Fetch seerah features by main tag and sub tag
  /// Example: main="possessions", sub="weapons"
  Future<SeerahFeatureListResponse?> fetchSeerahFeatures({
    required String mainTag,
    required String subTag,
  }) async {
    if (!_canCallApi) {
      _logDebug('Seerah API base URL not configured');
      return null;
    }

    final key = '${mainTag}_$subTag';
    _featureLoadingStates[key] = true;
    update();

    try {
      final url = Uri.parse(
        '$apisBaseUrl/seerah-features/$mainTag/$subTag',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = SeerahFeatureListResponse.fromJson(json);
        _featureItems[key] = result.items;
        return result;
      } else {
        _logDebug('Error fetching seerah features: ${response.statusCode}');
        return null;
      }
    } catch (error, stackTrace) {
      _logDebug('Exception fetching seerah features', error, stackTrace);
      return null;
    } finally {
      _featureLoadingStates[key] = false;
      update();
    }
  }

  /// Fetch categories for a specific main tag and sub tag
  /// Example: main="possessions", sub="perfumes"
  Future<SeerahCategoryListResponse?> fetchSeerahCategories({
    required String mainTag,
    required String subTag,
  }) async {
    if (!_canCallApi) {
      _logDebug('Seerah API base URL not configured');
      return null;
    }

    final key = '${mainTag}_${subTag}_categories';
    _categoryLoadingStates[key] = true;
    update();

    try {
      final url = Uri.parse(
        '$apisBaseUrl/seerah-features/$mainTag/$subTag/categories',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = SeerahCategoryListResponse.fromJson(json);
        _categoryItems[key] = result.items;
        return result;
      } else {
        _logDebug('Error fetching seerah categories: ${response.statusCode}');
        return null;
      }
    } catch (error, stackTrace) {
      _logDebug('Exception fetching seerah categories', error, stackTrace);
      return null;
    } finally {
      _categoryLoadingStates[key] = false;
      update();
    }
  }

  /// Fetch seerah features by category
  /// Example: main="possessions", sub="perfumes", category="seerah_features"
  Future<SeerahFeatureListResponse?> fetchSeerahFeaturesByCategory({
    required String mainTag,
    required String subTag,
    required String category,
  }) async {
    if (!_canCallApi) {
      _logDebug('Seerah API base URL not configured');
      return null;
    }

    final key = '${mainTag}_${subTag}_$category';
    _featureLoadingStates[key] = true;
    update();

    try {
      final url = Uri.parse(
        '$apisBaseUrl/seerah-features/$mainTag/$subTag/category/$category',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = SeerahFeatureListResponse.fromJson(json);
        _featureItems[key] = result.items;
        return result;
      } else {
        _logDebug(
          'Error fetching seerah features by category: ${response.statusCode}',
        );
        return null;
      }
    } catch (error, stackTrace) {
      _logDebug(
        'Exception fetching seerah features by category',
        error,
        stackTrace,
      );
      return null;
    } finally {
      _featureLoadingStates[key] = false;
      update();
    }
  }

  /// Clear cached data for a specific main/sub tag combination
  void clearFeatureCache(String mainTag, String subTag) {
    final key = '${mainTag}_$subTag';
    _featureItems.remove(key);
    _featureLoadingStates.remove(key);
  }

  /// Clear cached data for categories
  void clearCategoryCache(String mainTag, String subTag) {
    final key = '${mainTag}_${subTag}_categories';
    _categoryItems.remove(key);
    _categoryLoadingStates.remove(key);
  }

  /// Clear all cached data
  void clearAllCache() {
    _featureItems.clear();
    _categoryItems.clear();
    _featureLoadingStates.clear();
    _categoryLoadingStates.clear();
  }

  /// Fetch all naats
  /// API: GET /naats
  Future<NaatListResponse?> fetchAllNaats() async {
    if (!_canCallApi) {
      _logDebug('Seerah API base URL not configured');
      return null;
    }

    _naatsLoading = true;
    update();

    try {
      final url = Uri.parse('$apisBaseUrl/naats');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = NaatListResponse.fromJson(json);
        _naats = result.naats;
        return result;
      } else {
        _logDebug('Error fetching naats: ${response.statusCode}');
        return null;
      }
    } catch (error, stackTrace) {
      _logDebug('Exception fetching naats', error, stackTrace);
      return null;
    } finally {
      _naatsLoading = false;
      update();
    }
  }

  /// Fetch all reciters with their naat count
  /// API: GET /naats/reciters
  Future<ReciterListResponse?> fetchAllReciters() async {
    if (!_canCallApi) {
      _logDebug('Seerah API base URL not configured');
      return null;
    }

    _recitersLoading = true;
    update();

    try {
      final url = Uri.parse('$apisBaseUrl/naats/reciters');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = ReciterListResponse.fromJson(json);
        _reciters = result.reciters;
        return result;
      } else {
        _logDebug('Error fetching reciters: ${response.statusCode}');
        return null;
      }
    } catch (error, stackTrace) {
      _logDebug('Exception fetching reciters', error, stackTrace);
      return null;
    } finally {
      _recitersLoading = false;
      update();
    }
  }

  /// Fetch naats by a specific reciter
  /// API: GET /naats/by-reciter/{reciterName}
  Future<NaatListResponse?> fetchNaatsByReciter(String reciterName) async {
    if (!_canCallApi) {
      _logDebug('Seerah API base URL not configured');
      return null;
    }

    _naatsByReciterLoading = true;
    update();

    try {
      final encodedName = Uri.encodeComponent(reciterName);
      final url = Uri.parse('$apisBaseUrl/naats/by-reciter/$encodedName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = NaatListResponse.fromJson(json);
        _naatsByReciter = result.naats;
        return result;
      } else {
        _logDebug('Error fetching naats by reciter: ${response.statusCode}');
        return null;
      }
    } catch (error, stackTrace) {
      _logDebug('Exception fetching naats by reciter', error, stackTrace);
      return null;
    } finally {
      _naatsByReciterLoading = false;
      update();
    }
  }

  /// Fetch detail of a specific naat
  /// API: GET /naats/{id}
  Future<NaatDetail?> fetchNaatDetail(String naatId) async {
    if (!_canCallApi) {
      _logDebug('Seerah API base URL not configured');
      return null;
    }

    _naatDetailLoading = true;
    update();

    try {
      final url = Uri.parse('$apisBaseUrl/naats/$naatId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _currentNaatDetail = NaatDetail.fromJson(json);
        return _currentNaatDetail;
      } else {
        _logDebug('Error fetching naat detail: ${response.statusCode}');
        return null;
      }
    } catch (error, stackTrace) {
      _logDebug('Exception fetching naat detail', error, stackTrace);
      return null;
    } finally {
      _naatDetailLoading = false;
      update();
    }
  }

  void _logDebug(String message, [Object? error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    debugPrint(error == null ? message : '$message: $error');
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }
}

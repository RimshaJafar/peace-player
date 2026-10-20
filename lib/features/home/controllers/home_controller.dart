import 'package:ecommerce_app/features/home/models/peace_sunnah_model.dart';
import 'package:ecommerce_app/features/home/models/peace_verse_model.dart';
import 'package:ecommerce_app/features/home/models/worship_item_model.dart';
import 'package:ecommerce_app/features/home/models/life_event_model.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart' as http;
import 'dart:convert';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';

class HomeController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  // Existing home data
  var peaceVerse = Rxn<PeaceVerse>();
  var peaceSunnah = Rxn<PeaceSunnah>();
  var isLoading = false.obs;

  // Auth/user for worship endpoints
  final authRepo = Get.find<AuthenticationRepository>();
  final userController = Get.find<UserController>();
  String? uId;

  // Worship data shown on home
  final worshipSimpleItems = <WorshipItem>[].obs;
  final worshipSavedItems = <WorshipItem>[].obs;
  final isWorshipLoadingSimple = false.obs;
  final isWorshipLoadingSaved = false.obs;
  final isWorshipSaving = false.obs;
  final lastWorshipSaveStatus = Rxn<SaveStatusResponse>();

  // For tag-specific loading states (asma, kalma, etc.)
  final Map<String, bool> _tagLoadingStates = {};
  final Map<String, List<WorshipItem>> _tagWorshipItems = {};

  // For life events loading states
  final Map<String, bool> _lifeEventLoadingStates = {};
  final Map<String, List<LifeEventItem>> _lifeEventItems = {};

  bool isTagLoading(String tag) => _tagLoadingStates[tag] ?? false;
  List<WorshipItem> getTagWorshipItems(String tag) =>
      _tagWorshipItems[tag] ?? [];

  bool isLifeEventLoading(String key) => _lifeEventLoadingStates[key] ?? false;
  List<LifeEventItem> getLifeEventItems(String key) =>
      _lifeEventItems[key] ?? [];

  bool get _canCallWorshipApi =>
      apisBaseUrl != null && (uId != null && uId!.isNotEmpty);

  @override
  Future<void> onInit() async {
    super.onInit();
    if (authRepo.isLoggedInRx.value) {
      await userController.fetchUserRecord();
      final user = userController.user.value;
      uId = user.id;
    }
  }

  Future<void> fetchHomeRandomVerse() async {
    isLoading.value = true;
    try {
      final res = await http.get(Uri.parse("$apisBaseUrl/home/verse"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is List && data.isNotEmpty) {
          peaceVerse.value =
              PeaceVerse.fromJson(Map<String, dynamic>.from(data[0]));
        }
      }
    } catch (error, stackTrace) {
      _logDebug('Verse error', error, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHomeRandomHadith() async {
    isLoading.value = true;
    try {
      final res = await http.get(Uri.parse("$apisBaseUrl/home/hadith"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is List && data.isNotEmpty) {
          peaceSunnah.value =
              PeaceSunnah.fromJson(Map<String, dynamic>.from(data[0]));
        }
      }
    } catch (error, stackTrace) {
      _logDebug('Hadith error', error, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Worship: simple list for home
  Future<void> fetchWorshipSimple() async {
    if (!_canCallWorshipApi) return;
    isWorshipLoadingSimple.value = true;
    try {
      final url = Uri.parse(
          '$apisBaseUrl/worship/simple?user_id=${Uri.encodeComponent(uId!)}');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) {
          final response = WorshipListResponse.fromJson(data);
          worshipSimpleItems.assignAll(response.items);
        }
      }
    } catch (error, stackTrace) {
      _logDebug('Worship simple error', error, stackTrace);
    } finally {
      isWorshipLoadingSimple.value = false;
    }
  }

  // Worship: fetch simple items by tag (for screens like asma, kalma, etc.)
  Future<void> fetchWorshipByTag(String mainTag) async {
    if (!_canCallWorshipApi) return;
    _tagLoadingStates[mainTag] = true;
    try {
      final url = Uri.parse(
          '$apisBaseUrl/worship/simple?user_id=${Uri.encodeComponent(uId!)}');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) {
          final response = WorshipListResponse.fromJson(data);
          // Filter by tag and store
          final filtered = response.items
              .where((item) =>
                  (item.tag['main'] ?? '').toLowerCase() ==
                  mainTag.toLowerCase())
              .toList();
          _tagWorshipItems[mainTag] = filtered;
        }
      }
    } catch (error, stackTrace) {
      _logDebug('Worship by tag ($mainTag) error', error, stackTrace);
    } finally {
      _tagLoadingStates[mainTag] = false;
      update(); // Notify listeners of tag-specific screen
    }
  }

  // Worship: saved list for home
  Future<void> fetchWorshipSaved() async {
    if (!_canCallWorshipApi) return;
    isWorshipLoadingSaved.value = true;
    try {
      final url = Uri.parse(
          '$apisBaseUrl/worship/saved?user_id=${Uri.encodeComponent(uId!)}');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) {
          final response = WorshipListResponse.fromJson(data);
          final marked = response.items
              .map((e) => WorshipItem(
                    id: e.id,
                    contentHash: e.contentHash,
                    source: e.source,
                    tag: e.tag,
                    title: e.title,
                    textArabic: e.textArabic,
                    translations: e.translations,
                    description: e.description,
                    createdAt: e.createdAt,
                    isSaved: true,
                  ))
              .toList();
          worshipSavedItems.assignAll(marked);
        }
      }
    } catch (error, stackTrace) {
      _logDebug('Worship saved error', error, stackTrace);
    } finally {
      isWorshipLoadingSaved.value = false;
    }
  }

  Future<SaveStatusResponse?> saveWorship(WorshipItem item) async {
    if (!_canCallWorshipApi) return null;
    isWorshipSaving.value = true;
    try {
      final url = Uri.parse('$apisBaseUrl/worship/save');
      final body = item.toSavePayload(userId: uId!);
      final req = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);
      final resp = await http.Client().send(req);
      final text = await resp.stream.bytesToString();
      if (resp.statusCode == 200 && text.isNotEmpty) {
        final jsonMap = jsonDecode(text) as Map<String, dynamic>;
        final parsed = SaveStatusResponse.fromJson(jsonMap);
        lastWorshipSaveStatus.value = parsed;
        _markWorshipSaved(item.id, true);
        await fetchWorshipSaved();
        return parsed;
      }
      return null;
    } catch (error, stackTrace) {
      _logDebug('Worship save error', error, stackTrace);
      return null;
    } finally {
      isWorshipSaving.value = false;
    }
  }

  Future<SaveStatusResponse?> unsaveWorship(String worshipContentId) async {
    if (!_canCallWorshipApi) return null;
    isWorshipSaving.value = true;
    try {
      final url = Uri.parse('$apisBaseUrl/worship/unsave');
      final body = {
        'user_id': uId!,
        'worship_content_id': worshipContentId,
      };
      final req = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);
      final resp = await http.Client().send(req);
      final text = await resp.stream.bytesToString();
      if (resp.statusCode == 200 && text.isNotEmpty) {
        final jsonMap = jsonDecode(text) as Map<String, dynamic>;
        final parsed = SaveStatusResponse.fromJson(jsonMap);
        lastWorshipSaveStatus.value = parsed;
        _markWorshipSaved(worshipContentId, false);
        await fetchWorshipSaved();
        return parsed;
      }
      return null;
    } catch (error, stackTrace) {
      _logDebug('Worship unsave error', error, stackTrace);
      return null;
    } finally {
      isWorshipSaving.value = false;
    }
  }

  Future<SaveStatusResponse?> deleteWorship(String worshipContentId) async {
    if (!_canCallWorshipApi) {
      PLoaders.errorSnackBar(
        title: 'Error',
        message: 'Unable to delete this item right now. Please try again later.',
      );
      return null;
    }
    isWorshipSaving.value = true;
    try {
      final url = Uri.parse('$apisBaseUrl/worship/delete');
      final body = {
        'user_id': uId!,
        'worship_content_id': worshipContentId,
      };
      if (kDebugMode) {
        debugPrint('Deleting worship: $worshipContentId');
      }
      final req = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);
      final resp = await http.Client().send(req);
      final text = await resp.stream.bytesToString();
      if (kDebugMode) {
        debugPrint('Delete response status: ${resp.statusCode}');
        debugPrint('Delete response body length: ${text.length}');
      }

      if (resp.statusCode == 200 && text.isNotEmpty) {
        final jsonMap = jsonDecode(text) as Map<String, dynamic>;
        final parsed = SaveStatusResponse.fromJson(jsonMap);
        lastWorshipSaveStatus.value = parsed;
        // Remove from both lists
        worshipSimpleItems.removeWhere((e) => e.id == worshipContentId);
        worshipSavedItems.removeWhere((e) => e.id == worshipContentId);
        worshipSimpleItems.refresh();
        worshipSavedItems.refresh();

        PLoaders.successSnackBar(
          title: 'Success',
          message: 'Item deleted successfully (${parsed.status})',
        );
        return parsed;
      } else {
        PLoaders.errorSnackBar(
          title: 'Error',
          message: AppErrorMessage.fromStatusCode(
            resp.statusCode,
            parsedMessage: ApiErrorParser.messageFromDecoded(
              safeDecodeJson(text),
            ),
            fallback: 'Unable to delete this item. Please try again.',
          ),
          duration: 4,
        );
      }
      return null;
    } catch (error, stackTrace) {
      _logDebug('Worship delete error', error, stackTrace);
      PLoaders.errorSnackBar(
        title: 'Error',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to delete this item. Please try again.',
        ),
        duration: 4,
      );
      return null;
    } finally {
      isWorshipSaving.value = false;
    }
  }

  Future<SaveStatusResponse?> agentCreateAndSave(WorshipItem item) async {
    if (!_canCallWorshipApi) return null;
    isWorshipSaving.value = true;
    try {
      final url = Uri.parse('$apisBaseUrl/worship/agent_create_save');
      final payload = item.toSavePayload(userId: uId!);
      payload['source'] = 'agent';
      final req = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(payload);
      final resp = await http.Client().send(req);
      final text = await resp.stream.bytesToString();
      if (resp.statusCode == 200 && text.isNotEmpty) {
        final jsonMap = jsonDecode(text) as Map<String, dynamic>;
        final parsed = SaveStatusResponse.fromJson(jsonMap);
        lastWorshipSaveStatus.value = parsed;
        await fetchWorshipSaved();
        return parsed;
      }
      return null;
    } catch (error, stackTrace) {
      _logDebug('Worship agent save error', error, stackTrace);
      return null;
    } finally {
      isWorshipSaving.value = false;
    }
  }

  Future<void> toggleWorshipSaved(WorshipItem item) async {
    final alreadySaved = worshipSavedItems.any((e) => e.id == item.id);
    if (alreadySaved) {
      await unsaveWorship(item.id);
    } else {
      await saveWorship(item);
    }
  }

  List<WorshipItem> filterWorshipByTag(
      List<WorshipItem> source, String mainTag) {
    final lower = mainTag.toLowerCase();
    return source
        .where((e) => (e.tag['main'] ?? '').toLowerCase() == lower)
        .toList();
  }

  List<WorshipItem> filterWorshipBySubTag(
      List<WorshipItem> source, String subTag) {
    final lower = subTag.toLowerCase();
    return source
        .where((e) => (e.tag['sub'] ?? '').toLowerCase() == lower)
        .toList();
  }

  // Life Events: fetch by mainTag and subTag
  Future<void> fetchLifeEventsByTag(String mainTag, String subTag) async {
    if (apisBaseUrl == null) return;
    final key = '${mainTag}_$subTag';
    _lifeEventLoadingStates[key] = true;
    try {
      final url = Uri.parse('$apisBaseUrl/life-events/$mainTag/$subTag');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) {
          final response = LifeEventListResponse.fromJson(data);
          _lifeEventItems[key] = response.items;
        }
      }
    } catch (error, stackTrace) {
      _logDebug('Life events by tag ($mainTag/$subTag) error', error, stackTrace);
    } finally {
      _lifeEventLoadingStates[key] = false;
      update(); // Notify listeners
    }
  }

  // Helper to filter life events by main tag
  List<LifeEventItem> filterLifeEventsByMainTag(
      List<LifeEventItem> source, String mainTag) {
    final lower = mainTag.toLowerCase();
    return source
        .where((e) => (e.tag['main'] ?? '').toLowerCase() == lower)
        .toList();
  }

  // Helper to filter life events by sub tag
  List<LifeEventItem> filterLifeEventsBySubTag(
      List<LifeEventItem> source, String subTag) {
    final lower = subTag.toLowerCase();
    return source
        .where((e) => (e.tag['sub'] ?? '').toLowerCase() == lower)
        .toList();
  }

  void _markWorshipSaved(String id, bool saved) {
    final idx = worshipSimpleItems.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final e = worshipSimpleItems[idx];
      worshipSimpleItems[idx] = WorshipItem(
        id: e.id,
        contentHash: e.contentHash,
        source: e.source,
        tag: e.tag,
        title: e.title,
        textArabic: e.textArabic,
        translations: e.translations,
        description: e.description,
        createdAt: e.createdAt,
        isSaved: saved,
      );
      worshipSimpleItems.refresh();
    }

    if (!saved) {
      worshipSavedItems.removeWhere((e) => e.id == id);
      worshipSavedItems.refresh();
    }
  }

  void _logDebug(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('$message: $error');
    debugPrint(stackTrace.toString());
  }
}

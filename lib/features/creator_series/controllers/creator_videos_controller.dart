import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/features/creator_series/models/creator_video_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart' as http;
import 'package:ecommerce_app/utils/helpers/error_messages.dart';

class CreatorVideosController extends GetxController {
  final String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  final authRepo = Get.find<AuthenticationRepository>();
  final userController = Get.find<UserController>();

  String? firebaseUserId;
  String? _videosUserId;
  String? _scheduleUserId;

  final videos = <CreatorVideoModel>[].obs;
  final schedule = <CreatorVideoModel>[].obs;

  final isVideosLoading = false.obs;
  final isScheduleLoading = false.obs;

  final videosError = Rxn<String>();
  final scheduleError = Rxn<String>();

  String get _baseUrl {
    final configuredUrl = apisBaseUrl?.trim();
    if (configuredUrl == null || configuredUrl.isEmpty) {
      throw const AppConfigurationException(
        'Creator videos are unavailable right now. Please try again later.',
      );
    }
    return configuredUrl.endsWith('/')
        ? configuredUrl.substring(0, configuredUrl.length - 1)
        : configuredUrl;
  }

  bool get isLoading => isVideosLoading.value || isScheduleLoading.value;

  int get approvedCount => videos.where((video) => video.isApproved).length;

  Future<void> loadCreatorContent({
    String? userId,
    bool force = false,
  }) async {
    final previousUserId = firebaseUserId;
    final resolvedUserId = await _resolveUserId(userId);
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      const message = 'Firebase User ID not available';
      videosError.value = message;
      scheduleError.value = message;
      return;
    }

    if (previousUserId != null && previousUserId != resolvedUserId) {
      videos.clear();
      schedule.clear();
      videosError.value = null;
      scheduleError.value = null;
    }

    await Future.wait([
      fetchCreatorVideos(userId: resolvedUserId, force: force),
      fetchCreatorSchedule(userId: resolvedUserId, force: force),
    ]);
  }

  Future<void> fetchCreatorVideos({
    required String userId,
    bool force = false,
  }) async {
    if (isVideosLoading.value) return;
    if (!force && videos.isNotEmpty && _videosUserId == userId) return;

    isVideosLoading.value = true;
    videosError.value = null;

    try {
      final items = await _fetchItems(
        '/creator/videos?firebase_user_id=${Uri.encodeComponent(userId)}',
      );
      videos.assignAll(items);
      _videosUserId = userId;
    } catch (error) {
      videosError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load creator videos. Please try again.',
      );
    } finally {
      isVideosLoading.value = false;
    }
  }

  Future<void> fetchCreatorSchedule({
    required String userId,
    bool force = false,
  }) async {
    if (isScheduleLoading.value) return;
    if (!force && schedule.isNotEmpty && _scheduleUserId == userId) return;

    isScheduleLoading.value = true;
    scheduleError.value = null;

    try {
      final items = await _fetchItems(
        '/creator/schedule?firebase_user_id=${Uri.encodeComponent(userId)}',
      );
      schedule.assignAll(items);
      _scheduleUserId = userId;
    } catch (error) {
      scheduleError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load creator schedule. Please try again.',
      );
    } finally {
      isScheduleLoading.value = false;
    }
  }

  Future<String?> _resolveUserId(String? userId) async {
    if (userId != null && userId.isNotEmpty) {
      firebaseUserId = userId;
      return userId;
    }

    if (firebaseUserId != null && firebaseUserId!.isNotEmpty) {
      return firebaseUserId;
    }

    if (!authRepo.isLoggedInRx.value) return null;

    await userController.fetchUserRecord();
    firebaseUserId = userController.user.value.id;
    return firebaseUserId;
  }

  Future<List<CreatorVideoModel>> _fetchItems(String endpoint) async {
    final response = await http
        .get(Uri.parse('$_baseUrl$endpoint'))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw AppUserFacingException(
        ApiErrorParser.parseResponse(
          response,
          fallback: 'Unable to load creator videos. Please try again.',
        ),
      );
    }

    final decoded = safeDecodeJson(response.body);
    final items = _extractItems(decoded);
    return items
        .whereType<Map<String, dynamic>>()
        .map(CreatorVideoModel.fromJson)
        .toList();
  }

  List<dynamic> _extractItems(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final items = decoded['items'];
      if (items is List) return items;

      final item = decoded['item'];
      if (item != null) return [item];
    }
    return [];
  }

}

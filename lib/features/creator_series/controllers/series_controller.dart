import 'package:ecommerce_app/features/creator_series/models/series_video_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart' as http;
import 'package:ecommerce_app/utils/helpers/error_messages.dart';

class SeriesController extends GetxController {
  final String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  final todayItems = <SeriesVideoModel>[].obs;
  final upcomingItems = <SeriesVideoModel>[].obs;

  final isTodayLoading = false.obs;
  final isUpcomingLoading = false.obs;

  final todayError = Rxn<String>();
  final upcomingError = Rxn<String>();

  SeriesVideoModel? get todayVideo =>
      todayItems.isNotEmpty ? todayItems.first : null;

  List<SeriesVideoModel> get allSeriesVideos => [
        ...todayItems,
        ...upcomingItems.where(
          (upcoming) => todayItems.every(
            (today) => today.videoId != upcoming.videoId,
          ),
        ),
      ];

  /// Get upcoming videos from tomorrow onwards (excluding today's videos)
  List<SeriesVideoModel> get upcomingFromTomorrow {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    return upcomingItems.where((video) {
      final scheduledDate = video.scheduledDate;
      if (scheduledDate == null) return true;

      final videoDate = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
      );

      // Include only videos scheduled from tomorrow onwards
      return !videoDate.isBefore(tomorrow);
    }).toList();
  }

  /// Get upcoming videos for the next 7 days starting from tomorrow.
  List<SeriesVideoModel> get upcomingNext7Days {
    final now = DateTime.now();
    final start =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final end = start.add(const Duration(days: 6));

    return upcomingFromTomorrow.where((video) {
      final scheduledDate = video.scheduledDate;
      if (scheduledDate == null) return true;

      final videoDate = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
      );

      return !videoDate.isBefore(start) && !videoDate.isAfter(end);
    }).toList();
  }

  String get _baseUrl {
    final configuredUrl = apisBaseUrl?.trim();
    if (configuredUrl == null || configuredUrl.isEmpty) {
      throw const AppConfigurationException(
        'Series videos are unavailable right now. Please try again later.',
      );
    }
    return configuredUrl.endsWith('/')
        ? configuredUrl.substring(0, configuredUrl.length - 1)
        : configuredUrl;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTodaySeries();
    fetchUpcomingSeries();
  }

  Future<void> fetchTodaySeries({bool force = false}) async {
    if (isTodayLoading.value) {
      await _waitForLoading(isTodayLoading);
      if (!force) return;
    }
    if (!force && todayItems.isNotEmpty) return;

    isTodayLoading.value = true;
    todayError.value = null;

    try {
      final items = await _fetchSeriesItems('/series/today');
      todayItems.assignAll(items);
    } catch (error) {
      todayError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load today\'s series. Please try again.',
      );
    } finally {
      isTodayLoading.value = false;
    }
  }

  Future<void> fetchUpcomingSeries({bool force = false}) async {
    if (isUpcomingLoading.value) {
      await _waitForLoading(isUpcomingLoading);
      if (!force) return;
    }
    if (!force && upcomingItems.isNotEmpty) return;

    isUpcomingLoading.value = true;
    upcomingError.value = null;

    try {
      final items = await _fetchSeriesItems('/series/upcoming');
      upcomingItems.assignAll(items);
    } catch (error) {
      upcomingError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load upcoming series. Please try again.',
      );
    } finally {
      isUpcomingLoading.value = false;
    }
  }

  Future<void> refreshSeries() async {
    await Future.wait([
      fetchTodaySeries(force: true),
      fetchUpcomingSeries(force: true),
    ]);
  }

  Future<List<SeriesVideoModel>> _fetchSeriesItems(String endpoint) async {
    final response = await http
        .get(Uri.parse('$_baseUrl$endpoint'))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw AppUserFacingException(
        ApiErrorParser.parseResponse(
          response,
          fallback: 'Unable to load series videos. Please try again.',
        ),
      );
    }

    final decoded = safeDecodeJson(response.body);
    final rawItems = _extractItems(decoded);
    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(SeriesVideoModel.fromJson)
        .toList();
  }

  Future<void> _waitForLoading(RxBool loadingFlag) async {
    while (loadingFlag.value) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
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

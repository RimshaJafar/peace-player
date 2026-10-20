import 'dart:convert';

import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:ecommerce_app/features/islamic_tube/models/playlist_model.dart';
import 'package:ecommerce_app/features/islamic_tube/models/search_input_model.dart';
import 'package:ecommerce_app/features/islamic_tube/models/video_item_model.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class IslamicMusicController extends GetxController {
  final String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];
  final isLoading = false.obs;
  final videoItem = <VideoItem>[].obs;
  final playlists = <Playlist>[].obs;
  final searchError = ''.obs;
  final playlistError = ''.obs;
  final selectedFilter = RxnString();
  final audioUrl = ''.obs;

  SearchInput? _lastSearchInput;

  static Uri buildSearchUri(String baseUrl, SearchInput input) {
    final queryParts = <String>[
      'query=${Uri.encodeQueryComponent(input.query)}',
      'max_results=${input.maxResults ?? 10}',
    ];
    for (final filter in input.filters) {
      queryParts.add('filters=${Uri.encodeQueryComponent(filter)}');
    }
    return Uri.parse('$baseUrl/player/search/?${queryParts.join('&')}');
  }

  static Uri buildShortsUri(String baseUrl, SearchInput input) {
    return Uri.parse('$baseUrl/player/shorts/').replace(
      queryParameters: {
        'query': input.query,
        'max_results': '${input.maxResults ?? 10}',
        'filters': jsonEncode(input.filters),
      },
    );
  }

  static bool isNoShortsContentResponse(
    int statusCode,
    String responseBody,
  ) {
    if (statusCode != 404) return false;
    final decoded = safeDecodeJson(responseBody);
    return decoded is Map &&
        decoded['detail']?.toString() == 'No Islamic content found.';
  }

  Future<void> fetchSearchContent(SearchInput input) async {
    isLoading.value = true;
    searchError.value = '';
    _lastSearchInput = input;
    try {
      final baseUrl = _requireBaseUrl();
      final response = await http
          .get(buildSearchUri(baseUrl, input))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to load videos. Please try again.',
          ),
        );
      }

      final decoded = safeDecodeJson(response.body);
      if (decoded is! List) {
        throw const FormatException('Invalid video search response.');
      }
      videoItem.assignAll(
        decoded
            .whereType<Map>()
            .map((item) => VideoItem.fromJson(Map<String, dynamic>.from(item))),
      );
    } catch (error, stackTrace) {
      _handleSearchError(error, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<VideoItem>> fetchSearchShorts(SearchInput input) async {
    try {
      final baseUrl = _requireBaseUrl();
      final response = await http
          .get(buildShortsUri(baseUrl, input))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final decoded = safeDecodeJson(response.body);
        if (decoded is! List) {
          throw const FormatException('Invalid shorts response.');
        }
        return decoded
            .whereType<Map>()
            .map((item) => VideoItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      if (isNoShortsContentResponse(response.statusCode, response.body)) {
        return <VideoItem>[];
      }
      throw AppUserFacingException(
        ApiErrorParser.parseResponse(
          response,
          fallback: 'Unable to load short videos.',
        ),
      );
    } catch (error, stackTrace) {
      _logDebug('Shorts loading failed.', error, stackTrace);
      if (videoItem.isEmpty) {
        searchError.value = AppErrorMessage.fromException(
          error,
          fallback: 'Unable to load videos. Please try again.',
        );
      }
      return <VideoItem>[];
    }
  }

  Future<void> fetchPlaylistVideos(String playlistId) async {
    isLoading.value = true;
    searchError.value = '';
    try {
      final baseUrl = _requireBaseUrl();
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/player/playlists/${Uri.encodeComponent(playlistId)}/videos/',
            ),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to load playlist videos. Please try again.',
          ),
        );
      }

      final decoded = safeDecodeJson(response.body);
      if (decoded is! List) {
        throw const FormatException('Invalid playlist response.');
      }
      videoItem.assignAll(
        decoded
            .whereType<Map>()
            .map((item) => VideoItem.fromJson(Map<String, dynamic>.from(item))),
      );
    } catch (error, stackTrace) {
      _handleSearchError(
        error,
        stackTrace,
        fallback: 'Unable to load playlist videos. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPlaylists() async {
    isLoading.value = true;
    playlistError.value = '';
    try {
      final baseUrl = _requireBaseUrl();
      final response = await http
          .get(Uri.parse('$baseUrl/player/playlists/'))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to load playlists. Please try again.',
          ),
        );
      }

      final decoded = safeDecodeJson(response.body);
      if (decoded is! List) {
        throw const FormatException('Invalid playlists response.');
      }
      playlists.assignAll(
        decoded
            .whereType<Map>()
            .map((item) => Playlist.fromJson(Map<String, dynamic>.from(item))),
      );
    } catch (error, stackTrace) {
      _logDebug('Playlist loading failed.', error, stackTrace);
      playlistError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load playlists. Please try again.',
      );
      PLoaders.errorSnackBar(
        title: 'Playlists Unavailable',
        message: playlistError.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retryLastSearch() async {
    final input = _lastSearchInput;
    if (input != null) await fetchSearchContent(input);
  }

  String _requireBaseUrl() {
    final value = apisBaseUrl?.trim() ?? '';
    final uri = Uri.tryParse(value);
    if (value.isEmpty || uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const AppConfigurationException(
        'Islamic Tube is temporarily unavailable.',
      );
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  void _handleSearchError(
    Object error,
    StackTrace stackTrace, {
    String fallback = 'Unable to load videos. Please try again.',
  }) {
    _logDebug('Video loading failed.', error, stackTrace);
    searchError.value =
        AppErrorMessage.fromException(error, fallback: fallback);
    PLoaders.errorSnackBar(
      title: 'Videos Unavailable',
      message: searchError.value,
    );
  }

  void _logDebug(
    String message,
    Object error,
    StackTrace stackTrace,
  ) {
    if (!kDebugMode) return;
    debugPrint('[IslamicTube] $message $error');
    debugPrint(stackTrace.toString());
  }
}

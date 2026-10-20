import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/features/creator_series/models/video_upload_model.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';

class VideosController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  final authRepo = Get.find<AuthenticationRepository>();
  final userController = Get.find<UserController>();
  String? firebaseUserId;

  var uploadedVideo = Rxn<VideoUploadModel>();
  var isUploadLoading = false.obs;
  var uploadError = Rxn<String>();
  var isVideoUploaded = false.obs;

  bool get _canCallApi =>
      apisBaseUrl != null &&
      (firebaseUserId != null && firebaseUserId!.isNotEmpty);

  @override
  Future<void> onInit() async {
    super.onInit();
    if (authRepo.isLoggedInRx.value) {
      await userController.fetchUserRecord();
      firebaseUserId = userController.user.value.id;
    }
  }

  /// Upload new video
  Future<void> uploadVideo({
    required String title,
    required String description,
    required String category,
    required String tags,
    required String sourcePlatform,
    String? preferredDate,
    XFile? videoFile,
    XFile? thumbnailFile,
    String? language,
    String? duration,
  }) async {
    if (!_canCallApi) {
      uploadError.value = 'Base URL or Firebase User ID not available';
      return;
    }

    final validationError = _validateVideoPayload(
      title: title,
      description: description,
      category: category,
      tags: tags,
      sourcePlatform: sourcePlatform,
      preferredDate: preferredDate,
      duration: duration,
      videoFile: videoFile,
      thumbnailFile: thumbnailFile,
      requireMedia: true,
    );
    if (validationError != null) {
      uploadError.value = validationError;
      return;
    }

    isUploadLoading.value = true;
    uploadError.value = null;
    try {
      final uri = Uri.parse('$apisBaseUrl/videos/upload');
      var request = http.MultipartRequest('POST', uri);
      request.fields['firebase_user_id'] = firebaseUserId!;
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['tags'] = tags;
      request.fields['source_platform'] = sourcePlatform;
      if (preferredDate != null) {
        request.fields['preferred_date'] = preferredDate;
      }
      if (language != null) request.fields['language'] = language;
      if (duration != null) request.fields['duration'] = duration;

      if (videoFile != null) {
        final bytes = await videoFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'video_file',
            bytes,
            filename: videoFile.name,
          ),
        );
      }

      if (thumbnailFile != null) {
        final bytes = await thumbnailFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'thumbnail_file',
            bytes,
            filename: thumbnailFile.name,
          ),
        );
      }

      final response = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout - file may be too large');
        },
      );

      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = safeDecodeJson(responseBody);
        if (data is! Map) {
          throw const FormatException('Invalid upload response.');
        }
        final item = data['item'] ?? data;
        uploadedVideo.value = VideoUploadModel.fromJson(item);
        isVideoUploaded.value = true;
      } else {
        uploadError.value = AppErrorMessage.fromStatusCode(
          response.statusCode,
          parsedMessage:
              ApiErrorParser.messageFromDecoded(safeDecodeJson(responseBody)),
          fallback: 'Unable to upload this video. Please try again.',
        );
      }
    } catch (error, stackTrace) {
      uploadError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to upload this video. Please try again.',
      );
      _logDebug('Upload Video Error', error, stackTrace);
    } finally {
      isUploadLoading.value = false;
    }
  }

  /// Update existing video
  Future<void> updateVideo({
    required String videoId,
    required String title,
    required String description,
    required String category,
    required String tags,
    required String sourcePlatform,
    String? preferredDate,
    XFile? videoFile,
    XFile? thumbnailFile,
    String? language,
    String? duration,
  }) async {
    if (!_canCallApi) {
      uploadError.value = 'Base URL or Firebase User ID not available';
      return;
    }

    final validationError = _validateVideoPayload(
      title: title,
      description: description,
      category: category,
      tags: tags,
      sourcePlatform: sourcePlatform,
      preferredDate: preferredDate,
      duration: duration,
      videoFile: videoFile,
      thumbnailFile: thumbnailFile,
      requireMedia: false,
    );
    if (validationError != null) {
      uploadError.value = validationError;
      return;
    }

    isUploadLoading.value = true;
    uploadError.value = null;
    try {
      final uri = Uri.parse('$apisBaseUrl/videos/$videoId');
      var request = http.MultipartRequest('PUT', uri);
      request.fields['firebase_user_id'] = firebaseUserId!;
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['tags'] = tags;
      request.fields['source_platform'] = sourcePlatform;
      if (preferredDate != null) {
        request.fields['preferred_date'] = preferredDate;
      }
      if (language != null) request.fields['language'] = language;
      if (duration != null) request.fields['duration'] = duration;

      if (videoFile != null) {
        final bytes = await videoFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'video_file',
            bytes,
            filename: videoFile.name,
          ),
        );
      }

      if (thumbnailFile != null) {
        final bytes = await thumbnailFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'thumbnail_file',
            bytes,
            filename: thumbnailFile.name,
          ),
        );
      }

      final response = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Update timeout - file may be too large');
        },
      );

      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = safeDecodeJson(responseBody);
        if (data is! Map) {
          throw const FormatException('Invalid update response.');
        }
        final item = data['item'] ?? data;
        uploadedVideo.value = VideoUploadModel.fromJson(item);
        isVideoUploaded.value = true;
      } else {
        uploadError.value = AppErrorMessage.fromStatusCode(
          response.statusCode,
          parsedMessage:
              ApiErrorParser.messageFromDecoded(safeDecodeJson(responseBody)),
          fallback: 'Unable to update this video. Please try again.',
        );
      }
    } catch (error, stackTrace) {
      uploadError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to update this video. Please try again.',
      );
      _logDebug('Update Video Error', error, stackTrace);
    } finally {
      isUploadLoading.value = false;
    }
  }

  /// Delete uploaded video
  Future<bool> deleteVideo({required String videoId}) async {
    if (!_canCallApi) return false;
    try {
      final uri = Uri.parse(
          '$apisBaseUrl/videos/$videoId?firebase_user_id=$firebaseUserId');
      final response =
          await http.delete(uri).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        uploadedVideo.value = null;
        isVideoUploaded.value = false;
        return true;
      }
      return false;
    } catch (error, stackTrace) {
      _logDebug('Delete Video Error', error, stackTrace);
      return false;
    }
  }

  /// Try to fetch latest uploaded video for current user
  Future<void> fetchLatestUserUpload() async {
    if (!_canCallApi) return;
    try {
      final uri = Uri.parse(
          '$apisBaseUrl/creator/videos?firebase_user_id=$firebaseUserId');
      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = safeDecodeJson(response.body);
        // Get items list from response
        if (data is Map && data['items'] is List && data['items'].isNotEmpty) {
          // Get the latest upload (first item in the list, assuming newest first)
          uploadedVideo.value = VideoUploadModel.fromJson(data['items'][0]);
          isVideoUploaded.value = true;
        } else if (data is Map && data['item'] != null) {
          uploadedVideo.value = VideoUploadModel.fromJson(data['item']);
          isVideoUploaded.value = true;
        }
      }
    } catch (error, stackTrace) {
      _logDebug('Fetch Latest Upload Error', error, stackTrace);
    }
  }

  void _logDebug(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('$message: $error');
    debugPrint(stackTrace.toString());
  }

  String? _validateVideoPayload({
    required String title,
    required String description,
    required String category,
    required String tags,
    required String sourcePlatform,
    String? preferredDate,
    String? duration,
    XFile? videoFile,
    XFile? thumbnailFile,
    required bool requireMedia,
  }) {
    if (title.trim().isEmpty) return 'Title is required.';
    if (description.trim().isEmpty) return 'Description is required.';
    if (category.trim().isEmpty) return 'Category is required.';
    if (tags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .isEmpty) {
      return 'Tags are required.';
    }
    if (sourcePlatform.trim().isEmpty) {
      return 'Source platform is required.';
    }
    if (preferredDate != null &&
        preferredDate.trim().isNotEmpty &&
        DateTime.tryParse(preferredDate.trim()) == null) {
      return 'Enter a valid preferred date.';
    }
    if (duration != null && duration.trim().isNotEmpty) {
      final parsedDuration = num.tryParse(duration.trim());
      if (parsedDuration == null || parsedDuration <= 0) {
        return 'Duration must be a positive number.';
      }
    }
    if (requireMedia && videoFile == null) {
      return 'Video file is required.';
    }
    if (requireMedia && thumbnailFile == null) {
      return 'Thumbnail image is required.';
    }

    return null;
  }
}

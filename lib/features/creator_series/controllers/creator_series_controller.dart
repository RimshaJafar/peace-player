import 'package:ecommerce_app/features/creator_series/models/creator_register_model.dart';
import 'package:ecommerce_app/features/creator_series/models/creator_profile_model.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';

class CreatorSeriesController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  // Creator Register data
  var creatorRegister = Rxn<CreatorRegisterModel>();
  var isRegisterLoading = false.obs;
  var registerError = Rxn<String>();

  // Creator Profile data
  var creatorProfile = Rxn<CreatorProfileModel>();
  var isProfileLoading = false.obs;
  var profileError = Rxn<String>();
  final isCreatorRegistered = false.obs;

  bool get canUploadCreatorVideos {
    final profile = creatorProfile.value;
    if (profile == null) return false;

    return profile.isApproved || profile.status.toLowerCase() == 'approved';
  }

  String get creatorUploadRestrictionMessage {
    final profile = creatorProfile.value;
    if (profile == null) {
      return 'Please complete creator registration and wait for approval before uploading videos.';
    }

    final status = profile.status.trim();
    if (status.isEmpty) {
      return 'Your creator registration must be approved before you can upload videos.';
    }

    return 'Your creator registration status is "$status". You can upload videos after it is approved.';
  }

  // Auth/user for creator endpoints
  final authRepo = Get.find<AuthenticationRepository>();
  final userController = Get.find<UserController>();
  String? firebaseUserId;

  bool get _canCallCreatorApi =>
      apisBaseUrl != null &&
      (firebaseUserId != null && firebaseUserId!.isNotEmpty);

  @override
  Future<void> onInit() async {
    super.onInit();
    await ensureFirebaseUserId();
  }

  Future<void> ensureFirebaseUserId() async {
    if (firebaseUserId != null && firebaseUserId!.isNotEmpty) return;

    if (authRepo.isLoggedInRx.value) {
      await userController.fetchUserRecord();
      final user = userController.user.value;
      firebaseUserId = user.id;
    }
  }

  /// Register Creator
  ///
  /// Submits creator registration form with multipart data
  Future<void> registerCreator({
    required String fullName,
    String? email,
    required String country,
    String? videoLanguage,
    required String bio,
    required String contentCategory,
    required String instagramUrl,
    required String youtubeUrl,
    required String tiktokUrl,
    required String facebookUrl,
    required List<XFile> videoFiles,
    String? existingSampleVideoUrl,
    required bool agreementAccepted,
  }) async {
    if (!_canCallCreatorApi) {
      registerError.value =
          'Creator registration is unavailable right now. Please try again later.';
      return;
    }

    final validationError = _validateCreatorPayload(
      fullName: fullName,
      country: country,
      bio: bio,
      contentCategory: contentCategory,
      instagramUrl: instagramUrl,
      youtubeUrl: youtubeUrl,
      tiktokUrl: tiktokUrl,
      videoLanguage: videoLanguage,
      videoFiles: videoFiles,
      existingSampleVideoUrl: existingSampleVideoUrl,
      agreementAccepted: agreementAccepted,
    );
    if (validationError != null) {
      registerError.value = validationError;
      return;
    }

    isRegisterLoading.value = true;
    registerError.value = null;

    try {
      // Get email from user controller if not provided
      final userEmail = email ?? userController.user.value.email;

      final uri = Uri.parse('$apisBaseUrl/creators/register');
      var request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['firebase_user_id'] = firebaseUserId!;
      request.fields['full_name'] = fullName;
      request.fields['email'] = userEmail;
      request.fields['country'] = country;
      request.fields['bio'] = bio;
      request.fields['content_category'] = contentCategory;
      request.fields['instagram_url'] = instagramUrl;
      request.fields['youtube_url'] = youtubeUrl;
      request.fields['tiktok_url'] = tiktokUrl;
      request.fields['facebook_url'] = facebookUrl;
      if (videoLanguage != null && videoLanguage.isNotEmpty) {
        request.fields['sample_video_language'] = videoLanguage;
      }
      request.fields['agreement_accepted'] = agreementAccepted.toString();

      // Add video files
      if (videoFiles.isNotEmpty) {
        for (int i = 0; i < videoFiles.length; i++) {
          try {
            final bytes = await videoFiles[i].readAsBytes();
            if (kDebugMode) {
              debugPrint(
                'Video file ${i + 1}: ${videoFiles[i].name}, Size: ${bytes.length} bytes',
              );
            }
            request.files.add(
              http.MultipartFile(
                'sample_video_file',
                http.ByteStream.fromBytes(bytes),
                bytes.length,
                filename: videoFiles[i].name,
              ),
            );
          } catch (error, stackTrace) {
            _logDebug('Error reading video file', error, stackTrace);
            throw const AppUserFacingException(
              'Unable to read the selected video. Please choose another file.',
            );
          }
        }
      } else if (existingSampleVideoUrl != null &&
          existingSampleVideoUrl.isNotEmpty) {
        final existingVideoResponse =
            await http.get(Uri.parse(existingSampleVideoUrl));
        if (existingVideoResponse.statusCode == 200) {
          final bytes = existingVideoResponse.bodyBytes;
          final fileName = existingSampleVideoUrl.split('/').last;
          request.files.add(
            http.MultipartFile(
              'sample_video_file',
              http.ByteStream.fromBytes(bytes),
              bytes.length,
              filename: fileName,
            ),
          );
        } else {
          throw AppUserFacingException(
            AppErrorMessage.fromStatusCode(
              existingVideoResponse.statusCode,
              fallback:
                  'Unable to load the existing sample video. Please try again.',
            ),
          );
        }
      }

      final response = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout - file may be too large');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final data = safeDecodeJson(responseBody);
        if (data is! Map) {
          throw const FormatException('Invalid creator response.');
        }
        final itemData = data['item'] ?? data;
        creatorRegister.value = CreatorRegisterModel.fromJson(itemData);
        creatorProfile.value = CreatorProfileModel.fromJson(itemData);
        isCreatorRegistered.value = true;
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorMessage = AppErrorMessage.fromStatusCode(
          response.statusCode,
          parsedMessage:
              ApiErrorParser.messageFromDecoded(safeDecodeJson(responseBody)),
          fallback: 'Registration failed. Please try again.',
        );

        // The backend stores the creator before sending its lifecycle email.
        // If email delivery then fails, it responds with 500 even though the
        // registration exists. A retry subsequently returns "already exists".
        final shouldReconcile = response.statusCode >= 500 ||
            (response.statusCode == 400 &&
                errorMessage.toLowerCase().contains('already exists'));
        if (shouldReconcile && await _reconcileCreatorRegistration()) {
          registerError.value = null;
        } else {
          registerError.value = errorMessage;
        }
      }
    } catch (error, stackTrace) {
      // A timeout or dropped connection can also happen after the backend has
      // persisted the registration, so confirm server state before failing.
      if (await _reconcileCreatorRegistration()) {
        registerError.value = null;
      } else {
        registerError.value = AppErrorMessage.fromException(
          error,
          fallback: 'Unable to submit creator registration. Please try again.',
        );
        _logDebug('Register Creator Error', error, stackTrace);
      }
    } finally {
      isRegisterLoading.value = false;
    }
  }

  /// Confirms whether an ambiguous registration request was persisted.
  ///
  /// This intentionally avoids [fetchCreatorProfile] so a failed recovery
  /// does not replace the registration error with a profile-loading error.
  Future<bool> _reconcileCreatorRegistration() async {
    final baseUrl = apisBaseUrl;
    final uid = firebaseUserId;
    if (baseUrl == null || baseUrl.isEmpty || uid == null || uid.isEmpty) {
      return false;
    }

    try {
      final uri = Uri.parse('$baseUrl/creators/me').replace(
        queryParameters: {'firebase_user_id': uid},
      );
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );
      if (response.statusCode != 200) return false;

      final data = safeDecodeJson(response.body);
      if (data is! Map) return false;
      final itemData = data['item'] ?? data;
      if (itemData is! Map<String, dynamic>) return false;

      creatorRegister.value = CreatorRegisterModel.fromJson(itemData);
      creatorProfile.value = CreatorProfileModel.fromJson(itemData);
      isCreatorRegistered.value = true;
      profileError.value = null;
      return true;
    } catch (error, stackTrace) {
      _logDebug('Creator registration reconciliation failed', error, stackTrace);
      return false;
    }
  }

  /// Fetch Creator Profile
  ///
  /// Fetches the current user's creator profile using their firebase user ID
  Future<void> fetchCreatorProfile({String? userId}) async {
    await ensureFirebaseUserId();
    final uid = userId ?? firebaseUserId;

    if (!_canCallCreatorApi && uid == null) {
      creatorProfile.value = null;
      isCreatorRegistered.value = false;
      profileError.value =
          'Creator profile is unavailable right now. Please try again later.';
      return;
    }

    isProfileLoading.value = true;
    profileError.value = null;

    try {
      final uri = Uri.parse('$apisBaseUrl/creators/me?firebase_user_id=$uid');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = safeDecodeJson(response.body);
        if (data is! Map) {
          throw const FormatException('Invalid profile response.');
        }
        final itemData = data['item'] ?? data;
        creatorProfile.value = CreatorProfileModel.fromJson(itemData);
        isCreatorRegistered.value = true;
      } else {
        creatorProfile.value = null;
        isCreatorRegistered.value = false;
        profileError.value = ApiErrorParser.parseResponse(
          response,
          fallback: 'Unable to load creator profile. Please try again.',
        );
      }
    } catch (error, stackTrace) {
      creatorProfile.value = null;
      isCreatorRegistered.value = false;
      profileError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load creator profile. Please try again.',
      );
      _logDebug('Fetch Creator Profile Error', error, stackTrace);
    } finally {
      isProfileLoading.value = false;
    }
  }

  /// Update Creator Profile
  ///
  /// Updates an existing creator profile using PUT endpoint
  /// firebase_user_id and email are preserved (not changed)
  Future<void> updateCreatorProfile({
    required String fullName,
    required String email,
    required String firebaseUserId,
    required String country,
    String? videoLanguage,
    required String bio,
    required String contentCategory,
    required String instagramUrl,
    required String youtubeUrl,
    required String tiktokUrl,
    required String facebookUrl,
    required List<XFile> videoFiles,
    String? existingSampleVideoUrl,
    required bool agreementAccepted,
  }) async {
    if (!_canCallCreatorApi) {
      registerError.value =
          'Creator profile updates are unavailable right now. Please try again later.';
      return;
    }

    final validationError = _validateCreatorPayload(
      fullName: fullName,
      country: country,
      bio: bio,
      contentCategory: contentCategory,
      instagramUrl: instagramUrl,
      youtubeUrl: youtubeUrl,
      tiktokUrl: tiktokUrl,
      videoLanguage: videoLanguage,
      videoFiles: videoFiles,
      existingSampleVideoUrl: existingSampleVideoUrl,
      agreementAccepted: agreementAccepted,
    );
    if (validationError != null) {
      registerError.value = validationError;
      return;
    }

    isRegisterLoading.value = true;
    registerError.value = null;

    try {
      final uri = Uri.parse('$apisBaseUrl/creators/me');
      var request = http.MultipartRequest('PUT', uri);

      // Add form fields - firebase_user_id and email are preserved (same value)
      request.fields['firebase_user_id'] = firebaseUserId;
      request.fields['full_name'] = fullName;
      request.fields['email'] = email;
      request.fields['country'] = country;
      request.fields['bio'] = bio;
      request.fields['content_category'] = contentCategory;
      request.fields['instagram_url'] = instagramUrl;
      request.fields['youtube_url'] = youtubeUrl;
      request.fields['tiktok_url'] = tiktokUrl;
      request.fields['facebook_url'] = facebookUrl;
      if (videoLanguage != null && videoLanguage.isNotEmpty) {
        request.fields['sample_video_language'] = videoLanguage;
      }
      request.fields['agreement_accepted'] = agreementAccepted.toString();

      // Add video file only if a new one is selected (optional for updates)
      if (videoFiles.isNotEmpty) {
        for (int i = 0; i < videoFiles.length; i++) {
          try {
            final bytes = await videoFiles[i].readAsBytes();
            if (kDebugMode) {
              debugPrint(
                'Video file ${i + 1}: ${videoFiles[i].name}, Size: ${bytes.length} bytes',
              );
            }
            request.files.add(
              http.MultipartFile(
                'sample_video_file',
                http.ByteStream.fromBytes(bytes),
                bytes.length,
                filename: videoFiles[i].name,
              ),
            );
          } catch (error, stackTrace) {
            _logDebug('Error reading video file', error, stackTrace);
            throw const AppUserFacingException(
              'Unable to read the selected video. Please choose another file.',
            );
          }
        }
      }
      // Note: If no new video file is provided, the existing video URL is preserved by the backend

      final response = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Update timeout - file may be too large');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final data = safeDecodeJson(responseBody);
        if (data is! Map) {
          throw const FormatException('Invalid profile update response.');
        }
        final itemData = data['item'] ?? data;
        creatorProfile.value = CreatorProfileModel.fromJson(itemData);
        creatorRegister.value = CreatorRegisterModel.fromJson(itemData);
        isCreatorRegistered.value = true;
      } else {
        final responseBody = await response.stream.bytesToString();
        registerError.value = AppErrorMessage.fromStatusCode(
          response.statusCode,
          parsedMessage:
              ApiErrorParser.messageFromDecoded(safeDecodeJson(responseBody)),
          fallback: 'Unable to update creator profile. Please try again.',
        );
      }
    } catch (error, stackTrace) {
      registerError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to update creator profile. Please try again.',
      );
      _logDebug('Update Creator Profile Error', error, stackTrace);
    } finally {
      isRegisterLoading.value = false;
    }
  }

  /// Clear creator register data
  void clearRegisterData() {
    creatorRegister.value = null;
    registerError.value = null;
  }

  void setCreatorRegistrationState(bool registered) {
    isCreatorRegistered.value = registered;
  }

  void _logDebug(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('$message: $error');
    debugPrint(stackTrace.toString());
  }

  /// Clear creator profile data
  void clearProfileData() {
    creatorProfile.value = null;
    profileError.value = null;
    isCreatorRegistered.value = false;
  }

  String? _validateCreatorPayload({
    required String fullName,
    required String country,
    required String bio,
    required String contentCategory,
    required String instagramUrl,
    required String youtubeUrl,
    required String tiktokUrl,
    String? videoLanguage,
    required List<XFile> videoFiles,
    String? existingSampleVideoUrl,
    required bool agreementAccepted,
  }) {
    if (fullName.trim().isEmpty) return 'Full name is required.';
    if (country.trim().isEmpty) return 'Country is required.';
    if (instagramUrl.trim().isEmpty) {
      return 'Instagram username is required.';
    }
    if (youtubeUrl.trim().isEmpty) return 'YouTube channel is required.';
    if (tiktokUrl.trim().isEmpty) return 'TikTok username is required.';
    if (bio.trim().isEmpty) return 'Bio is required.';
    if (contentCategory.trim().isEmpty) {
      return 'Content category is required.';
    }
    if (videoLanguage == null || videoLanguage.trim().isEmpty) {
      return 'Video language is required.';
    }
    if (videoFiles.isEmpty &&
        (existingSampleVideoUrl == null ||
            existingSampleVideoUrl.trim().isEmpty)) {
      return 'Sample video file is required.';
    }
    if (!agreementAccepted) {
      return 'You must accept the terms and conditions.';
    }

    return null;
  }
}

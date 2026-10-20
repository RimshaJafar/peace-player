import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/common/models/speech_to_text_response.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/helpers/billing_gate_helper.dart';
import 'package:ecommerce_app/features/billing/services/billing_api_service.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../models/chat_delete_response.dart';
import '../models/chat_model.dart';
import '../models/chat_rename_response.dart';
import '../models/max_message_id_response.dart';
import '../models/message_model.dart';

class IslamicGuiderController extends GetxController {
  final authRepo = Get.find<AuthenticationRepository>();
  final userController = Get.find<UserController>();
  final audioController = Get.find<AudioTTSSTTController>();

  final String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  String? uId;
  String? uName;
  String? uEmail;

  final chats = <int, String>{}.obs;
  final selectedChatId = 0.obs;
  final selectedChatName = ''.obs;
  final messages = <MessageModel>[].obs;

  final messageCounter = 1.obs;
  final chatCounter = 1.obs;
  final isLoadingChats = false.obs;
  final isLoadingMessages = false.obs;
  final isSendingMessage = false.obs;
  final chatError = ''.obs;
  final messageError = ''.obs;

  late final TextEditingController inputTextController;

  final pickedImagePath = ''.obs;
  final pickedWebImageFile = Rxn<Uint8List>();
  final pendingImageBytes = Rxn<Uint8List>();
  final pendingImageName = ''.obs;
  final pendingImageMime = ''.obs;
  final ImagePicker _picker = ImagePicker();
  final isImageUploading = false.obs;
  final imageCache = <int, Uint8List>{};

  @override
  Future<void> onInit() async {
    super.onInit();
    inputTextController = TextEditingController();

    if (!authRepo.isLoggedInRx.value) return;

    try {
      await userController.fetchUserRecord();
      final user = userController.user.value;
      uId = user.id;
      uName = user.fullName;
      uEmail = user.email;
      await fetchUserChats();
    } catch (error, stackTrace) {
      _logDebug('initialization failed', error, stackTrace);
      chatError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load your chats. Please try again.',
      );
    }
  }

  @override
  void onClose() {
    inputTextController.dispose();
    super.onClose();
  }

  int _generateMessageId() => messageCounter.value++;

  Future<void> sendMessage() async {
    if (selectedChatId.value == 0 || isSendingMessage.value) return;

    isSendingMessage.value = true;
    messageError.value = '';
    try {
      final text = inputTextController.text.trim();
      final hasPendingImage = pendingImageBytes.value != null;
      if (text.isEmpty && !hasPendingImage) return;

      final featureKey = hasPendingImage
          ? BillingFeatureKeys.imageAiChat
          : BillingFeatureKeys.peaceGuiderAiChat;
      if (!await BillingGateHelper.ensureFeatureAccess(featureKey)) return;

      final id = _generateMessageId();
      final idempotencyKey = BillingRequestId.newKey();
      final effectiveText = text.isEmpty && hasPendingImage ? '[image]' : text;
      var userMessage = MessageModel(
        chatId: selectedChatId.value,
        chatName: selectedChatName.value,
        sender: 'user',
        messageId: id,
        content: effectiveText,
        imageUrl: null,
        timestamp: DateTime.now().toUtc().toIso8601String(),
      );

      if (hasPendingImage) {
        final bytes = pendingImageBytes.value!;
        final dataUrl =
            'data:${pendingImageMime.value};base64,${base64Encode(bytes)}';
        userMessage = userMessage.copyWith(imageUrl: dataUrl);
        imageCache[id] = bytes;
      }

      messages.add(userMessage);
      inputTextController.clear();
      await _sendMessageToBackend(
        userMessage,
        idempotencyKey: idempotencyKey,
      );

      if (hasPendingImage) clearPendingImage();
    } catch (error, stackTrace) {
      _logDebug('sendMessage failed', error, stackTrace);
      final friendly = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to send your message. Please try again.',
      );
      messageError.value = friendly;
      PLoaders.errorSnackBar(
        title: 'Message Failed',
        message: friendly,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> _sendMessageToBackend(
    MessageModel message, {
    required String idempotencyKey,
  }) async {
    final baseUrl = _requireApiBaseUrl();
    final userId = _requireUserId();
    final client = http.Client();
    final buffer = StringBuffer();
    var streamCompleted = false;

    messages.add(
      MessageModel(
        chatId: message.chatId,
        chatName: message.chatName,
        sender: 'assistant',
        messageId: message.messageId,
        content: '',
        timestamp: DateTime.now().toUtc().toIso8601String(),
        isStreaming: true,
      ),
    );

    try {
      final request = http.Request('POST', Uri.parse('$baseUrl/chat/message/'))
        ..headers['Content-Type'] = 'application/json'
        ..headers['Idempotency-Key'] = idempotencyKey
        ..body = jsonEncode({
          'user': {
            'user_id': userId,
            'user_name': uName ?? 'User',
            'user_email': uEmail ?? 'user@example.com',
          },
          'chat': {
            'chat_id': message.chatId,
            'chat_name': message.chatName,
          },
          'message': {
            'message_id': message.messageId,
            'content': message.content,
            'image_url': message.imageUrl,
            'time_stamp': message.timestamp,
          },
        });

      final response =
          await client.send(request).timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        final body = await response.stream
            .bytesToString()
            .timeout(const Duration(seconds: 15));
        _handleBillingPayload(body, statusCode: response.statusCode);
        throw AppUserFacingException(
          AppErrorMessage.fromStatusCode(
            response.statusCode,
            parsedMessage:
                ApiErrorParser.messageFromDecoded(safeDecodeJson(body)),
            fallback: 'Unable to send your message. Please try again.',
          ),
        );
      }

      void processLine(String raw) {
        final decoded = safeDecodeJson(raw);
        if (decoded is! Map) {
          if (kDebugMode) {
            debugPrint('Peace Guider ignored an invalid stream line.');
          }
          return;
        }

        final data = Map<String, dynamic>.from(decoded);
        if (data.containsKey('error') ||
            data.containsKey('errorCode') ||
            data.containsKey('error_code')) {
          final streamError = ApiErrorParser.messageFromDecoded(data);
          throw AppUserFacingException(
            streamError ?? 'The response could not be completed.',
          );
        }

        final part = data['part'];
        if (part != null) {
          final assistantIndex = _streamingMessageIndex(message);
          if (assistantIndex == -1) {
            throw const AppUserFacingException(
              'The conversation changed while the response was loading. Please try again.',
            );
          }
          final current = messages[assistantIndex];
          messages[assistantIndex] = current.copyWith(
            content: current.content + part.toString(),
          );
          messages.refresh();
        }

        final billing = data['billing'];
        if (billing is Map && Get.isRegistered<BillingController>()) {
          BillingController.instance.updateUsageFromBillingMetadata(
            Map<String, dynamic>.from(billing),
          );
        }

        final billingError =
            data['billingError'] ?? data['billing_error'];
        if (billingError is Map) {
          BillingGateHelper.handleError(
            billingApiExceptionFromJson(billingError).error,
          );
        }
      }

      await for (final chunk in response.stream
          .transform(utf8.decoder)
          .timeout(const Duration(seconds: 60))) {
        buffer.write(chunk);
        final lines = buffer.toString().split('\n');
        for (var index = 0; index < lines.length - 1; index++) {
          final line = lines[index].trim();
          if (line.isNotEmpty) processLine(line);
        }
        buffer
          ..clear()
          ..write(lines.last);
      }

      final finalLine = buffer.toString().trim();
      if (finalLine.isNotEmpty) processLine(finalLine);
      streamCompleted = true;
    } catch (error, stackTrace) {
      _logDebug('message stream failed', error, stackTrace);
      final friendly = AppErrorMessage.fromException(
        error,
        fallback: 'The response was interrupted. Please try again.',
      );
      messageError.value = friendly;
      throw AppUserFacingException(friendly);
    } finally {
      client.close();
      final assistantIndex = _streamingMessageIndex(message);
      if (assistantIndex != -1) {
        final current = messages[assistantIndex];
        if (!streamCompleted && current.content.trim().isEmpty) {
          messages.removeAt(assistantIndex);
        } else {
          messages[assistantIndex] = current.copyWith(isStreaming: false);
        }
        messages.refresh();
      }
    }
  }

  Future<void> fetchUserChats() async {
    isLoadingChats.value = true;
    chatError.value = '';
    try {
      final baseUrl = _requireApiBaseUrl();
      final userId = _requireUserId();
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/user/chats/${Uri.encodeComponent(userId)}',
            ),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to load your chats. Please try again.',
          ),
        );
      }

      final decoded = safeDecodeJson(response.body);
      if (decoded is! List) {
        throw const FormatException('Invalid chats response.');
      }

      chats.clear();
      for (final item in decoded) {
        if (item is! Map) continue;
        final chat = ChatModel.fromJson(Map<String, dynamic>.from(item));
        if (chat.chatId != 0) chats[chat.chatId] = chat.chatName;
      }

      final maxId =
          chats.keys.isEmpty ? 0 : chats.keys.reduce((a, b) => a > b ? a : b);
      chatCounter.value = maxId + 1;
      selectedChatId.value = 0;
      selectedChatName.value = '';
      messages.clear();
      messages.refresh();
    } catch (error, stackTrace) {
      _logDebug('fetchUserChats failed', error, stackTrace);
      chatError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load your chats. Please try again.',
      );
    } finally {
      isLoadingChats.value = false;
    }
  }

  Future<void> fetchChatMessages(int chatId) async {
    isLoadingMessages.value = true;
    messageError.value = '';
    try {
      final baseUrl = _requireApiBaseUrl();
      final userId = _requireUserId();
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/user/chat/messages/${Uri.encodeComponent(userId)}/$chatId',
            ),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to load this chat. Please try again.',
          ),
        );
      }

      final decoded = safeDecodeJson(response.body);
      if (decoded is! List) {
        throw const FormatException('Invalid messages response.');
      }

      messages.clear();
      for (final raw in decoded) {
        if (raw is! Map) continue;
        final chatObject = raw['chat'] is Map ? raw['chat'] as Map : raw;
        final messageObject =
            raw['message'] is Map ? raw['message'] as Map : raw;

        final chatIdValue = chatObject['chat_id'];
        final parsedChatId = chatIdValue is int
            ? chatIdValue
            : int.tryParse(chatIdValue?.toString() ?? '') ?? 0;
        final chatName = chatObject['chat_name']?.toString() ?? '';

        final messageIdValue =
            messageObject['message_id'] ?? raw['message_id'];
        final messageId = messageIdValue is int
            ? messageIdValue
            : int.tryParse(messageIdValue?.toString() ?? '') ?? 0;
        final userContent = messageObject['content'] ?? raw['content'];
        final aiContent = messageObject['ai_response'] ??
            raw['ai_response'] ??
            messageObject['aiResponse'] ??
            raw['aiResponse'];
        final imageUrl = (messageObject['image_url'] ??
                raw['image_url'] ??
                messageObject['imageUrl'] ??
                raw['imageUrl'])
            ?.toString();
        final timestamp = _parseTimestamp(
          messageObject['time_stamp'] ??
              raw['time_stamp'] ??
              raw['timeStamp'],
        );

        if (userContent != null && userContent.toString().isNotEmpty) {
          if (imageUrl != null && imageUrl.startsWith('data:')) {
            try {
              final comma = imageUrl.indexOf(',');
              if (comma != -1) {
                imageCache[messageId] =
                    base64Decode(imageUrl.substring(comma + 1));
              }
            } catch (error, stackTrace) {
              _logDebug('chat image decode failed', error, stackTrace);
            }
          }

          messages.add(
            MessageModel(
              chatId: parsedChatId,
              chatName: chatName,
              sender: 'user',
              messageId: messageId,
              content: userContent.toString(),
              imageUrl: imageUrl,
              timestamp: timestamp,
            ),
          );
        }

        if (aiContent != null && aiContent.toString().isNotEmpty) {
          messages.add(
            MessageModel(
              chatId: parsedChatId,
              chatName: chatName,
              sender: 'assistant',
              messageId: messageId,
              content: aiContent.toString(),
              timestamp: timestamp,
            ),
          );
        }
      }
      messages.refresh();
    } catch (error, stackTrace) {
      _logDebug('fetchChatMessages failed', error, stackTrace);
      messageError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load this chat. Please try again.',
      );
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> selectChat(int id, String name) async {
    selectedChatId.value = id;
    selectedChatName.value = name;
    messages.clear();
    messages.refresh();

    try {
      final maxId = await getMaxMessageId(id);
      messageCounter.value = maxId != null && maxId > 0 ? maxId + 1 : 1;
      await fetchChatMessages(id);
    } catch (error, stackTrace) {
      _logDebug('selectChat failed', error, stackTrace);
      messageError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to open this chat. Please try again.',
      );
    }
  }

  void createNewChat(String name) {
    final id = chatCounter.value;
    chatCounter.value++;
    chats[id] = name;
    messages.clear();
    messages.refresh();
    selectedChatId.value = id;
    selectedChatName.value = name;
  }

  Future<void> pickImage() async {
    if (selectedChatId.value == 0) {
      PLoaders.warningSnackBar(
        title: 'Select a Chat',
        message: 'Please create or select a chat before adding an image.',
      );
      return;
    }
    if (kIsWeb) {
      PLoaders.warningSnackBar(
        title: 'Image Unavailable',
        message: 'Image selection is not available on this platform.',
      );
      return;
    }

    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) {
        throw const AppUserFacingException(
          'The selected image could not be read. Please choose another image.',
        );
      }

      pickedImagePath.value = picked.path;
      pendingImageBytes.value = bytes;
      pendingImageName.value = picked.name;
      pendingImageMime.value = _guessImageMimeType(picked.path);
    } catch (error, stackTrace) {
      _logDebug('pickImage failed', error, stackTrace);
      PLoaders.errorSnackBar(
        title: 'Image Selection Failed',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to open that image. Please try another one.',
        ),
      );
    }
  }

  Future<void> _uploadImageMessage({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    required int localMessageId,
    String? text,
  }) async {
    isImageUploading.value = true;
    try {
      final baseUrl = _requireApiBaseUrl();
      final userId = _requireUserId();
      final mediaType = MediaType.parse(mimeType);
      final request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/chat/message/image/'))
            ..fields['user_id'] = userId
            ..fields['user_name'] = uName ?? 'User'
            ..fields['user_email'] = uEmail ?? 'user@example.com'
            ..fields['chat_id'] = selectedChatId.value.toString()
            ..fields['chat_name'] = selectedChatName.value
            ..fields['message_id'] = localMessageId.toString()
            ..fields['time_stamp'] = DateTime.now().toUtc().toIso8601String()
            ..fields['content'] = text ?? ''
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                bytes,
                filename: fileName,
                contentType: mediaType,
              ),
            );

      final streamed =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to upload the image. Please try again.',
          ),
        );
      }

      final decoded = safeDecodeJson(response.body);
      if (decoded is! Map) {
        throw const FormatException('Invalid image response.');
      }
      final aiText = decoded['ai_response'] ?? decoded['aiResponse'] ?? '';
      final imageUrl = decoded['image_url'] ?? decoded['imageUrl'];
      if ((aiText is String && aiText.isNotEmpty) ||
          (imageUrl is String && imageUrl.isNotEmpty)) {
        messages.add(
          MessageModel(
            chatId: selectedChatId.value,
            chatName: selectedChatName.value,
            sender: 'assistant',
            messageId: localMessageId,
            content: aiText is String ? aiText : '',
            imageUrl: imageUrl is String ? imageUrl : null,
            timestamp: DateTime.now().toUtc().toIso8601String(),
          ),
        );
      }
    } catch (error, stackTrace) {
      _logDebug('image upload failed', error, stackTrace);
      PLoaders.errorSnackBar(
        title: 'Image Upload Failed',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to upload the image. Please try again.',
        ),
      );
    } finally {
      isImageUploading.value = false;
    }
  }

  String _guessImageMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/*';
  }

  Future<void> updateChatName(int chatId, String newName) async {
    try {
      final baseUrl = _requireApiBaseUrl();
      final userId = _requireUserId();
      final response = await http
          .patch(
            Uri.parse(
              '$baseUrl/chat/name/update/${Uri.encodeComponent(userId)}/$chatId/${Uri.encodeComponent(newName)}',
            ),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to update the chat name. Please try again.',
          ),
        );
      }

      final decoded = safeDecodeJson(response.body);
      if (decoded is! Map) {
        throw const FormatException('Invalid rename response.');
      }
      final rename = ChatRenameResponse.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      chats[rename.chatId] = rename.chatName;
      if (selectedChatId.value == rename.chatId) {
        selectedChatName.value = rename.chatName;
      }
      chats.refresh();
    } catch (error, stackTrace) {
      _logDebug('updateChatName failed', error, stackTrace);
      PLoaders.errorSnackBar(
        title: 'Update Failed',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to update the chat name. Please try again.',
        ),
      );
      rethrow;
    }
  }

  Future<void> deleteChat(int chatId) async {
    try {
      final baseUrl = _requireApiBaseUrl();
      final userId = _requireUserId();
      final response = await http
          .delete(
            Uri.parse(
              '$baseUrl/chat/delete/${Uri.encodeComponent(userId)}/$chatId',
            ),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to delete this chat. Please try again.',
          ),
        );
      }

      final decoded = safeDecodeJson(response.body);
      if (decoded is! Map) {
        throw const FormatException('Invalid delete response.');
      }
      final result = ChatDeleteResponse.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      if (!result.deleted) return;

      chats.remove(result.chatId);
      chats.refresh();
      if (selectedChatId.value == result.chatId) {
        selectedChatId.value = 0;
        selectedChatName.value = '';
        messages.clear();
        messages.refresh();
      }
    } catch (error, stackTrace) {
      _logDebug('deleteChat failed', error, stackTrace);
      PLoaders.errorSnackBar(
        title: 'Delete Failed',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to delete this chat. Please try again.',
        ),
      );
    }
  }

  Future<void> textToSpeech(String text, int messageId) async {
    try {
      await audioController.textToSpeech(text, messageId);
    } catch (error, stackTrace) {
      _showAudioError('Unable to create audio. Please try again.', error,
          stackTrace);
    }
  }

  Future<void> playAudio(int messageId) async {
    try {
      await audioController.playAudio(messageId);
    } catch (error, stackTrace) {
      _showAudioError('Unable to play audio. Please try again.', error,
          stackTrace);
    }
  }

  Future<void> stopAudio() async {
    try {
      await audioController.stopAudio();
    } catch (error, stackTrace) {
      _logDebug('stopAudio failed', error, stackTrace);
    }
  }

  Future<void> startVoiceInput() async {
    try {
      await audioController.startVoiceInput();
    } catch (error, stackTrace) {
      _showAudioError(
        'Unable to start voice input. Please try again.',
        error,
        stackTrace,
      );
    }
  }

  Future<void> cancelVoiceInput() async {
    try {
      await audioController.cancelVoiceInput();
    } catch (error, stackTrace) {
      _logDebug('cancelVoiceInput failed', error, stackTrace);
    }
  }

  Future<void> stopVoiceAndConvert() async {
    try {
      final result = await audioController.stopVoiceAndConvert();
      if (result != null && result.text.isNotEmpty) {
        inputTextController.text = result.text.trim();
      }
    } catch (error, stackTrace) {
      _showAudioError(
        'Unable to convert the recording. Please try again.',
        error,
        stackTrace,
      );
    }
  }

  void clearPendingImage() {
    pendingImageBytes.value = null;
    pendingImageName.value = '';
    pendingImageMime.value = '';
    pickedImagePath.value = '';
  }

  Future<SpeechToTextResponse?> speechToText(
    Uint8List audioBytes, {
    String fileName = 'audio.ogg',
    String mimeType = 'audio/ogg',
  }) async {
    try {
      return await audioController.speechToText(
        audioBytes,
        fileName: fileName,
        mimeType: mimeType,
      );
    } catch (error, stackTrace) {
      _showAudioError(
        'Unable to convert the recording. Please try again.',
        error,
        stackTrace,
      );
      return null;
    }
  }

  Future<int?> getMaxMessageId(int chatId) async {
    try {
      final baseUrl = _requireApiBaseUrl();
      final userId = _requireUserId();
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/user/chat/max-message-id/${Uri.encodeComponent(userId)}/$chatId',
            ),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) return null;

      final decoded = safeDecodeJson(response.body);
      if (decoded is! Map) return null;
      return MaxMessageIdResponse.fromJson(
        Map<String, dynamic>.from(decoded),
      ).maxMessageId;
    } catch (error, stackTrace) {
      _logDebug('getMaxMessageId failed', error, stackTrace);
      return null;
    }
  }

  String _parseTimestamp(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      return value[r'$date']?.toString() ??
          value['\$date']?.toString() ??
          value.toString();
    }
    return value.toString();
  }

  String _requireApiBaseUrl() {
    final value = apisBaseUrl?.trim() ?? '';
    final uri = Uri.tryParse(value);
    if (value.isEmpty ||
        uri == null ||
        !uri.hasScheme ||
        (uri.host.isEmpty && !kIsWeb)) {
      throw const AppConfigurationException(
        'Peace Guider is temporarily unavailable. Please try again later.',
      );
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  String _requireUserId() {
    final value = uId?.trim() ?? '';
    if (value.isEmpty) {
      throw const AppUserFacingException(
        'Please sign in again to continue.',
      );
    }
    return value;
  }

  int _streamingMessageIndex(MessageModel source) {
    return messages.lastIndexWhere(
      (candidate) =>
          candidate.sender == 'assistant' &&
          candidate.chatId == source.chatId &&
          candidate.messageId == source.messageId &&
          candidate.isStreaming,
    );
  }

  void _handleBillingPayload(String body, {required int statusCode}) {
    try {
      BillingGateHelper.handleError(
        billingApiExceptionFromJson(
          safeDecodeJson(body),
          statusCode: statusCode,
        ).error,
      );
    } catch (error, stackTrace) {
      _logDebug('billing payload parse failed', error, stackTrace);
    }
  }

  void _showAudioError(
    String fallback,
    Object error,
    StackTrace stackTrace,
  ) {
    _logDebug('audio operation failed', error, stackTrace);
    PLoaders.errorSnackBar(
      title: 'Audio Failed',
      message: AppErrorMessage.fromException(error, fallback: fallback),
    );
  }

  void _logDebug(String context, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('[IslamicGuiderController] $context: $error');
    debugPrint(stackTrace.toString());
  }
}

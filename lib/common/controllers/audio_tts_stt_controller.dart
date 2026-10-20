import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show pow;
import 'dart:typed_data';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/helpers/billing_gate_helper.dart';
import 'package:ecommerce_app/features/billing/services/billing_api_service.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/tts_response_model.dart';
import '../models/speech_to_text_response.dart';
import '../models/tts_single_response_model.dart';

enum VoiceInputState { idle, recording, processing }

class AudioTTSSTTController extends GetxController {
  final String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  // TTS related
  final ttsResponse = Rxn<TTSResponse>();
  final ttsSingleResponse = Rxn<TTSSingleResponse>();
  final isTTSLoading = false.obs;
  final currentTTSMessageId = Rxn<int>();

  // STT related
  final sttResponse = Rxn<SpeechToTextResponse>();
  final isSTTLoading = false.obs;

  // Voice input related
  final voiceState = VoiceInputState.idle.obs;
  final voiceAmplitude = 0.0.obs;
  final voiceAmplitudes = <double>[].obs;
  final recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _ampSub;
  static const int maxWaveformBars = 60;

  // Waveform smoothing
  List<double> _smoothedAmplitudes = [];
  static const double _smoothingFactor =
      0.25; // Exponential smoothing (lower = smoother)
  List<double> _amplitudeBuffer = []; // Buffer for moving average

  // Audio playback related
  final audioPlayer = AudioPlayer();
  final isAudioPlaying = false.obs;
  final currentPlayingMessageId = Rxn<int>();
  final audioCache = <int, Uint8List>{};

  @override
  Future<void> onInit() async {
    super.onInit();

    // Listen to audio player state changes
    audioPlayer.onPlayerStateChanged.listen((state) {
      isAudioPlaying.value = state == PlayerState.playing;
      if (state == PlayerState.completed) {
        currentPlayingMessageId.value = null;
      }
    });
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    _ampSub?.cancel();
    recorder.dispose();
    super.onClose();
  }

  /// Text to Speech
  Future<void> textToSpeech(String text, int messageId) async {
    try {
      final baseUrl = _requireApiBaseUrl();
      if (!await BillingGateHelper.ensureFeatureAccess(
        BillingFeatureKeys.textToSpeech,
      )) {
        return;
      }

      currentTTSMessageId.value = messageId;
      isTTSLoading.value = true;
      final url =
          Uri.parse('$baseUrl/text-to-speech/mms/multilang-paragraph');
      final request = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..headers['Idempotency-Key'] = BillingRequestId.newKey()
        ..body = jsonEncode({
          'text': text,
        });

      final client = http.Client();
      try {
        final response = await client
            .send(request)
            .timeout(const Duration(seconds: 30));
        if (response.statusCode != 200) {
          await _handleBillingFailure(response);
          throw AppUserFacingException(
            AppErrorMessage.fromStatusCode(
              response.statusCode,
              fallback: 'Unable to create audio. Please try again.',
            ),
          );
        }
        final responseBody = await response.stream
            .bytesToString()
            .timeout(const Duration(seconds: 20));
        final decoded = safeDecodeJson(responseBody);
        if (decoded is! Map) {
          throw const FormatException('Invalid text-to-speech response.');
        }
        final data = Map<String, dynamic>.from(decoded);
        _updateBillingUsage(data);
        ttsResponse.value = TTSResponse.fromJson(data);

        if (ttsResponse.value?.audioData.isNotEmpty ?? false) {
          final audioBytes = base64Decode(ttsResponse.value!.audioData);
          audioCache[messageId] = audioBytes;
          await playAudio(messageId);
        }
      } finally {
        client.close();
      }
    } catch (error, stackTrace) {
      _logDebug('Text-to-speech failed.', error, stackTrace);
      ttsResponse.value = null;
      PLoaders.errorSnackBar(
        title: 'Audio Failed',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to create audio. Please try again.',
        ),
      );
    } finally {
      isTTSLoading.value = false;
      currentTTSMessageId.value = null;
    }
  }

  /// Text to Speech - single language endpoint (for worships & lifeevents)
  Future<void> textToSpeechSingleLanguage(String text, int messageId,
      {String language = 'ur'}) async {
    try {
      final baseUrl = _requireApiBaseUrl();
      if (!await BillingGateHelper.ensureFeatureAccess(
        BillingFeatureKeys.textToSpeech,
      )) {
        return;
      }

      currentTTSMessageId.value = messageId;
      isTTSLoading.value = true;
      final url = Uri.parse('$baseUrl/text-to-speech/mms/single-language');
      final request = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..headers['Idempotency-Key'] = BillingRequestId.newKey()
        ..body = jsonEncode({'language': language, 'text': text});

      final client = http.Client();
      try {
        final response = await client
            .send(request)
            .timeout(const Duration(seconds: 30));
        if (response.statusCode != 200) {
          await _handleBillingFailure(response);
          throw AppUserFacingException(
            AppErrorMessage.fromStatusCode(
              response.statusCode,
              fallback: 'Unable to create audio. Please try again.',
            ),
          );
        }
        final responseBody = await response.stream
            .bytesToString()
            .timeout(const Duration(seconds: 20));
        final decoded = safeDecodeJson(responseBody);
        if (decoded is! Map) {
          throw const FormatException('Invalid text-to-speech response.');
        }
        final data = Map<String, dynamic>.from(decoded);
        _updateBillingUsage(data);
        ttsSingleResponse.value = TTSSingleResponse.fromJson(data);

        if (ttsSingleResponse.value?.audioData.isNotEmpty ?? false) {
          final audioBytes = base64Decode(ttsSingleResponse.value!.audioData);
          audioCache[messageId] = audioBytes;
          await playAudio(messageId);
        }
      } finally {
        client.close();
      }
    } catch (error, stackTrace) {
      _logDebug('Single-language text-to-speech failed.', error, stackTrace);
      ttsSingleResponse.value = null;
      PLoaders.errorSnackBar(
        title: 'Audio Failed',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to create audio. Please try again.',
        ),
      );
    } finally {
      isTTSLoading.value = false;
      currentTTSMessageId.value = null;
    }
  }

  /// Play audio from cache
  Future<void> playAudio(int messageId) async {
    try {
      // If same audio is playing, pause it
      if (currentPlayingMessageId.value == messageId && isAudioPlaying.value) {
        await audioPlayer.pause();
        currentPlayingMessageId.value = null;
        return;
      }

      // Check if audio is cached
      final audioBytes = audioCache[messageId];
      if (audioBytes == null) {
        return;
      }

      // Stop any currently playing audio
      await audioPlayer.stop();

      // Play the audio from bytes
      currentPlayingMessageId.value = messageId;
      await audioPlayer.play(BytesSource(audioBytes));
    } catch (error, stackTrace) {
      _logDebug('Audio playback failed.', error, stackTrace);
      currentPlayingMessageId.value = null;
      PLoaders.errorSnackBar(
        title: 'Playback Failed',
        message: 'Unable to play audio. Please try again.',
      );
    }
  }

  /// Stop audio playback
  Future<void> stopAudio() async {
    try {
      await audioPlayer.stop();
    } catch (error, stackTrace) {
      _logDebug('Audio stop failed.', error, stackTrace);
    } finally {
      currentPlayingMessageId.value = null;
    }
  }

  /// Start voice input recording
  Future<void> startVoiceInput() async {
    if (kIsWeb) {
      PLoaders.warningSnackBar(
        title: 'Voice Input',
        message: 'Voice input is not available on this platform.',
      );
      return;
    }
    if (!await BillingGateHelper.ensureFeatureAccess(
      BillingFeatureKeys.voiceInput,
    )) {
      return;
    }

    try {
      var status = await Permission.microphone.status;
      if (status.isDenied || status.isRestricted) {
        status = await Permission.microphone.request();
      }

      if (status.isPermanentlyDenied) {
        PLoaders.warningSnackBar(
          title: 'Microphone Permission',
          message:
              'Microphone access is disabled. Enable it in app settings.',
          duration: 5,
          actionLabel: 'Settings',
          onAction: openAppSettings,
        );
        return;
      }

      if (!status.isGranted) {
        PLoaders.warningSnackBar(
          title: 'Permission Required',
          message: 'Microphone permission is needed for voice input.',
          duration: 5,
        );
        return;
      }

      voiceState.value = VoiceInputState.recording;
      voiceAmplitude.value = 0;
      voiceAmplitudes.clear();

      await _ampSub?.cancel();
      _smoothedAmplitudes = [];
      _amplitudeBuffer = [];
      _ampSub = recorder
          .onAmplitudeChanged(const Duration(milliseconds: 50))
          .listen((amp) {
        // Better normalization: -60dB to 0dB range
        // Clamp to -60 to 0 range, then normalize to 0-1
        final normalizedAmp = ((amp.current + 90) / 90).clamp(0, 1);

        // Apply power curve for better visual representation
        final level = pow(normalizedAmp, 0.8).toDouble();

        // Add to buffer for moving average
        _amplitudeBuffer.add(level);
        if (_amplitudeBuffer.length > 3) {
          _amplitudeBuffer.removeAt(0);
        }

        // Calculate moving average
        final movingAvg = _amplitudeBuffer.isNotEmpty
            ? _amplitudeBuffer.reduce((a, b) => a + b) / _amplitudeBuffer.length
            : level;

        // Apply exponential smoothing
        double smoothed;
        if (_smoothedAmplitudes.isEmpty) {
          smoothed = movingAvg;
        } else {
          final lastSmoothed = _smoothedAmplitudes.last;
          smoothed = (lastSmoothed * (1 - _smoothingFactor)) +
              (movingAvg * _smoothingFactor);
        }

        _smoothedAmplitudes.add(smoothed);
        voiceAmplitude.value = smoothed;

        // Keep last 25 smoothed values for better waveform visualization
        if (voiceAmplitudes.isNotEmpty || _smoothedAmplitudes.length > 1) {
          voiceAmplitudes.add(smoothed);
          if (voiceAmplitudes.length > maxWaveformBars) {
            voiceAmplitudes.removeAt(0);
          }
        }
      }, onError: (Object error, StackTrace stackTrace) {
        _logDebug('Voice amplitude monitoring failed.', error, stackTrace);
        unawaited(cancelVoiceInput());
        PLoaders.errorSnackBar(
          title: 'Recording Error',
          message: 'Recording stopped unexpectedly. Please try again.',
        );
      }, cancelOnError: true);

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          bitRate: 128000,
        ),
        path: filePath,
      );
    } catch (error, stackTrace) {
      _logDebug('Voice recording failed to start.', error, stackTrace);
      await _ampSub?.cancel();
      _ampSub = null;
      voiceState.value = VoiceInputState.idle;

      PLoaders.errorSnackBar(
        title: 'Recording Error',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to start voice recording. Please try again.',
        ),
      );
    }
  }

  /// Cancel voice input
  Future<void> cancelVoiceInput() async {
    try {
      await _ampSub?.cancel();
      _ampSub = null;
      _smoothedAmplitudes = [];
      _amplitudeBuffer = [];
      voiceAmplitude.value = 0;
      Future.delayed(const Duration(milliseconds: 150), () {
        voiceAmplitudes.clear();
      });
      if (await recorder.isRecording()) {
        await recorder.stop();
      }
    } catch (error, stackTrace) {
      _logDebug('Voice recording cancellation failed.', error, stackTrace);
    } finally {
      voiceState.value = VoiceInputState.idle;
    }
  }

  /// Stop voice recording and convert to text
  Future<SpeechToTextResponse?> stopVoiceAndConvert() async {
    if (voiceState.value != VoiceInputState.recording) return null;

    voiceState.value = VoiceInputState.processing;
    _ampSub?.cancel();
    _ampSub = null;
    _smoothedAmplitudes = [];
    _amplitudeBuffer = [];
    voiceAmplitude.value = 0;

    try {
      final path = await recorder.stop();

      if (path == null) {
        voiceState.value = VoiceInputState.idle;
        return null;
      }

      // Give the file system a moment to flush the recording
      await Future.delayed(const Duration(milliseconds: 800));

      final file = File(path);
      if (!await file.exists()) {
        voiceState.value = VoiceInputState.idle;
        return null;
      }

      final bytes = await file.readAsBytes();
      final fileSize = bytes.length;

      if (fileSize == 0) {
        voiceState.value = VoiceInputState.idle;
        return null;
      }

      final mime = _guessMimeType(path);
      final name = path.split('/').last;

      final result = await speechToText(
        bytes,
        fileName: name,
        mimeType: mime,
      );

      return result;
    } catch (error, stackTrace) {
      _logDebug('Voice conversion failed.', error, stackTrace);
      PLoaders.errorSnackBar(
        title: 'Voice Input Failed',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to convert the recording. Please try again.',
        ),
      );
      return null;
    } finally {
      voiceState.value = VoiceInputState.idle;
      _ampSub?.cancel();
      _ampSub = null;
      _smoothedAmplitudes = [];
      _amplitudeBuffer = [];
      // Don't clear immediately - let animation complete
      Future.delayed(const Duration(milliseconds: 150), () {
        voiceAmplitudes.clear();
      });
    }
  }

  /// Speech to Text
  Future<SpeechToTextResponse?> speechToText(
    Uint8List audioBytes, {
    String fileName = 'audio.ogg',
    String mimeType = 'audio/ogg',
  }) async {
    try {
      final baseUrl = _requireApiBaseUrl();
      if (!await BillingGateHelper.ensureFeatureAccess(
        BillingFeatureKeys.voiceInput,
      )) {
        return null;
      }

      isSTTLoading.value = true;
      final url = Uri.parse('$baseUrl/speech-to-text');
      final mediaType = MediaType.parse(mimeType);

      final request = http.MultipartRequest('POST', url)
        ..headers['Idempotency-Key'] = BillingRequestId.newKey()
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            audioBytes,
            filename: fileName,
            contentType: mediaType,
          ),
        );

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          sttResponse.value = null;
          return null;
        }

        final decoded = safeDecodeJson(response.body);
        if (decoded is! Map) {
          throw const FormatException('Invalid speech-to-text response.');
        }
        final data = Map<String, dynamic>.from(decoded);
        _updateBillingUsage(data);
        final result = SpeechToTextResponse.fromJson(data);
        sttResponse.value = result;
        return result;
      } else {
        BillingGateHelper.handleError(
          billingApiExceptionFromJson(
            safeDecodeJson(response.body),
            statusCode: response.statusCode,
          ).error,
        );
        PLoaders.errorSnackBar(
          title: 'Voice Input Failed',
          message: ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to convert the recording. Please try again.',
          ),
        );
        sttResponse.value = null;
        return null;
      }
    } catch (error, stackTrace) {
      _logDebug('Speech-to-text failed.', error, stackTrace);
      sttResponse.value = null;
      PLoaders.errorSnackBar(
        title: 'Voice Input Failed',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to convert the recording. Please try again.',
        ),
      );
      return null;
    } finally {
      isSTTLoading.value = false;
    }
  }

  /// Guess mime type from file path
  String _guessMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.wav')) return 'audio/wav';
    if (lower.endsWith('.m4a') || lower.endsWith('.mp4')) return 'audio/mp4';
    if (lower.endsWith('.aac')) return 'audio/aac';
    if (lower.endsWith('.ogg') || lower.endsWith('.opus')) return 'audio/ogg';
    return 'audio/*';
  }

  /// Clear audio cache for specific message
  void clearAudioCache(int messageId) {
    audioCache.remove(messageId);
  }

  /// Clear all audio cache
  void clearAllAudioCache() {
    audioCache.clear();
  }

  void _updateBillingUsage(Map<String, dynamic> data) {
    final dynamic billing = data['billing'];
    if (billing is Map && Get.isRegistered<BillingController>()) {
      BillingController.instance.updateUsageFromBillingMetadata(
        Map<String, dynamic>.from(billing),
      );
    }
  }

  Future<void> _handleBillingFailure(http.StreamedResponse response) async {
    final String body = await response.stream
        .bytesToString()
        .timeout(const Duration(seconds: 20));
    BillingGateHelper.handleError(
      billingApiExceptionFromJson(
        safeDecodeJson(body),
        statusCode: response.statusCode,
      ).error,
    );
  }

  String _requireApiBaseUrl() {
    final value = apisBaseUrl?.trim() ?? '';
    final uri = Uri.tryParse(value);
    if (value.isEmpty || uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const AppConfigurationException(
        'Audio services are temporarily unavailable.',
      );
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  void _logDebug(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode) return;
    debugPrint('[AudioTTSSTT] $message');
    if (error != null) debugPrint(error.toString());
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }
}

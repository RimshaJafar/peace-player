import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/helpers/billing_gate_helper.dart';
import 'package:ecommerce_app/features/billing/services/billing_api_service.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:record/record.dart';

import '../models/navigation_response.dart';

enum VoiceNavState { idle, listening, processing, error, success }

class VoiceNavigationController extends GetxController {
  final _recorder = AudioRecorder();
  final String apiUrl;

  PorcupineManager? _wakeWordManager;
  String? _filePath;

  final state = VoiceNavState.idle.obs;
  final transcription = ''.obs;
  final errorMessage = ''.obs;

  Timer? _silenceTimer;
  Timer? _maxListeningTimer;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  bool _hasDetectedSpeech = false;
  bool _isStoppingAndProcessing = false;
  int _speechDetectionCount = 0;
  double _noiseFloorDb = -55.0;

  static const int minSpeechDetections = 3;
  static const silenceTimeoutNoSpeech = Duration(seconds: 5);
  static const silenceTimeoutAfterSpeech = Duration(seconds: 2);
  static const maxListeningDuration = Duration(seconds: 8);
  static const double minSpeechStartDb = -23.0;
  static const double minSpeechContinueDb = -26.0;
  static const double noiseFloorMarginStartDb = 10.0;
  static const double noiseFloorMarginContinueDb = 7.0;

  VoiceNavigationController({required this.apiUrl});

  Future<void> startWakeWordService() async {
    try {
      if (_wakeWordManager != null) {
        await _wakeWordManager!.start();
        return;
      }

      final accessKey = dotenv.env['PORCUPINE_ACCESS_KEY']?.trim() ?? '';
      if (accessKey.isEmpty) {
        _setError('Voice activation is temporarily unavailable.');
        _logDebug('PORCUPINE_ACCESS_KEY is missing.');
        return;
      }

      final keywordPath = _wakeWordKeywordPath();
      if (keywordPath == null) {
        _setError('Wake-word navigation is not supported on this device.');
        return;
      }

      _wakeWordManager = await PorcupineManager.fromKeywordPaths(
        accessKey,
        [keywordPath],
        (index) {
          _logDebug('Wake word detected at index $index.');
          unawaited(onWakeWordDetected());
        },
        errorCallback: (error) {
          _logDebug('Wake-word callback failed.', error);
          if (state.value == VoiceNavState.idle) {
            _setError('Voice activation stopped. Please try again.');
          }
        },
      );
      await _wakeWordManager!.start();
      _logDebug('Wake-word service started.');
    } catch (error, stackTrace) {
      _logDebug('Wake-word initialization failed.', error, stackTrace);
      _setError('Voice activation could not start. Please try again.');
    }
  }

  String? _wakeWordKeywordPath() {
    if (Platform.isIOS) return 'assets/porcupine/peace_en_ios.ppn';
    if (Platform.isAndroid) return 'assets/porcupine/peace_en_android.ppn';
    return null;
  }

  Future<void> stopWakeWordService() async {
    try {
      await _wakeWordManager?.stop();
      await _wakeWordManager?.delete();
    } catch (error, stackTrace) {
      _logDebug('Wake-word shutdown failed.', error, stackTrace);
    } finally {
      _wakeWordManager = null;
    }
  }

  Future<void> startRecording(String filePath) async {
    try {
      _filePath = filePath;
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav, bitRate: 128000),
        path: filePath,
      );
      _startAmplitudeMonitoring();
    } catch (error, stackTrace) {
      _logDebug('Recording failed to start.', error, stackTrace);
      await _cancelAmplitudeMonitoring();
      throw const AppUserFacingException(
        'Recording could not start. Please try again.',
      );
    }
  }

  void _startAmplitudeMonitoring() {
    unawaited(_cancelAmplitudeMonitoring());
    _amplitudeSubscription =
        _recorder.onAmplitudeChanged(const Duration(milliseconds: 200)).listen(
      (amplitude) {
        if (state.value != VoiceNavState.listening) return;
        _updateNoiseFloor(amplitude.current);

        if (_isSpeechStart(amplitude.current)) {
          _speechDetectionCount++;
          if (_speechDetectionCount >= minSpeechDetections &&
              !_hasDetectedSpeech) {
            _hasDetectedSpeech = true;
            _startSilenceTimer();
          } else if (_hasDetectedSpeech &&
              _isSpeechContinue(amplitude.current)) {
            _startSilenceTimer();
          }
        } else {
          if (_speechDetectionCount > 0 && !_hasDetectedSpeech) {
            _speechDetectionCount--;
          }
          if (_hasDetectedSpeech && _isSpeechContinue(amplitude.current)) {
            _startSilenceTimer();
          }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        _logDebug('Amplitude monitoring failed.', error, stackTrace);
        if (state.value == VoiceNavState.listening) {
          unawaited(_handleRecordingFailure());
        }
      },
      cancelOnError: true,
    );
  }

  void _updateNoiseFloor(double currentDb) {
    if (currentDb > -5) return;
    final maxNoiseSample = _noiseFloorDb + 6.0;
    final sample = math.min(currentDb, maxNoiseSample);
    _noiseFloorDb = (_noiseFloorDb * 0.9) + (sample * 0.1);
  }

  bool _isSpeechStart(double currentDb) {
    final threshold =
        math.max(minSpeechStartDb, _noiseFloorDb + noiseFloorMarginStartDb);
    return currentDb >= threshold;
  }

  bool _isSpeechContinue(double currentDb) {
    final threshold = math.max(
      minSpeechContinueDb,
      _noiseFloorDb + noiseFloorMarginContinueDb,
    );
    return currentDb >= threshold;
  }

  Future<String?> stopRecording() async {
    try {
      await _cancelAmplitudeMonitoring();
      final path = await _recorder.stop();
      return path ?? _filePath;
    } catch (error, stackTrace) {
      _logDebug('Recording failed to stop.', error, stackTrace);
      throw const AppUserFacingException(
        'Recording could not be completed. Please try again.',
      );
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _cancelAmplitudeMonitoring();
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (error, stackTrace) {
      _logDebug('Recording cancellation failed.', error, stackTrace);
    }
  }

  Future<NavigationResponse?> sendAudio(File audioFile) async {
    final uri = Uri.tryParse(apiUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const AppConfigurationException(
        'Voice navigation is temporarily unavailable.',
      );
    }
    if (!await audioFile.exists() || await audioFile.length() == 0) {
      throw const AppUserFacingException(
        'The recording was empty. Please try again.',
      );
    }

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Idempotency-Key'] = BillingRequestId.newKey()
        ..files.add(
          await http.MultipartFile.fromPath('audio', audioFile.path),
        );
      final response =
          await request.send().timeout(const Duration(seconds: 30));
      final body = await response.stream
          .bytesToString()
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        _handleBillingFailure(body, response.statusCode);
        throw AppUserFacingException(
          AppErrorMessage.fromStatusCode(
            response.statusCode,
            parsedMessage:
                ApiErrorParser.messageFromDecoded(safeDecodeJson(body)),
            fallback: 'Voice navigation could not process the recording.',
          ),
        );
      }

      final decoded = safeDecodeJson(body);
      if (decoded is! Map) {
        throw const FormatException('Invalid voice navigation response.');
      }
      final data = Map<String, dynamic>.from(decoded);
      final billing = data['billing'];
      if (billing is Map && Get.isRegistered<BillingController>()) {
        BillingController.instance.updateUsageFromBillingMetadata(
          Map<String, dynamic>.from(billing),
        );
      }
      return NavigationResponse.fromJson(data);
    } catch (error, stackTrace) {
      _logDebug('Audio upload failed.', error, stackTrace);
      if (error is AppUserFacingException ||
          error is AppConfigurationException) {
        rethrow;
      }
      throw AppUserFacingException(
        AppErrorMessage.fromException(
          error,
          fallback: 'Voice navigation could not process the recording.',
        ),
      );
    }
  }

  static void handleBackendRoute(String? backendRoute) {
    if (backendRoute != null && backendRoute.trim().isNotEmpty) {
      Get.toNamed(backendRoute);
    }
  }

  Future<void> onWakeWordDetected() async {
    if (state.value == VoiceNavState.listening ||
        state.value == VoiceNavState.processing ||
        _isStoppingAndProcessing) {
      return;
    }

    var recordingStarted = false;
    try {
      if (!await BillingGateHelper.ensureFeatureAccess(
        BillingFeatureKeys.voiceNavigation,
      )) {
        return;
      }

      final permission = await Permission.microphone.request();
      if (permission.isPermanentlyDenied) {
        _setError(
          'Microphone access is disabled. Enable it in app settings.',
        );
        PLoaders.warningSnackBar(
          title: 'Microphone Permission',
          message: 'Microphone access is disabled. Enable it in app settings.',
          actionLabel: 'Settings',
          onAction: openAppSettings,
        );
        return;
      }
      if (!permission.isGranted) {
        _setError('Microphone permission is required for voice navigation.');
        PLoaders.warningSnackBar(
          title: 'Microphone Permission',
          message: 'Microphone permission is required for voice navigation.',
        );
        return;
      }

      await _wakeWordManager?.stop();
      await HapticFeedback.vibrate();
      _resetSpeechDetection();
      errorMessage.value = '';
      state.value = VoiceNavState.listening;

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/voice_nav.wav';
      await startRecording(filePath);
      recordingStarted = true;
      _startSilenceTimer();
      _startMaxListeningTimer();
    } catch (error, stackTrace) {
      _logDebug('Wake-word command start failed.', error, stackTrace);
      await cancelRecording();
      _showUserTriggeredError(
        AppErrorMessage.fromException(
          error,
          fallback: 'Voice navigation could not start. Please try again.',
        ),
      );
    } finally {
      if (!recordingStarted) {
        await _resumeWakeWordService();
      }
    }
  }

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    final timeout =
        _hasDetectedSpeech ? silenceTimeoutAfterSpeech : silenceTimeoutNoSpeech;
    _silenceTimer = Timer(timeout, () {
      unawaited(_onSilenceDetected());
    });
  }

  void _startMaxListeningTimer() {
    _maxListeningTimer?.cancel();
    _maxListeningTimer = Timer(maxListeningDuration, () {
      unawaited(_onMaxListeningReached());
    });
  }

  void onUserSpeaking() {
    _hasDetectedSpeech = true;
    _startSilenceTimer();
  }

  Future<void> onCloseWordDetected() async {
    _hasDetectedSpeech = true;
    await _stopAndProcess();
  }

  Future<void> _onSilenceDetected() async {
    try {
      _maxListeningTimer?.cancel();
      if (!_hasDetectedSpeech) {
        await cancelRecording();
        state.value = VoiceNavState.idle;
        await _resumeWakeWordService();
        return;
      }
      await _stopAndProcess();
    } catch (error, stackTrace) {
      _logDebug('Silence handling failed.', error, stackTrace);
      _showUserTriggeredError(
        'Recording could not be completed. Please try again.',
      );
      await _resumeWakeWordService();
    }
  }

  Future<void> _onMaxListeningReached() async {
    if (state.value != VoiceNavState.listening || _isStoppingAndProcessing) {
      return;
    }

    try {
      if (!_hasDetectedSpeech) {
        await cancelRecording();
        state.value = VoiceNavState.idle;
        await _resumeWakeWordService();
        return;
      }
      await _stopAndProcess();
    } catch (error, stackTrace) {
      _logDebug('Maximum listening handling failed.', error, stackTrace);
      _showUserTriggeredError(
        'Recording could not be completed. Please try again.',
      );
      await _resumeWakeWordService();
    }
  }

  Future<void> _stopAndProcess() async {
    if (_isStoppingAndProcessing) return;
    _isStoppingAndProcessing = true;
    _silenceTimer?.cancel();
    _maxListeningTimer?.cancel();
    File? audioFile;

    try {
      state.value = VoiceNavState.processing;
      final filePath = await stopRecording();
      if (filePath == null || filePath.trim().isEmpty) {
        throw const AppUserFacingException(
          'Recording could not be completed. Please try again.',
        );
      }

      audioFile = File(filePath);
      final response = await sendAudio(audioFile);
      if (response == null || !response.success || response.route == null) {
        throw AppUserFacingException(
          AppErrorMessage.sanitize(response?.message) ??
              'I did not understand. Please try again.',
        );
      }

      transcription.value = response.transcription;
      state.value = VoiceNavState.success;
      await HapticFeedback.lightImpact();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      handleBackendRoute(response.route);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      state.value = VoiceNavState.idle;
    } catch (error, stackTrace) {
      _logDebug('Voice command processing failed.', error, stackTrace);
      _showUserTriggeredError(
        AppErrorMessage.fromException(
          error,
          fallback: 'Voice navigation failed. Please try again.',
        ),
      );
    } finally {
      _isStoppingAndProcessing = false;
      await _deleteTemporaryFile(audioFile);
      await _resumeWakeWordService();
    }
  }

  Future<void> _handleRecordingFailure() async {
    await cancelRecording();
    _showUserTriggeredError(
      'Recording stopped unexpectedly. Please try again.',
    );
    await _resumeWakeWordService();
  }

  Future<void> _cancelAmplitudeMonitoring() async {
    try {
      await _amplitudeSubscription?.cancel();
    } catch (error, stackTrace) {
      _logDebug('Amplitude subscription cleanup failed.', error, stackTrace);
    } finally {
      _amplitudeSubscription = null;
    }
  }

  Future<void> _resumeWakeWordService() async {
    try {
      if (_wakeWordManager != null) {
        await _wakeWordManager!.start();
      }
    } catch (error, stackTrace) {
      _logDebug('Wake-word service failed to resume.', error, stackTrace);
    }
  }

  Future<void> _deleteTemporaryFile(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) await file.delete();
    } catch (error, stackTrace) {
      _logDebug('Temporary recording cleanup failed.', error, stackTrace);
    }
  }

  void _handleBillingFailure(String body, int statusCode) {
    try {
      BillingGateHelper.handleError(
        billingApiExceptionFromJson(
          safeDecodeJson(body),
          statusCode: statusCode,
        ).error,
      );
    } catch (error, stackTrace) {
      _logDebug('Billing response parsing failed.', error, stackTrace);
    }
  }

  void _resetSpeechDetection() {
    _hasDetectedSpeech = false;
    _speechDetectionCount = 0;
    _noiseFloorDb = -55.0;
  }

  void _setError(String message) {
    errorMessage.value =
        AppErrorMessage.sanitize(message) ?? 'Voice navigation failed.';
    state.value = VoiceNavState.error;
  }

  void _showUserTriggeredError(String message) {
    _setError(message);
    PLoaders.errorSnackBar(
      title: 'Voice Navigation',
      message: errorMessage.value,
    );
  }

  void _logDebug(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode) return;
    debugPrint('[VoiceNavigation] $message');
    if (error != null) debugPrint(error.toString());
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }

  @override
  void onClose() {
    _silenceTimer?.cancel();
    _maxListeningTimer?.cancel();
    unawaited(_disposeResources());
    super.onClose();
  }

  Future<void> _disposeResources() async {
    await cancelRecording();
    await stopWakeWordService();
    try {
      await _recorder.dispose();
    } catch (error, stackTrace) {
      _logDebug('Recorder disposal failed.', error, stackTrace);
    }
  }
}

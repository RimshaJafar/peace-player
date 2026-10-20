import 'dart:async';

import 'package:ecommerce_app/utils/helpers/network_manager.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/features/creator_series/controllers/series_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ecommerce_app/features/voice_navigation/controllers/voice_navigation_controller.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NetworkManager>()) {
      Get.put(NetworkManager());
    }
    if (!Get.isRegistered<AudioTTSSTTController>()) {
      Get.put(AudioTTSSTTController());
    }
    if (!Get.isRegistered<SeriesController>()) {
      Get.put(SeriesController(), permanent: true);
    }

    final voiceNavController = Get.isRegistered<VoiceNavigationController>()
        ? Get.find<VoiceNavigationController>()
        : Get.put(
            VoiceNavigationController(
              apiUrl:
                  "${dotenv.env['APIS_BASE_URL'] ?? ''}/api/navigate/voice",
            ),
            permanent: true,
          );
    unawaited(
      voiceNavController.startWakeWordService().catchError(
        (Object error, StackTrace stackTrace) {
          if (kDebugMode) {
            debugPrint('[GeneralBindings] Wake-word startup failed: $error');
            debugPrint(stackTrace.toString());
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/islamic_guider/controllers/islamic_guider_controller.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'waveform_painter.dart';

class ChatSearchBar extends StatefulWidget {
  const ChatSearchBar({super.key});

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late final IslamicGuiderController controller;
  late final AudioTTSSTTController audioController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<IslamicGuiderController>();
    audioController = Get.find<AudioTTSSTTController>();

    // Animation for dotted line
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = audioController.voiceState.value;
      final isRecording = state == VoiceInputState.recording;
      final isProcessing = state == VoiceInputState.processing;
      final isSending = controller.isSendingMessage.value;
      final sendDisabled = isRecording || isProcessing || isSending;

      final bar = Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        child: Container(
          // Dynamic height: grows with attachments and up to 3 lines of text
          constraints: const BoxConstraints(minHeight: 68),
          decoration: BoxDecoration(
            color: const Color(0xFFD2E3DF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attachments preview area (fixed at top inside bar)
                Obx(() {
                  final bytes = controller.pendingImageBytes.value;
                  if (bytes == null) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, bottom: 4, top: 6),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: (MediaQuery.sizeOf(context).width * 0.4)
                                .clamp(140.0, 260.0)
                                .toDouble(),
                            height: PSizes.isSmallPhone(context) ? 104 : 120,
                            child: Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: controller.clearPendingImage,
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Text field grows up to 3 lines, then scrolls (full width)
                TextField(
                  controller: controller.inputTextController,
                  enabled: state == VoiceInputState.idle,
                  readOnly: state != VoiceInputState.idle,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: state == VoiceInputState.idle
                        ? "Search Islamic guidance..."
                        : (isRecording
                            ? "Listening..."
                            : "Converting speech to text..."),
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      letterSpacing: 0.2,
                    ),
                    contentPadding: const EdgeInsets.only(
                        left: 16, top: 12, right: 8, bottom: 8),
                    border: InputBorder.none,
                    isDense: true,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                  onSubmitted: (_) =>
                      sendDisabled ? null : controller.sendMessage(),
                ),

                const SizedBox(height: 8),

                // Buttons row below text
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.inputTextController,
                    builder: (_, value, __) {
                      final hasText = value.text.isNotEmpty;
                      return Row(
                        children: [
                          // Image pick button
                          Obx(() {
                            final uploading = controller.isImageUploading.value;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 12, right: 8),
                              child: GestureDetector(
                                onTap: state == VoiceInputState.idle
                                    ? controller.pickImage
                                    : null,
                                child: uploading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.grey),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.photo_library,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                              ),
                            );
                          }),

                          // Waveform in the middle during recording
                          Expanded(
                            child: Container(
                              height: 32,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Background when no waveform
                                  if (!isRecording && !isProcessing)
                                    const SizedBox.expand(),

                                  // Animated waveform
                                  AnimatedOpacity(
                                    opacity: isRecording ? 1.0 : 0.5,
                                    duration: const Duration(milliseconds: 300),
                                    child: Obx(() {
                                      final amps =
                                          audioController.voiceAmplitudes;
                                      // Show waveform even with empty list during recording
                                      if (amps.isEmpty && !isRecording) {
                                        return const SizedBox.expand();
                                      }
                                      return AnimatedBuilder(
                                        animation: _animationController,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            painter: WaveformPainter(
                                              amplitudes: amps.isNotEmpty
                                                  ? amps
                                                  : [0.0],
                                              waveColor:
                                                  const Color(0xFF329070),
                                              opacity: isRecording ? 1.0 : 0.7,
                                              animationPhase:
                                                  _animationController.value,
                                            ),
                                            size:
                                                const Size(double.infinity, 32),
                                          );
                                        },
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Circular mic button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: GestureDetector(
                              onTap: isProcessing
                                  ? null
                                  : isRecording
                                      ? controller.stopVoiceAndConvert
                                      : controller.startVoiceInput,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF329070),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: isProcessing
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white),
                                        ),
                                      )
                                    : Icon(
                                        isRecording ? Icons.check : Icons.mic,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                              ),
                            ),
                          ),

                          // Circular send button
                          Padding(
                            padding: const EdgeInsets.only(left: 6, right: 12),
                            child: GestureDetector(
                              onTap: isRecording
                                  ? controller.cancelVoiceInput
                                  : (isProcessing || isSending || !hasText
                                      ? null
                                      : controller.sendMessage),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isRecording
                                      ? const Color(0xFF329070)
                                      : (isProcessing || isSending || !hasText)
                                          ? Colors.grey.shade400
                                          : const Color(0xFF329070),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  isRecording
                                      ? Icons.close
                                      : isSending
                                          ? Icons.hourglass_top
                                          : Icons.arrow_upward,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (!PSizes.isTablet(context)) return bar;

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: bar,
        ),
      );
    });
  }
}

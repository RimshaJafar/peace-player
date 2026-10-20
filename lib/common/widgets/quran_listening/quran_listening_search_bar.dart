import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';

class QuranListeningSearchBar extends StatelessWidget {
  const QuranListeningSearchBar({
    super.key,
    required this.textController,
    required this.voiceState,
    required this.isCommandLoading,
    required this.onMicTap,
    required this.onSend,
    required this.onCancel,
  });

  final TextEditingController textController;
  final VoiceInputState voiceState;
  final bool isCommandLoading;
  final VoidCallback onMicTap;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  Widget _buildCircleButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade400 : const Color(0xFF329070),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Text field
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 12, top: 2, bottom: 8),
                child: TextField(
                  controller: textController,
                  enabled: voiceState == VoiceInputState.idle,
                  maxLines: 2,
                  scrollPhysics: const BouncingScrollPhysics(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: voiceState == VoiceInputState.idle
                        ? "Type command or tap mic..."
                        : (voiceState == VoiceInputState.recording
                            ? "Listening..."
                            : "Converting speech to text..."),
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                    border: InputBorder.none,
                    isDense: true,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 16),
                child: _buildCircleButton(
                  voiceState == VoiceInputState.processing
                      ? Icons.hourglass_top
                      : (voiceState == VoiceInputState.recording
                          ? Icons.mic_off
                          : Icons.mic),
                  voiceState == VoiceInputState.processing ? null : onMicTap,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: textController,
              builder: (context, value, child) {
                final hasText = value.text.trim().isNotEmpty;
                final sendEnabled = !isCommandLoading &&
                    hasText &&
                    voiceState != VoiceInputState.recording;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 6, right: 12, bottom: 16),
                    child: GestureDetector(
                      onTap: voiceState == VoiceInputState.recording
                          ? onCancel
                          : (sendEnabled ? onSend : null),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: sendEnabled ||
                                  voiceState == VoiceInputState.recording
                              ? const Color(0xFF329070)
                              : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: isCommandLoading &&
                                voiceState != VoiceInputState.recording
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Icon(
                                voiceState == VoiceInputState.recording
                                    ? Icons.close
                                    : Icons.arrow_upward,
                                color: Colors.white,
                                size: 26,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ));
  }
}

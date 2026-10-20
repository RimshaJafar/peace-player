import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/islamic_guider/models/message_model.dart';
import 'package:ecommerce_app/features/islamic_guider/controllers/islamic_guider_controller.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';

/// Reusable chat message container displaying user and assistant messages.
class ChatMessageContainer extends StatelessWidget {
  const ChatMessageContainer({
    super.key,
    required this.msg,
    required this.isUser,
  });

  final MessageModel msg;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final streaming = msg.isStreaming && msg.sender == 'assistant';
    final isAssistant = msg.sender == 'assistant';
    final controller = Get.find<IslamicGuiderController>();
    final audioController = Get.find<AudioTTSSTTController>();

    Widget? buildImage() {
      if (msg.imageUrl == null || msg.imageUrl!.isEmpty) return null;

      final bytes = controller.imageCache[msg.messageId];
      if (bytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            height: 220,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 220,
                child: Center(
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              );
            },
          ),
        );
      }

      if (msg.imageUrl!.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            msg.imageUrl!,
            fit: BoxFit.cover,
            height: 220,
            width: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const SizedBox(
                height: 220,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 220,
                child: Center(
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              );
            },
          ),
        );
      }

      return null;
    }

    const List<Color> gradientColors = [Color(0xFF60BEA8), Color(0xFF1C5D4E)];
    const actionSize = 44.0;

    Widget buildActionButton({
      required IconData icon,
      required VoidCallback onTap,
      bool isLoading = false,
    }) {
      return GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          width: actionSize,
          height: actionSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
          ),
        ),
      );
    }

    return Padding(
        padding: EdgeInsets.only(
          top: 0,
          bottom: isAssistant && msg.content.isNotEmpty && !streaming
              ? actionSize / 2 + 2
              : 0,
        ),
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: isUser ? MediaQuery.of(context).size.width * 0.85 : null,
                decoration: BoxDecoration(
                  color: isUser ? null : const Color(0xFFE6F0EF),
                  gradient: isUser
                      ? const LinearGradient(colors: gradientColors)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image attachment, if any (show above text)
                    if (buildImage() != null) ...[
                      buildImage()!,
                      const SizedBox(height: 12),
                    ],

                    // Message content
                    streaming
                        ? msg.content.isEmpty
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF329070),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Thinking...",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                msg.content,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isUser ? Colors.white : Colors.black,
                                ),
                              )
                        : MarkdownBody(
                            data: msg.content,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 16,
                                color: isUser ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                    if (isAssistant && msg.content.isNotEmpty && !streaming)
                      const SizedBox(height: 28),
                  ],
                ),
              ),

              // Action buttons (Save then Voice) for assistant messages
              if (isAssistant && msg.content.isNotEmpty && !streaming)
                Positioned(
                  bottom: -actionSize / 2,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Save icon (left)
                        buildActionButton(
                          icon: Icons.bookmark_border_rounded,
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: msg.content));
                            if (!context.mounted) return;
                            PLoaders.successSnackBar(
                              title: 'Saved',
                              message: 'Message copied to clipboard',
                              duration: 2,
                              context: context,
                            );
                          },
                        ),
                        const SizedBox(width: 12),

                        // Voice icon (right)
                        Obx(() {
                          final isLoading =
                              audioController.currentTTSMessageId.value ==
                                  msg.messageId;
                          final isPlaying =
                              audioController.currentPlayingMessageId.value ==
                                      msg.messageId &&
                                  audioController.isAudioPlaying.value;
                          final hasAudio = audioController.audioCache
                              .containsKey(msg.messageId);

                          return buildActionButton(
                            icon: isLoading
                                ? Icons.more_horiz
                                : isPlaying
                                    ? Icons.pause_rounded
                                    : (hasAudio
                                        ? Icons.play_arrow_rounded
                                        : Icons.volume_up_rounded),
                            isLoading: isLoading,
                            onTap: () {
                              if (audioController.audioCache
                                  .containsKey(msg.messageId)) {
                                audioController.playAudio(msg.messageId);
                              } else {
                                audioController.textToSpeech(
                                    msg.content, msg.messageId);
                              }
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}

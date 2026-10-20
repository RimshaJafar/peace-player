import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/seerah_nabwi/controllers/seerah_nabwi_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;

class NaatInnerScreen extends StatefulWidget {
  final String naatId;
  final List<String> naatIds;
  final int initialIndex;

  const NaatInnerScreen({
    super.key,
    required this.naatId,
    required this.naatIds,
    required this.initialIndex,
  });

  @override
  State<NaatInnerScreen> createState() => _NaatInnerScreenState();
}

class _NaatInnerScreenState extends State<NaatInnerScreen>
    with SingleTickerProviderStateMixin {
  final SeerahNabwiController controller = Get.put(SeerahNabwiController());
  late AudioPlayer audioPlayer;

  bool isPlaying = false;
  double currentPosition = 0.0;
  double duration = 0.0;
  late AnimationController _textAnimationController;
  late int _currentIndex;
  bool _isDetailLoading = false;
  bool _isAudioLoading = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _textAnimationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _currentIndex = _getInitialIndex();

    audioPlayer.durationStream.listen((newDuration) {
      if (newDuration != null && mounted) {
        setState(() {
          duration = newDuration.inSeconds.toDouble();
        });
      }
    });

    audioPlayer.positionStream.listen((newPosition) {
      if (mounted) {
        setState(() {
          currentPosition = newPosition.inSeconds.toDouble();
        });
      }
    });

    audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });

    // Defer API call to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNaatDetail(_currentNaatId);
    });
  }

  int _getInitialIndex() {
    if (widget.naatIds.isEmpty) {
      return 0;
    }
    if (widget.initialIndex < 0) {
      return 0;
    }
    if (widget.initialIndex >= widget.naatIds.length) {
      return widget.naatIds.length - 1;
    }
    return widget.initialIndex;
  }

  String get _currentNaatId {
    if (widget.naatIds.isEmpty) {
      return widget.naatId;
    }
    return widget.naatIds[_currentIndex];
  }

  Future<void> _loadNaatDetail(String naatId) async {
    if (mounted) {
      setState(() {
        _isDetailLoading = true;
      });
    }
    final detail = await controller.fetchNaatDetail(naatId);
    if (detail != null) {
      if (detail.audioUrl.isNotEmpty) {
        await _loadAudio(detail.audioUrl);
      } else if (mounted) {
        PLoaders.warningSnackBar(
          title: 'Audio Unavailable',
          message: 'No audio available for this naat',
          context: context,
        );
      }
    }
    if (mounted) {
      setState(() {
        _isDetailLoading = false;
      });
    }
  }

  Future<void> _changeNaat(int newIndex) async {
    if (newIndex < 0 || newIndex >= widget.naatIds.length) {
      return;
    }
    setState(() {
      _currentIndex = newIndex;
      currentPosition = 0.0;
      duration = 0.0;
      isPlaying = false;
      _isAudioLoading = true;
    });
    await audioPlayer.stop();
    await _loadNaatDetail(_currentNaatId);
  }

  Future<void> _loadAudio(String audioUrl) async {
    try {
      if (mounted) {
        setState(() {
          _isAudioLoading = true;
        });
      }
      if (audioUrl.isEmpty) {
        if (kDebugMode) debugPrint('Audio URL is empty');
        return;
      }
      if (kDebugMode) debugPrint('Loading audio from: $audioUrl');

      // Verify URL exists before loading
      if (kDebugMode) debugPrint('Verifying URL...');
      final headResponse = await http.head(Uri.parse(audioUrl)).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('URL verification timeout - no internet connection');
        },
      );
      if (kDebugMode) {
        debugPrint('URL verification status: ${headResponse.statusCode}');
      }

      if (headResponse.statusCode != 200) {
        throw Exception(
            'URL returned status ${headResponse.statusCode}. File may not exist.');
      }

      if (kDebugMode) debugPrint('URL verified. Loading audio...');
      await audioPlayer.setUrl(audioUrl);
      if (kDebugMode) debugPrint('Audio loaded successfully');
    } catch (error, stackTrace) {
      _logDebug('Error loading audio', error, stackTrace);
      var errorMessage = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load audio. Please try again.',
      );
      final raw = error.toString();

      // Provide more helpful error messages
      if (raw.contains('UnknownHostException') ||
          raw.contains('no network') ||
          raw.contains('Unable to resolve host') ||
          raw.contains('timeout')) {
        errorMessage =
            'No internet connection. Please check your network and try again.';
      } else if (raw.contains('404') || raw.contains('File may not exist')) {
        errorMessage = 'Audio file not found. The URL may be incorrect.';
      } else if (raw.contains('Source error')) {
        errorMessage =
            'Failed to load audio file. It may be corrupted or unavailable.';
      } else if (raw.contains('status 403')) {
        errorMessage = 'Access denied to audio file. Check file permissions.';
      }

      if (mounted) {
        PLoaders.errorSnackBar(
          title: 'Audio Error',
          message: errorMessage,
          duration: 5,
          context: context,
          actionLabel: 'Retry',
          onAction: () {
            _loadAudio(audioUrl);
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SeerahNabwiController>(
      builder: (seerahController) {
        final textLanguageCode = AppLanguageHelper.textLanguageCode();
        final naatDetail = seerahController.currentNaatDetail;
        final canGoPrevious = widget.naatIds.isNotEmpty && _currentIndex > 0;
        final canGoNext = widget.naatIds.isNotEmpty &&
            _currentIndex < widget.naatIds.length - 1;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 40,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
            title: naatDetail != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 0, right: 10),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: AnimatedBuilder(
                        animation: _textAnimationController,
                        builder: (context, child) {
                          final containerWidth =
                              MediaQuery.of(context).size.width - 60;
                          final translation = (containerWidth + 200) *
                                  _textAnimationController.value -
                              200;

                          return Transform.translate(
                            offset: Offset(translation, 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLanguageHelper.pickText(
                                            naatDetail.title, textLanguageCode)
                                        .trim()
                                        .isNotEmpty
                                    ? AppLanguageHelper.pickText(
                                        naatDetail.title, textLanguageCode)
                                    : 'Naat',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textDirection: TextDirectionUtils.directionFor(
                                    textLanguageCode),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: PColors.linearGradient,
              ),
            ),
          ),
          body: naatDetail == null
              ? const Center(child: Text('Failed to load naat details'))
              : Column(
                  children: [
                    if (_isDetailLoading)
                      const LinearProgressIndicator(
                        minHeight: 2,
                        color: Color(0xFF329070),
                        backgroundColor: Color(0xFFE0E0E0),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Large Naat cover image
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFD7C27B),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF173F32)
                                          .withValues(alpha: 0.20),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.asset(
                                    'assets/images/content/naat_inner_image.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        const ColoredBox(
                                      color: Color(0xFF5F8466),
                                      child: Icon(
                                        Icons.music_note_rounded,
                                        color: Colors.white,
                                        size: 72,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Audio Progress Section
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                children: [
                                  SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: const Color(0xFF329070),
                                      inactiveTrackColor: Colors.grey[300],
                                      thumbColor: const Color(0xFF329070),
                                      thumbShape: const RoundSliderThumbShape(
                                        elevation: 4.0,
                                        enabledThumbRadius: 8.0,
                                      ),
                                      trackHeight: 8.0,
                                    ),
                                    child: Slider(
                                      value:
                                          currentPosition.clamp(0.0, duration),
                                      min: 0.0,
                                      max: duration > 0 ? duration : 1.0,
                                      onChanged: (value) {
                                        setState(() {
                                          currentPosition = value;
                                        });
                                        audioPlayer.seek(
                                            Duration(seconds: value.toInt()));
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatTime(currentPosition),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          _formatTime(duration),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Playback Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Image.asset(
                                    'assets/icons/previous.png',
                                    width: 32,
                                    height: 32,
                                    color: canGoPrevious
                                        ? const Color(0xFF329070)
                                        : Colors.grey,
                                  ),
                                  onPressed: canGoPrevious
                                      ? () => _changeNaat(_currentIndex - 1)
                                      : null,
                                ),
                                const SizedBox(width: 24),
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: _isAudioLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Color(0xFF329070),
                                          ),
                                        )
                                      : IconButton(
                                          icon: Image.asset(
                                            isPlaying
                                                ? 'assets/icons/pausebutton.png'
                                                : 'assets/icons/playbutton.png',
                                            width: 64,
                                            height: 64,
                                            color: const Color(0xFF329070),
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: () async {
                                            try {
                                              if (isPlaying) {
                                                await audioPlayer.pause();
                                              } else {
                                                if (duration == 0.0) {
                                                  PLoaders.warningSnackBar(
                                                    title: 'Audio Not Ready',
                                                    message:
                                                        'Audio not loaded yet. Please check your internet connection.',
                                                    context: context,
                                                  );
                                                  return;
                                                }
                                                await audioPlayer.play();
                                              }
                                            } catch (error, stackTrace) {
                                              _logDebug(
                                                'Playback error',
                                                error,
                                                stackTrace,
                                              );
                                              if (!context.mounted) return;
                                              PLoaders.errorSnackBar(
                                                title: 'Playback Error',
                                                message:
                                                    AppErrorMessage.fromException(
                                                  error,
                                                  fallback:
                                                      'Unable to play audio. Please try again.',
                                                ),
                                                context: context,
                                              );
                                            }
                                          },
                                        ),
                                ),
                                const SizedBox(width: 24),
                                IconButton(
                                  icon: Image.asset(
                                    'assets/icons/nextbutton.png',
                                    width: 38,
                                    height: 38,
                                    color: canGoNext
                                        ? const Color(0xFF329070)
                                        : Colors.grey,
                                  ),
                                  onPressed: canGoNext
                                      ? () => _changeNaat(_currentIndex + 1)
                                      : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Secondary Actions
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/icons/share.png',
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      PLoaders.warningSnackBar(
                                        title: 'Share',
                                        message: 'Share Naat',
                                        context: context,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/icons/shuffle.png',
                                      width: 36,
                                      height: 36,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      PLoaders.successSnackBar(
                                        title: 'Shuffle',
                                        message: 'Shuffle enabled',
                                        context: context,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    // Bottom Metadata Section
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Reciter',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLanguageHelper.pickText(naatDetail.reciter,
                                              textLanguageCode)
                                          .trim()
                                          .isNotEmpty
                                      ? AppLanguageHelper.pickText(
                                          naatDetail.reciter, textLanguageCode)
                                      : 'Unknown',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                  textDirection:
                                      TextDirectionUtils.directionFor(
                                          textLanguageCode),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Writer',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLanguageHelper.pickText(naatDetail.writer,
                                              textLanguageCode)
                                          .trim()
                                          .isNotEmpty
                                      ? AppLanguageHelper.pickText(
                                          naatDetail.writer, textLanguageCode)
                                      : 'Unknown',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                  textDirection:
                                      TextDirectionUtils.directionFor(
                                          textLanguageCode),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _logDebug(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('$message: $error');
    debugPrint(stackTrace.toString());
  }
}

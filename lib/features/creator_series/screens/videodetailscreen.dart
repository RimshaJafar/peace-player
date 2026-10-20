import 'package:ecommerce_app/features/creator_series/controllers/series_controller.dart';
import 'package:ecommerce_app/features/creator_series/models/series_video_model.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoDetailScreen extends StatefulWidget {
  final SeriesVideoModel? video;

  const VideoDetailScreen({super.key, this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late final SeriesController _seriesController =
      Get.isRegistered<SeriesController>()
          ? Get.find<SeriesController>()
          : Get.put(SeriesController());

  SeriesVideoModel? _currentVideo;
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  bool _hasVideoError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialVideo();
    });
  }

  Future<void> _loadInitialVideo() async {
    final initialVideo = widget.video ?? _seriesController.todayVideo;

    if (initialVideo != null) {
      await _setVideo(initialVideo);
      return;
    }

    await _seriesController.fetchTodaySeries();
    final fetchedVideo = _seriesController.todayVideo;
    if (mounted && fetchedVideo != null) {
      await _setVideo(fetchedVideo);
    }
  }

  Future<void> _setVideo(SeriesVideoModel video) async {
    if (_currentVideo?.videoId == video.videoId &&
        _videoController != null &&
        _isVideoReady) {
      return;
    }

    final oldController = _videoController;
    setState(() {
      _currentVideo = video;
      _videoController = null;
      _isVideoReady = false;
      _hasVideoError = false;
    });
    await oldController?.dispose();

    if (video.videoUrl.isEmpty) {
      if (mounted) {
        setState(() => _hasVideoError = true);
      }
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(video.videoUrl),
      );
      _videoController = controller;
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      await controller.play();
      setState(() {
        _isVideoReady = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _hasVideoError = true);
      }
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _videoController;
    if (controller == null || !_isVideoReady) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (mounted) setState(() {});
  }

  Widget _buildHeroMedia(SeriesVideoModel? video) {
    final controller = _videoController;

    if (controller != null && _isVideoReady && controller.value.isInitialized) {
      final size = controller.value.size;

      return SizedBox(
        height: 280,
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.width == 0 ? 16 : size.width,
            height: size.height == 0 ? 9 : size.height,
            child: VideoPlayer(controller),
          ),
        ),
      );
    }

    return Stack(
      children: [
        _buildThumbnail(video),
        if (!_hasVideoError && video != null && video.videoUrl.isNotEmpty)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(color: PColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildThumbnail(SeriesVideoModel? video) {
    final thumbnailUrl = video?.thumbnailUrl ?? '';

    if (thumbnailUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Image.network(
      thumbnailUrl,
      height: 280,
      width: double.infinity,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          height: 280,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  Widget _buildPlayIcon() {
    final controller = _videoController;

    if (controller == null || !_isVideoReady) {
      return const Icon(Icons.play_arrow, size: 40, color: PColors.primary);
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        return Icon(
          value.isPlaying ? Icons.pause : Icons.play_arrow,
          size: 40,
          color: PColors.primary,
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final controller = _videoController;

    if (controller == null || !_isVideoReady) {
      return Row(
        children: [
          const Text('00:00', style: TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: 0,
              onChanged: (_) {},
              activeColor: PColors.primary,
              inactiveColor: Colors.white24,
            ),
          ),
          const SizedBox(width: 8),
          const Text('00:00', style: TextStyle(color: Colors.white)),
        ],
      );
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        final duration = value.duration;
        final durationMs = duration.inMilliseconds;
        final position = value.position;
        final positionMs =
            durationMs == 0 ? 0 : position.inMilliseconds.clamp(0, durationMs);
        final sliderValue = durationMs == 0 ? 0.0 : positionMs / durationMs;

        return Row(
          children: [
            Text(_formatDuration(position),
                style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: sliderValue,
                onChanged: durationMs == 0
                    ? null
                    : (value) {
                        final seekMs = (durationMs * value).round();
                        controller.seekTo(Duration(milliseconds: seekMs));
                      },
                activeColor: PColors.primary,
                inactiveColor: Colors.white24,
              ),
            ),
            const SizedBox(width: 8),
            Text(_formatDuration(duration),
                style: const TextStyle(color: Colors.white)),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedVideo =
        _currentVideo ?? widget.video ?? _seriesController.todayVideo;
    return Scaffold(
      backgroundColor: PColors.lightGrey,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: DefaultTextStyle(
                style: const TextStyle(fontFamily: 'Roboto'),
                child: Column(
                  children: [
                    // 1. TOP VIDEO SECTION (STACK)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Video thumbnail with curved bottom
                        ClipRRect(
                          child: _buildHeroMedia(selectedVideo),
                        ),
                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Back button
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                        // Play button (centered)
                        Positioned.fill(
                          child: Center(
                            child: GestureDetector(
                              onTap: _togglePlayback,
                              child: AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.85),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: _buildPlayIcon(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Video progress bar
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 8,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildProgressBar(),
                          ),
                        ),
                      ],
                    ),
                    // 2. CURVED WHITE CONTAINER (MAIN CONTENT)
                    Transform.translate(
                        offset: const Offset(0, -20),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - 280,
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 32, bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 3. VIDEO TITLE + TAG
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          selectedVideo?.displayTitle ??
                                              'The Beauty of Islamic Knowledge',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: PColors.primary
                                              .withValues(alpha: 0.9),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Featured',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Roboto'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    selectedVideo?.displayDescription ??
                                        'A deep dive into the wisdom and beauty of Islamic teachings for modern life.',
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontFamily: 'Roboto'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 20),
                                  // 4. CREATOR CARD
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 24,
                                          backgroundImage: AssetImage(
                                              'assets/images/content/user.png'),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  selectedVideo
                                                          ?.displayCreatorName ??
                                                      'Mufti Ismail Menk',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const SizedBox(height: 2),
                                              const Text('Featured Creator',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // 5. SOURCE SECTION
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Source',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto')),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _SourceAssetChip(
                                              asset: 'assets/logos/youtube.png',
                                              label: 'YouTube',
                                            ),
                                            const SizedBox(width: 10),
                                            _SourceAssetChip(
                                              asset:
                                                  'assets/logos/instagram.png',
                                              label: 'Instagram',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SourceAssetChip extends StatelessWidget {
  final String asset;
  final String label;
  const _SourceAssetChip({required this.asset, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(asset, width: 18, height: 18),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 13, fontFamily: 'Roboto')),
        ],
      ),
    );
  }
}

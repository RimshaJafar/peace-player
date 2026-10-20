import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/islamic_tube/models/video_item_model.dart';
import 'package:ecommerce_app/features/islamic_tube/controllers/islamic_tube_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    as yt_flutter;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt_iframe;

class VideoPlayerScreen extends StatefulWidget {
  final VideoItem item;

  const VideoPlayerScreen({super.key, required this.item});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  late IslamicMusicController controller;
  late VideoItem currentItem;

  yt_flutter.YoutubePlayerController? _flutterController;
  yt_iframe.YoutubePlayerController? _webController;
  String? videoId;
  bool _playerInitialized = false;
  late AnimationController _titleAnimationController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<IslamicMusicController>();
    currentItem = widget.item;

    _titleAnimationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  // -------------------- PLAYER INIT --------------------
  void _initializePlayer() {
    debugPrint('🎬 Initializing player...');
    debugPrint('📌 videoId from model: "${currentItem.videoId}"');
    debugPrint('📌 videoUrl from model: "${currentItem.videoUrl}"');

    // Better validation: check if videoId is not empty AND not 'null' string
    if (currentItem.videoId.isNotEmpty &&
        currentItem.videoId != 'null' &&
        currentItem.videoId.length == 11) {
      videoId = currentItem.videoId;
      debugPrint('✅ Using videoId from model: $videoId');
    } else {
      videoId = _extractVideoIdFromUrl(currentItem.videoUrl);
      debugPrint('✅ Extracted videoId from URL: $videoId');
    }

    if (videoId == null || videoId!.isEmpty || videoId!.length != 11) {
      debugPrint('❌ Invalid videoId: "$videoId"');
      setState(() {
        _playerInitialized = true; // Show error state
      });
      return;
    }

    debugPrint('🚀 Loading YouTube embed with videoId: $videoId');

    if (kIsWeb) {
      _webController = yt_iframe.YoutubePlayerController.fromVideoId(
        videoId: videoId!,
        autoPlay: true,
        params: const yt_iframe.YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
        ),
      );
    } else {
      _flutterController = yt_flutter.YoutubePlayerController(
        initialVideoId: videoId!,
        flags: const yt_flutter.YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
          controlsVisibleAtStart: true,
          hideControls: false,
          showLiveFullscreenButton: true,
        ),
      );
    }
    setState(() {
      _playerInitialized = true;
    });
  }

  // -------------------- VIDEO ID EXTRACTION --------------------
  String? _extractVideoIdFromUrl(String url) {
    if (url.isEmpty) return null;

    if (url.contains('youtube.com/watch?v=')) {
      return url.split('v=')[1].split('&')[0];
    }
    if (url.contains('youtu.be/')) {
      return url.split('youtu.be/')[1].split('?')[0];
    }
    if (url.contains('youtube.com/embed/')) {
      return url.split('embed/')[1].split('?')[0];
    }
    if (url.length == 11 && !url.contains('/')) {
      return url;
    }

    return null; // Return null instead of trying to use removed library
  }

  // -------------------- DISPOSE --------------------
  @override
  void dispose() {
    _flutterController?.dispose();
    _webController?.close();
    _titleAnimationController.dispose();
    super.dispose();
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final relatedVideos = controller.videoItem
        .where((v) => v.videoUrl != currentItem.videoUrl)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 40,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF60BEA8), Color(0xFF329070), Color(0xFF1C5D4E)],
              stops: [0.08, 0.47, 0.85],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 0, right: 10),
          child: SizedBox(
            height: 40,
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _titleAnimationController,
                builder: (context, child) {
                  final containerWidth = MediaQuery.of(context).size.width - 90;
                  final translation =
                      (containerWidth + 200) * _titleAnimationController.value -
                          200;
                  return Transform.translate(
                    offset: Offset(translation, 0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        currentItem.title,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------- PLAYER --------------------
            SizedBox(
              width: screenWidth,
              height: screenWidth * 9 / 16,
              child: !_playerInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : (videoId == null || videoId!.isEmpty)
                      ? const Center(
                          child: Text('Invalid video ID',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)))
                      : (kIsWeb
                          ? yt_iframe.YoutubePlayer(
                              key: ValueKey(videoId),
                              controller: _webController!,
                              aspectRatio: 16 / 9,
                            )
                          : yt_flutter.YoutubePlayer(
                              key: ValueKey(videoId),
                              controller: _flutterController!,
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: const Color(0xFF329070),
                              progressColors:
                                  const yt_flutter.ProgressBarColors(
                                playedColor: Color(0xFF329070),
                                handleColor: Color(0xFF60BEA8),
                              ),
                            )),
            ),

            // -------------------- RELATED LABEL --------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Related videos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // -------------------- RELATED LIST --------------------
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              itemCount: relatedVideos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = relatedVideos[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Dispose old controllers
                      _flutterController?.dispose();
                      _webController?.close();
                      currentItem = item;
                      _playerInitialized = false;
                      _initializePlayer();
                    });
                  },
                  child: RelatedVideoTile(item: item),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- RELATED TILE --------------------
class RelatedVideoTile extends StatelessWidget {
  final VideoItem item;

  const RelatedVideoTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final thumbnailWidth = (width * 0.4).clamp(128.0, 220.0).toDouble();

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFD2E3DF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(10),
            ),
            child: SizedBox(
              width: thumbnailWidth,
              height: 90,
              child: Image.network(
                item.thumbnailUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:ecommerce_app/features/islamic_tube/controllers/islamic_tube_controller.dart';
import 'package:ecommerce_app/features/islamic_tube/models/playlist_model.dart';
import 'package:ecommerce_app/features/islamic_tube/models/video_item_model.dart';
import 'package:ecommerce_app/features/islamic_tube/screens/video_player_screen.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistScreen({super.key, required this.playlist});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final IslamicMusicController controller = Get.find();
  List<VideoItem>? videoBackup;

  @override
  void initState() {
    super.initState();
    // Get the backup from arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    videoBackup = arguments?['videoBackup'] as List<VideoItem>?;

    // Schedule the data fetch after the current frame to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.isLoading.value = true;
      controller.searchError.value = '';
      controller.fetchPlaylistVideos(widget.playlist.playlistId);
    });
  }

  void _playFirstVideo() {
    if (controller.videoItem.isEmpty) return;

    Get.to(
      () => VideoPlayerScreen(item: controller.videoItem.first),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final containerHeight = math.min(
      (screenHeight * 0.46).clamp(330.0, 440.0),
      screenHeight * 0.60,
    );

    return Scaffold(
      body: Column(
        children: [
          // Responsive hero header with gradient and thumbnail.
          Container(
            height: containerHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: PColors.linearGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 16, 6),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () {
                            Get.back();
                            if (videoBackup != null) {
                              controller.videoItem.assignAll(videoBackup!);
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.playlist.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Responsive 16:9 hero thumbnail.
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: GestureDetector(
                              onTap: _playFirstVideo,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  PSizes.borderRadiusMd,
                                ),
                                child: Image.network(
                                  widget.playlist.thumbnailUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.medium,
                                  errorBuilder: (context, error, stackTrace) {
                                    return ColoredBox(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white,
                                          size: 60,
                                        ),
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return ColoredBox(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.video_library_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      '${widget.playlist.totalVideos} videos',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _playFirstVideo,
                          icon: const Icon(Icons.play_arrow_rounded, size: 21),
                          label: const Text('Play All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF258A67),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            side: BorderSide.none,
                            overlayColor: const Color(0x14329070),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Videos list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.searchError.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.searchError.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => controller.fetchPlaylistVideos(
                          widget.playlist.playlistId,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final videos = controller.videoItem;

              if (videos.isEmpty) {
                return const Center(
                  child: Text('No videos found in this playlist.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: PSizes.defaultSpace,
                  horizontal: 12,
                ),
                itemCount: videos.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = videos[index];
                  return GestureDetector(
                    onTap: () => Get.to(
                      () => VideoPlayerScreen(item: item),
                    ),
                    child: RelatedVideoTile(item: item),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

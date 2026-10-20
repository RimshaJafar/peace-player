import 'package:ecommerce_app/features/islamic_tube/controllers/islamic_tube_controller.dart';
import 'package:ecommerce_app/features/islamic_tube/screens/video_player_screen.dart';
import 'package:ecommerce_app/features/islamic_tube/screens/shorts_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/cards/video_list_item.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final IslamicMusicController controller = Get.find();

    return Obx(() {
      final videoItems = controller.videoItem.toList();

      // Show loader during initial fetch or when loading
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
                onPressed: controller.retryLastSearch,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (videoItems.isEmpty) {
        return const Center(child: Text('No video results found.'));
      }

      // Identify shorts position - they are in the middle section
      // Arrangement from islamic_tube_player_screen: [videos_above, 5_shorts, videos_below]
      List<dynamic> aboveVideos = [];
      List<dynamic> shortsItems = [];
      List<dynamic> belowVideos = [];

      final totalItems = videoItems.length;

      // If more than 4 items, shorts should be in the middle (5 items)
      if (totalItems > 4) {
        // Calculate original video count (total - 5 shorts)
        final originalVideoCount = totalItems - 5;

        if (originalVideoCount > 4) {
          // Videos were split: belowCount = (videoCount / 2).ceil()
          final belowCount = (originalVideoCount / 2).ceil();
          final aboveCount = originalVideoCount - belowCount;

          aboveVideos = videoItems.take(aboveCount).toList();
          shortsItems = videoItems.skip(aboveCount).take(5).toList();
          belowVideos = videoItems.skip(aboveCount + 5).toList();
        } else {
          // Original videos were 4 or fewer, all above shorts
          aboveVideos = videoItems.take(originalVideoCount).toList();
          shortsItems = videoItems.skip(originalVideoCount).take(5).toList();
          belowVideos = [];
        }
      } else {
        // 5 or fewer items, all are videos (no shorts)
        aboveVideos = videoItems;
      }

      return ListView(
        children: [
          // Videos above shorts
          ...aboveVideos.map((item) => VideoListItem(
                item: item,
                onTap: () => Get.to(() => VideoPlayerScreen(item: item)),
              )),

          // Shorts carousel
          if (shortsItems.isNotEmpty) ...[
            // Show shorts if any exist
            SizedBox(height: PSizes.spaceBtwItems),
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth.isFinite
                      ? constraints.maxWidth
                      : MediaQuery.sizeOf(context).width;
                  final carouselWidth =
                      availableWidth.clamp(0.0, 380.0).toDouble();
                  final carouselHeight =
                      PSizes.isSmallPhone(context) ? 232.0 : 250.0;

                  return SizedBox(
                    height: carouselHeight,
                    width: carouselWidth,
                    child: _ShortsCarousel(height: carouselHeight),
                  );
                },
              ),
            ),
            if (belowVideos.isNotEmpty) SizedBox(height: PSizes.spaceBtwItems),
          ],

          // Videos below shorts
          ...belowVideos.map((item) => VideoListItem(
                item: item,
                onTap: () => Get.to(() => VideoPlayerScreen(item: item)),
              )),
        ],
      );
    });
  }
}

/// Compact card for horizontally scrolling “shorts” items.
class _ShortItem extends StatelessWidget {
  const _ShortItem({
    required this.item,
    required this.onTap,
    required this.width,
    required this.height,
  });

  final dynamic item;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((255 * 0.3).toInt()),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8, // 80%
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10)),
                    child: SizedBox.expand(
                      child: Image.network(
                        item.thumbnailUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const ColoredBox(
                            color: Color(0xFFE6F0EF),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const ColoredBox(
                            color: Color(0xFFE6F0EF),
                            child: Center(
                              child: Icon(Icons.image_not_supported_outlined),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2, // 20%
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: PSizes.fontSizeSm,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C3D35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stateful carousel showing two shorts with left/right nav buttons.
class _ShortsCarousel extends StatefulWidget {
  const _ShortsCarousel({required this.height});

  final double height;

  @override
  State<_ShortsCarousel> createState() => _ShortsCarouselState();
}

class _ShortsCarouselState extends State<_ShortsCarousel> {
  int offset = 0;

  @override
  Widget build(BuildContext context) {
    final IslamicMusicController controller = Get.find();
    final allItems = controller.videoItem.toList();

    // Extract shorts from the middle section
    List<dynamic> shortsChunk = <dynamic>[];
    if (allItems.length > 4) {
      final originalVideoCount = allItems.length - 5;
      if (originalVideoCount > 4) {
        final belowCount = (originalVideoCount / 2).ceil();
        final aboveCount = originalVideoCount - belowCount;
        shortsChunk = allItems.skip(aboveCount).take(5).toList();
      } else {
        shortsChunk = allItems.skip(originalVideoCount).take(5).toList();
      }
    }

    final maxStart = shortsChunk.length >= 2 ? shortsChunk.length - 2 : 0;
    if (offset > maxStart) offset = maxStart;

    void goLeft() {
      setState(() {
        offset = (offset - 2);
        if (offset < 0) offset = 0;
      });
    }

    void goRight() {
      setState(() {
        final next = offset + 2;
        offset = next > maxStart ? maxStart : next;
      });
    }

    final visible = shortsChunk.skip(offset).take(2).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasTwoItems = visible.length > 1;
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final compact = PSizes.isSmallPhone(context) || maxWidth < 340;
        final cardWidthLimit = hasTwoItems ? (maxWidth - 49) / 2 : maxWidth - 32;
        final cardWidth = cardWidthLimit
            .clamp(compact ? 112.0 : 140.0, compact ? 136.0 : 160.0)
            .toDouble();
        final cardHeight = (cardWidth * 1.62).clamp(206.0, 240.0).toDouble();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (visible.isNotEmpty)
                      Flexible(
                        child: _ShortItem(
                          item: visible[0],
                          width: cardWidth,
                          height: cardHeight,
                          onTap: () => Get.to(
                            () => ShortsPlayerScreen(
                              shorts: shortsChunk,
                              initialIndex: offset,
                            ),
                          ),
                        ),
                      ),
                    if (hasTwoItems) const SizedBox(width: 1),
                    if (hasTwoItems)
                      Flexible(
                        child: _ShortItem(
                          item: visible[1],
                          width: cardWidth,
                          height: cardHeight,
                          onTap: () => Get.to(
                            () => ShortsPlayerScreen(
                              shorts: shortsChunk,
                              initialIndex: offset + 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: (widget.height / 2) - 20,
              child: _NavCircle(
                icon: Icons.chevron_left,
                onTap: goLeft,
              ),
            ),
            Positioned(
              right: 0,
              top: (widget.height / 2) - 20,
              child: _NavCircle(
                icon: Icons.chevron_right,
                onTap: goRight,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Circular navigation button used on the left/right, half overlapping content.
class _NavCircle extends StatelessWidget {
  const _NavCircle({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFF329070),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}

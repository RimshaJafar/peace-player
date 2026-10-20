import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class StoryCardContainer extends StatelessWidget {
  const StoryCardContainer({
    super.key,
    required this.title,
    required this.bottomColor,
    this.thumbnailPath,
    this.thumbnailUrl,
    this.playIconPath = 'assets/icons/play-button (1).png',
    this.textDirection = TextDirection.ltr,
    this.onTap,
    this.onPlayTap,
  });

  final String title;
  final Color bottomColor;
  final String? thumbnailPath;
  final String? thumbnailUrl;
  final String playIconPath;
  final TextDirection textDirection;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;

  @override
  Widget build(BuildContext context) {
    final thumbnailHeight = PSizes.compactSpace(context, 160.0, 132.0);
    final bottomHeight = PSizes.compactSpace(context, 76.0, 70.0);
    final playIconSize = PSizes.compactSpace(context, 40.0, 34.0);

    final Widget card = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  height: thumbnailHeight,
                  color: const Color(0xFFEFEFEF),
                  child: thumbnailUrl != null && thumbnailUrl!.isNotEmpty
                      ? Image.network(
                          thumbnailUrl!,
                          fit: BoxFit.cover,
                          webHtmlElementStrategy:
                              WebHtmlElementStrategy.fallback,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                          errorBuilder: (context, error, stack) => const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 32,
                          ),
                        )
                      : thumbnailPath != null
                          ? Image.asset(
                              thumbnailPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 32,
                              ),
                            )
                          : const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 32,
                            ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: bottomHeight,
            decoration: BoxDecoration(
              color: bottomColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              textDirection: textDirection,
              children: [
                Expanded(
                  child: Text(
                    title,
                    textDirection: textDirection,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onPlayTap,
                  child: Image.asset(
                    playIconPath,
                    width: playIconSize,
                    height: playIconSize,
                    errorBuilder: (context, error, stack) => const Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return card;
  }
}

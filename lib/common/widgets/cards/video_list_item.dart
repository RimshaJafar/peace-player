import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';

/// Reusable video list item matching the exact UI in `video_screen.dart`.
class VideoListItem extends StatelessWidget {
  const VideoListItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final dynamic item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          top: 0, left: PSizes.md, right: PSizes.md, bottom: PSizes.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0EF),
        borderRadius: BorderRadius.circular(PSizes.borderRadiusMd),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((255 * 0.2).toInt()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-width thumbnail
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(PSizes.borderRadiusMd)),
              child: Image.network(
                item.thumbnailUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  );
                },
              ),
            ),

            // Title below thumbnail with white background and elevation
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(PSizes.borderRadiusMd)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((255 * 0.15).toInt()),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(PSizes.md),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: PSizes.fontSizeMd,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C3D35),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

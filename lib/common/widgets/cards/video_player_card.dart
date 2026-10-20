import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';

/// Reusable container that wraps a video player with gradient border and rounded corners.
class VideoPlayerCard extends StatelessWidget {
  const VideoPlayerCard({
    super.key,
    required this.child,
    this.height = 188,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF60BEA8),
            Color(0xFF329070),
            Color(0xFF1C5D4E),
          ],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
        borderRadius: BorderRadius.circular(PSizes.borderRadiusMd),
      ),
      child: Material(
        elevation: 16,
        shadowColor: Colors.black.withAlpha((255 * 0.3).toInt()),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(PSizes.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PSizes.borderRadiusMd - 3),
            child: SizedBox(
              width: double.infinity,
              height: height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

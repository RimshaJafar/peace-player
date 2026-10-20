import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';

/// Reusable gradient-masked leaf decoration for card corners.
/// Positions leaf at exactly one corner with specified rotation.
class GradientLeafDecoration extends StatelessWidget {
  const GradientLeafDecoration({
    super.key,
    required this.angle,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  /// Rotation angle in radians (e.g., 0, 1.5708 for 90°, 3.1416 for 180°, -1.5708 for -90°)
  final double angle;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: angle,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF60BEA8),
              Color(0xFF329070),
              Color(0xFF1C5D4E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Image.asset(
            PImages.leaves,
            width: 35,
            height: 35,
          ),
        ),
      ),
    );
  }
}

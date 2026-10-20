import 'package:flutter/material.dart';

/// Reusable gradient badge widget for displaying a range (e.g., "1 - 150").
/// Supports optional customization of width, padding, and text separator.
class GradientRangeBadge extends StatelessWidget {
  const GradientRangeBadge({
    super.key,
    required this.startNumber,
    required this.endNumber,
    this.width = 120,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.separator = ' - ',
  });

  final int startNumber;
  final int endNumber;
  final double width;
  final EdgeInsets padding;
  final String separator;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF60BEA8),
            Color(0xFF329070),
            Color(0xFF1C5D4E),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "$startNumber$separator$endNumber",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

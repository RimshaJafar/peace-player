import 'package:flutter/material.dart';

/// Reusable gradient badge widget for displaying simple text with gradient background.
/// Used for displaying info like book name, hadith number, status, etc.
class GradientTextBadge extends StatelessWidget {
  const GradientTextBadge({
    super.key,
    required this.text,
    this.width = 150,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final String text;
  final double width;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF60BEA8),
            Color(0xFF329070),
            Color(0xFF1C5D4E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.1).toInt()),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class GradientBadge extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final EdgeInsets padding;
  final double borderRadius;

  const GradientBadge({
    super.key,
    required this.text,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
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
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: textStyle ??
            const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }
}
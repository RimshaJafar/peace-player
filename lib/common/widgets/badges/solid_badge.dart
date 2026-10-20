import 'package:flutter/material.dart';

class SolidBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsets padding;
  final double borderRadius;

  const SolidBadge({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xFF329070),
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
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
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiButton extends StatelessWidget {
  final Color backgroundColor;
  final String iconPath;
  final String label;
  final double size;
  final double iconSize;
  final double fontSize;
  final VoidCallback? onTap;

  const AiButton({
    super.key,
    required this.backgroundColor,
    this.iconPath = 'assets/icons/ai.png',
    this.label = 'AI',
    this.size = 50,
    this.iconSize = 23,
    this.fontSize = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

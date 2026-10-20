import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 349,
      height: 68,
      decoration: BoxDecoration(
        gradient: backgroundColor == null
            ? (gradient ??
                const LinearGradient(
                  colors: [
                    Color(0xFF60BEA8),
                    Color(0xFF329070),
                    Color(0xFF1C5D4E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ))
            : null,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

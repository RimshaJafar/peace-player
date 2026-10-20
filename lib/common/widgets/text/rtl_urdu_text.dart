import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RTLUrduText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;

  const RTLUrduText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w300,
    this.color = Colors.black87,
    this.textAlign = TextAlign.right,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          text,
          style: GoogleFonts.lateef(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
          textAlign: textAlign,
        ),
      ),
    );
  }
}

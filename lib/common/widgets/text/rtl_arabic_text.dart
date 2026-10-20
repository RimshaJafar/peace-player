import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RTLArabicText extends StatelessWidget {
  final String text;
  final double fontSize;
  final double height;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;

  const RTLArabicText({
    super.key,
    required this.text,
    this.fontSize = 22,
    this.height = 2.1,
    this.fontWeight = FontWeight.bold,
    this.color = Colors.black,
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
          style: GoogleFonts.amiri(
            fontSize: fontSize,
            height: height,
            fontWeight: fontWeight,
            color: color,
          ),
          textAlign: textAlign,
        ),
      ),
    );
  }
}

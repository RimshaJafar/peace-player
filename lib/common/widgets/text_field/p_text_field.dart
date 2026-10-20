import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double verticalContentPadding;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final int maxLines;
  final String? suffixIconPath;
  final TextStyle? textStyle;
  final TextAlign textAlign;

  const PTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.verticalContentPadding = 10,
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFC3BEBE),
    this.maxLines = 1,
    this.suffixIconPath,
    this.textStyle,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final input = TextField(
      controller: controller,
      textAlignVertical: TextAlignVertical.center,
      textAlign: textAlign,
      maxLines: maxLines,
      style: textStyle ??
          GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF808080).withOpacity(0.6),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: verticalContentPadding),
        suffixIcon: suffixIconPath != null
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Image.asset(
                  suffixIconPath!,
                  width: 20,
                  height: 20,
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 20,
          minHeight: 20,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor.withOpacity(0.6)),
        borderRadius: borderRadius,
      ),
      child: maxLines > 1
          ? input
          : SizedBox(
              height: 24,
              child: input,
            ),
    );
  }
}

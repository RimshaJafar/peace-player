import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Basic text field container used across sadqah screens.
class BasicTextField extends StatelessWidget {
  const BasicTextField({
    super.key,
    required this.hint,
    required this.controller,
  });

  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC3BEBE).withOpacity(0.6)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        height: 24,
        child: TextField(
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
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
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}

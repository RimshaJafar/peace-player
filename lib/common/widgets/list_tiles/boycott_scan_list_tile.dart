import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoycottScanListTile extends StatelessWidget {
  final String text1;
  final String? text2;
  final bool spaceEvenly;
  const BoycottScanListTile({
    super.key,
    required this.text1,
    this.text2,
    this.spaceEvenly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 51,
      decoration: BoxDecoration(
        color: const Color(0xFF329070),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: spaceEvenly
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.center,
        children: [
          Text(
            text1,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (text2 != null)
            Text(
              text2!,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

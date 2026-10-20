import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SadqahTypeCard extends StatelessWidget {
  final String icon;
  final String text;
  final VoidCallback? onTap;

  const SadqahTypeCard({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 178,
        height: 170,
        decoration: BoxDecoration(
          color: const Color(0xFFD2E3DF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Image.asset(
                icon,
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

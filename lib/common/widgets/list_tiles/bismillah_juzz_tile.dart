import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable bismillah tile widget for Juzz display with ayah count and juzz name.
class BismillahJuzzTile extends StatelessWidget {
  final String juzName;
  final int totalAyahs;

  const BismillahJuzzTile({
    super.key,
    required this.juzName,
    required this.totalAyahs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.only(right: 16, left: 16, bottom: 24, top: 16),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ayahs $totalAyahs',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1C5D4E)),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  juzName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1C5D4E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: GoogleFonts.amiri(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'شروع الله کے نام سے جو بڑا مہربان نہایت رحم والا ہے',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: GoogleFonts.notoNastaliqUrdu(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

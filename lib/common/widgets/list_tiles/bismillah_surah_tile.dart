import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BismillahSurahTile extends StatelessWidget {
  final String surahName;
  final int totalAyahs;

  const BismillahSurahTile({
    super.key,
    required this.surahName,
    required this.totalAyahs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.only(right:16,left:16,bottom:24,top:16),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF60BEA8),
              Color(0xFF329070),
              Color(0xFF1C5D4E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First Row: Total Ayah + Surah Name (right-aligned)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total Ayah
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  "Ayahs $totalAyahs",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C5D4E),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Surah Name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:  Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  surahName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C5D4E),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Arabic Bismillah
          Text(
            'بِسْمِ ٱللّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color:  Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Urdu Tarjama
          FittedBox(
            fit: BoxFit.scaleDown,
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
        ],
      ),
    );
  }
}
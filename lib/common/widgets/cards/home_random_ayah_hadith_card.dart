import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/text/rtl_arabic_text.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:google_fonts/google_fonts.dart';

class VerseCard extends StatelessWidget {
  final String title;
  final String text;
  final String urduTranslation;
  final String translationLanguageCode;
  final String? reference;
  final String? status;
  final int? hadithNumber;
  final int? ayahNumberInSurah;
  final String? surahName;
  final int? surahNumber;
  final VoidCallback? onPlayAudio;

  const VerseCard({
    super.key,
    required this.title,
    required this.text,
    required this.urduTranslation,
    this.translationLanguageCode = 'ur',
    this.reference,
    this.status,
    this.hadithNumber,
    this.ayahNumberInSurah,
    this.surahName,
    this.surahNumber,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6F0EF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.14).toInt()),
              offset: const Offset(0, 1),
              blurRadius: 2.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(),
              const SizedBox(height: 16),
              RTLArabicText(text: text),
              const SizedBox(height: 10),
              _buildTranslationText(),
              const SizedBox(height: 14),
              _buildMetadataBadges(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationText() {
    final direction = TextDirectionUtils.directionFor(translationLanguageCode);
    final align = TextDirectionUtils.alignFor(translationLanguageCode);
    final isRtl = direction == TextDirection.rtl;

    return Align(
      alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        urduTranslation,
        textDirection: direction,
        textAlign: align,
        style: GoogleFonts.lateef(
          fontSize: 24,
          fontWeight: FontWeight.w300,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// Title section
  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF329070),
            ),
          ),
        ),
        // Audio icon removed
      ],
    );
  }

  /// Metadata badges (reference, status, hadith number OR surah name and ayah)
  Widget _buildMetadataBadges() {
    final hasReference = (reference ?? '').isNotEmpty;
    final hasStatus = (status ?? '').isNotEmpty;
    final hasHadith = hadithNumber != null;
    final hasAyah = _hasAyahData();
    final hasSurahName = (surahName ?? '').isNotEmpty;
    final hasSurahNumber = surahNumber != null;

    final shouldShowHadithRow = hasReference || hasStatus || hasHadith;
    final shouldShowAyahRow = hasAyah || hasSurahName || hasSurahNumber;

    if (!shouldShowHadithRow && !shouldShowAyahRow) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF60BEA8), Color(0xFF329070), Color(0xFF1C5D4E)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: shouldShowHadithRow
          ? _buildHadithMetadataRow()
          : _buildAyahMetadataRow(),
    );
  }

  Widget _buildHadithMetadataRow() {
    final isRtl = TextDirectionUtils.directionFor(translationLanguageCode) ==
        TextDirection.rtl;
    return Row(
      children: [
        Expanded(
          child: Text(
            status ?? '',
            overflow: TextOverflow.ellipsis,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            textDirection:
                TextDirectionUtils.directionFor(translationLanguageCode),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            hadithNumber != null ? "Hadith ${hadithNumber!}" : '',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            reference ?? '',
            overflow: TextOverflow.ellipsis,
            textAlign: isRtl ? TextAlign.left : TextAlign.right,
            textDirection:
                TextDirectionUtils.directionFor(translationLanguageCode),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAyahMetadataRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            surahNumber != null ? "Surah ${surahNumber!}" : '',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            ayahNumberInSurah != null ? "Verse ${ayahNumberInSurah!}" : '',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            surahName ?? '',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Helper to check if ayah data exists
  bool _hasAyahData() => ayahNumberInSurah != null;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/features/quran_hadith/models/surahs_model.dart';

class SurahPicker extends StatelessWidget {
  final RxList<Surahs> surahs;
  final RxBool isLoading;
  final int? selectedSurahNumber;
  final Function(Surahs surah)? onSelect;

  const SurahPicker({
    super.key,
    required this.surahs,
    required this.isLoading,
    this.selectedSurahNumber,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header (same style as QuranOptionPicker)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: PColors.linearGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Surah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (surahs.isEmpty) {
                return const Center(
                  child: Text('No surahs available'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  final isSelected = selectedSurahNumber == surah.surahNumber;

                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: 8,
                      left: 12,
                      right: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F0EF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF60BEA8).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Text(
                        '${surah.surahNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      title: Text(
                        surah.surahName['en'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            surah.surahName['ar'] ?? '',
                            style: GoogleFonts.amiri(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF329070),
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        if (onSelect != null) {
                          onSelect!(surah);
                        }
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

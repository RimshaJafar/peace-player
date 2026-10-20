import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/features/quran_hadith/models/audio_url_model.dart';

class QariAudioPicker extends StatelessWidget {
  final RxList<AudioUrl> audioUrls;
  final RxBool isLoading;
  final String? selectedReciter;
  final Function(String reciter)? onSelect;

  const QariAudioPicker({
    super.key,
    required this.audioUrls,
    required this.isLoading,
    this.selectedReciter,
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
                  'Select Qari Audio',
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

              // Get only Arabic reciters
              final arReciters = <String>[];
              for (final audioUrl in audioUrls) {
                if (audioUrl.language.toLowerCase() == 'ar') {
                  arReciters.addAll(audioUrl.reciters);
                }
              }

              if (arReciters.isEmpty) {
                return const Center(
                  child: Text('No reciters available'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: arReciters.length,
                itemBuilder: (context, index) {
                  final reciter = arReciters[index];
                  final isSelected = selectedReciter == reciter;

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
                      title: Text(
                        reciter,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF329070),
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        if (onSelect != null) {
                          onSelect!(reciter);
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

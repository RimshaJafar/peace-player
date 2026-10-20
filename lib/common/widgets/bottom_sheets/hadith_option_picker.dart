import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';

class HadithOptionPicker extends StatelessWidget {
  final String title;
  final RxList<String> languages;
  final RxBool isLoading;
  final Function(String language)? onSelect;
  final String? selectedLanguage;

  const HadithOptionPicker({
    super.key,
    required this.title,
    required this.languages,
    required this.isLoading,
    this.onSelect,
    this.selectedLanguage,
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
          // Header
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
                Text(
                  title,
                  style: const TextStyle(
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

              if (languages.isEmpty) {
                return const Center(
                  child: Text('No languages available'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F0EF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF60BEA8).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        language.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C5D4E),
                        ),
                      ),
                      trailing: (selectedLanguage != null &&
                              selectedLanguage == language)
                          ? const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF329070),
                              size: 24,
                            )
                          : null,
                      onTap: () {
                        if (onSelect != null) {
                          onSelect!(language);
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

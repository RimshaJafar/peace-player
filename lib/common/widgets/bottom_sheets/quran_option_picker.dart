import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';

class QuranOptionPicker<T> extends StatelessWidget {
  final String title;
  final RxList<T> items;
  final RxBool isLoading;
  final String Function(T) getLanguage;
  final List<String> Function(T) getOptions;
  final int Function(T) getTotalCount;
  final String optionLabel; // 'translators', 'tafseers', 'reciters'
  final Function(String language, String option)? onSelect;
  final String? selectedOption; // current selected option to mark with check

  const QuranOptionPicker({
    super.key,
    required this.title,
    required this.items,
    required this.isLoading,
    required this.getLanguage,
    required this.getOptions,
    required this.getTotalCount,
    required this.optionLabel,
    this.onSelect,
    this.selectedOption, // current selected option to mark with check
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

              if (items.isEmpty) {
                return Center(
                  child: Text('No $optionLabel available'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final language = getLanguage(item);
                  final options = getOptions(item);
                  final totalCount = getTotalCount(item);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Language Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          gradient: PColors.linearGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              language.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$totalCount $optionLabel',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Option Tiles
                      ...options.map((option) {
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
                              option,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: (selectedOption != null &&
                                    selectedOption == option)
                                ? const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFF329070),
                                    size: 20,
                                  )
                                : null,
                            onTap: () {
                              if (onSelect != null) {
                                onSelect!(language, option);
                              }
                              Navigator.pop(context);
                            },
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 16),
                    ],
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

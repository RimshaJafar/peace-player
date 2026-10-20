import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class QuranInfoBox extends StatelessWidget {
  final int selectedTabIndex;
  final int currentNumber;
  final int totalNumber;
  final String surahName;
  final int totalAyahs;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final Function(String query)? onSearch;
  final bool compact;

  const QuranInfoBox({
    super.key,
    required this.selectedTabIndex,
    required this.currentNumber,
    required this.totalNumber,
    this.surahName = '',
    this.totalAyahs = 0,
    required this.onDecrement,
    required this.onIncrement,
    this.onSearch,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double padding = compact ? 8 : 12;
    final double searchHeight = compact ? 44 : 50;
    final double infoHeight = compact ? 108 : 130;
    final double arrowSize = compact ? 26 : 30;
    final double counterFontSize = compact ? 22 : 24;
    final double buttonHeight = compact ? 40 : 48;
    final double buttonFontSize = compact ? 15 : 16;

    return Container(
      decoration: BoxDecoration(
        gradient: PColors.linearGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// White search bar with icon inside
          Container(
            height: searchHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      if (onSearch != null && value.trim().isNotEmpty) {
                        onSearch!(value.trim());
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Enter Surah number (1-114)...",
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/icons/search-interface-symbol.png',
                  height: 20,
                  width: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// White box with navigation and counter
          Container(
            height: infoHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Arrow buttons
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: onDecrement,
                        child: Image.asset(
                          'assets/icons/arrow1.png',
                          height: arrowSize,
                          width: arrowSize,
                        ),
                      ),
                      Text(
                        '$currentNumber/$totalNumber',
                        style: TextStyle(
                          fontSize: counterFontSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C5D4E),
                        ),
                      ),
                      GestureDetector(
                        onTap: onIncrement,
                        child: Transform.rotate(
                          angle: 3.14159,
                          child: Image.asset(
                            'assets/icons/arrow1.png',
                            height: arrowSize,
                            width: arrowSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Gradient buttons at bottom
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 12.0, left: 12, right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /// Surah name button
                      Expanded(
                        child: Container(
                          height: buttonHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            gradient: PColors.linearGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  surahName.isNotEmpty ? surahName : '—',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: buttonFontSize,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// Ayah count button
                      Expanded(
                        child: Container(
                          height: buttonHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            gradient: PColors.linearGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Ayahs: $totalAyahs',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: buttonFontSize,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

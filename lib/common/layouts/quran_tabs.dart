import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';

class QuranTabs extends StatelessWidget {
  const QuranTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final void Function(int) onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => onTabSelected(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Juzz",
                  style: TextStyle(
                    fontSize: 20,
                    color: selectedIndex == 0 ? PColors.primary : Colors.black,
                  ),
                ),
                if (selectedIndex == 0) const SizedBox(height: 2),
                if (selectedIndex == 0)
                  Container(
                    height: 2,
                    width: _getTabWidth("Juzz"),
                    color: PColors.primary,
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onTabSelected(1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Surah",
                  style: TextStyle(
                    fontSize: 20,
                    color: selectedIndex == 1 ? PColors.primary : Colors.black,
                  ),
                ),
                if (selectedIndex == 1) const SizedBox(height: 2),
                if (selectedIndex == 1)
                  Container(
                    height: 2,
                    width: _getTabWidth("Surah"),
                    color: PColors.primary,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getTabWidth(String tabName) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: tabName,
        style: const TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width + 4; // Add padding for proper alignment
  }
}

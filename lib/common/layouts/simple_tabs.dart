import 'package:flutter/material.dart';

class SimpleTabs extends StatelessWidget {
  const SimpleTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.tabs,
    this.backgroundColor = const Color.fromARGB(235, 119, 197, 162),
    this.selectedTabColor = Colors.white,
    this.unselectedTabColor = const Color.fromARGB(255, 0, 0, 0),
  });

  final int selectedIndex;
  final void Function(int) onTabSelected;
  final List<String> tabs;
  final Color backgroundColor;
  final Color selectedTabColor;
  final Color unselectedTabColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            tabs.length,
            (index) => GestureDetector(
              onTap: () => onTabSelected(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 20,
                      color: selectedIndex == index
                          ? selectedTabColor
                          : unselectedTabColor,
                    ),
                  ),
                  if (selectedIndex == index) const SizedBox(height: 2),
                  if (selectedIndex == index)
                    Container(
                      height: 2,
                      width: _getTabWidth(tabs[index]),
                      color: selectedTabColor,
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getTabWidth(String tabName) {
    // Calculate width based on text width more accurately
    // Using TextPainter to measure actual text width
    final textPainter = TextPainter(
      text: TextSpan(
        text: tabName,
        style: const TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width ; // Add padding for proper alignment
  }
}

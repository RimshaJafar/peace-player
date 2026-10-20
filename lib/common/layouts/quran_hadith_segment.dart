import 'package:flutter/material.dart';

class QuranHadithSegment extends StatelessWidget {
  const QuranHadithSegment({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final int selectedIndex;
  final void Function(int) onItemTapped;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onItemTapped(0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: selectedIndex == 0
                          ? const Color.fromRGBO(119, 197, 162, 0.9)
                          : const Color(0XFFE6F0EF),
                      border: Border.all(
                        color: selectedIndex == 0
                            ? const Color(0xFF329070)
                            : Colors.grey,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Quran",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: selectedIndex == 0
                              ? Colors.white
                              : const Color(0XFF627C75),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onItemTapped(1),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: selectedIndex == 1
                          ? const Color.fromRGBO(119, 197, 162, 0.9)
                          : const Color(0XFFE6F0EF),
                      border: Border.all(
                        color: selectedIndex == 1
                            ? const Color(0xFF329070)
                            : Colors.grey,
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Hadith",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: selectedIndex == 1
                              ? Colors.white
                              : const Color(0XFF627C75),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

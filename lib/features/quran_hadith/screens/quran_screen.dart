import 'package:ecommerce_app/features/quran_hadith/screens/juzz_list_screen.dart';
import 'package:ecommerce_app/features/quran_hadith/screens/surah_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/layouts/quran_tabs.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  QuranScreenState createState() => QuranScreenState();
}

class QuranScreenState extends State<QuranScreen> {
  int selectedTabIndex = 0; // Default to Juzz

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(235, 119, 197, 162), // background color
          borderRadius: BorderRadius.circular(16), // curved corners
        ),
        child: Column(
          children: [
            // Buttons for Juzz, Surah, and Favorites (extracted)
            QuranTabs(
              selectedIndex: selectedTabIndex,
              onTabSelected: (i) => setState(() => selectedTabIndex = i),
            ),
            SizedBox(height: 8),
            // Display content based on selected tab
            Expanded(
              child:
                  selectedTabIndex == 0 ? JuzzListScreen() : SurahListScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:ecommerce_app/features/quran_hadith/screens/hadith_books_screen.dart';
import 'package:ecommerce_app/features/quran_hadith/screens/quran_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/common/layouts/quran_hadith_segment.dart';

class QuranHadith extends StatefulWidget {
  const QuranHadith({super.key});

  @override
  State<QuranHadith> createState() => QuranHadithState();
}

class QuranHadithState extends State<QuranHadith> {
  int selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const PAppBar(
          title: Text(
            "Scriptures of Faith",
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          gradient: PColors.linearGradient,
          showBackArrow: false,
          // backgroundTransparent: true,
        ),
        body: Column(
          children: [
            QuranHadithSegment(
                selectedIndex: selectedIndex, onItemTapped: onItemTapped),
            Expanded(
              child: selectedIndex == 0
                  ? QuranScreen() // Display Quran related content
                  : HadithBooksScreen(), // Display Hadith content
            ),
          ],
        ));
  }
}

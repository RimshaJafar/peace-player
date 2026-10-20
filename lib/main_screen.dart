import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ecommerce_app/features/home/screens/home_screen.dart';
import 'package:ecommerce_app/features/islamic_guider/screens/chat_screen.dart';
import 'package:ecommerce_app/features/islamic_tube/screens/islamic_tube_player_screen.dart';
import 'package:ecommerce_app/features/utilities/screens/more_main_screen.dart';
import 'package:ecommerce_app/features/quran_hadith/screens/quranhadith.dart';
import 'package:ecommerce_app/navigation_controller.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final NavigationController navController = Get.put(NavigationController());

  final screens = [
    QuranHadith(),
    IslamicMusicPlayerScreen(),
    HomeScreen(),
    ChatScreen(),
    MoreMainScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => screens[navController.index.value]),
      bottomNavigationBar: Obx(() => CurvedNavigationBar(
            backgroundColor: Colors.transparent,
            color: Color(0xFF1C5D4E),
            animationDuration: Duration(milliseconds: 200),
            index: navController.index.value,
            onTap: (newIndex) {
              navController.index.value = newIndex;
            },
            items: [
              Image.asset(PImages.book,
                  width: 24, height: 24, color: Colors.white),
              Image.asset(PImages.player,
                  width: 24, height: 24, color: Colors.white),
              Image.asset(PImages.home,
                  width: 24, height: 24, color: Colors.white),
              Image.asset(PImages.chatbot,
                  width: 24, height: 24, color: Colors.white),
              Image.asset(PImages.more,
                  width: 24, height: 24, color: Colors.white),
            ],
          )),
    );
  }
}

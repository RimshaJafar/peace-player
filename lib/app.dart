import 'package:ecommerce_app/features/notifications/screens/notifications_screen.dart';
import 'package:ecommerce_app/features/app_support/screens/app_support_screen.dart';
import 'package:ecommerce_app/features/app_support/screens/manual_payment_screen.dart';
import 'package:ecommerce_app/features/app_support/screens/support_success_screen.dart';
import 'package:ecommerce_app/features/app_support/screens/support_history_screen.dart';
import 'package:ecommerce_app/features/utilities/screens/about_us_screen.dart';
import 'package:ecommerce_app/features/utilities/screens/app_settings_screen.dart';
import 'package:ecommerce_app/features/billing/screens/subscription_screen.dart';
import 'package:ecommerce_app/features/islamic_prayer/screens/prayer_times_screen.dart';
import 'package:ecommerce_app/features/islamic_prayer/screens/islamic_calendar_screen.dart';
import 'package:ecommerce_app/features/qibla/screens/qibla_direction_screen.dart';
import 'package:ecommerce_app/features/islamic_tube/screens/islamic_tube_player_screen.dart';
import 'package:ecommerce_app/features/kids/screens/general_story_screen.dart';
import 'package:ecommerce_app/features/kids/screens/good_words_screen.dart';
import 'package:ecommerce_app/features/kids/screens/learn_namaz_screen.dart';
import 'package:ecommerce_app/features/kids/screens/learn_wudu_screen.dart';
import 'package:ecommerce_app/features/kids/screens/main_story_screen.dart';
import 'package:ecommerce_app/features/kids/screens/prophet_story_screen.dart';
import 'package:ecommerce_app/features/kids/screens/quiz_screen.dart';
import 'package:ecommerce_app/features/kids/screens/sahaba_story_screen.dart';
import 'package:ecommerce_app/splash_screen.dart';
import 'package:ecommerce_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/voice_navigation/controllers/voice_navigation_controller.dart';
import 'package:ecommerce_app/features/voice_navigation/screens/voice_overlay.dart';

import 'features/kids/screens/main_kids_screen.dart';
import 'features/seerah_nabwi/screens/seerah_nabwi_outer_screen.dart';
import 'features/quran_listening/screens/quran_listening.dart';
import 'features/seerah_nabwi/screens/personal_possessions_screen.dart';
import 'features/utilities/screens/more_main_screen.dart';
import 'features/islamic_guider/screens/chat_screen.dart';
import 'features/home/screens/boycott_products_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/authentication/screens/signup.dart';
import 'features/home/screens/home_screen.dart';
import 'features/mosque/screens/nearby_mosque_screen.dart';
import 'features/lifeevents/screens/eidain_screen.dart';
import 'features/lifeevents/screens/jummah_screen.dart';
import 'features/lifeevents/screens/funneral_screen.dart';
import 'features/lifeevents/screens/marriage_screen.dart';
import 'features/lifeevents/screens/Pilgrimage_guidance_screen.dart';
import 'features/worships/screens/zikar_screen.dart';
import 'features/worships/screens/kalmas_screen.dart';
import 'features/worships/screens/darood_screen.dart';
import 'features/worships/screens/dua_screen.dart';
import 'features/worships/screens/asma_ul_husna_screen.dart';
import 'features/seerah_nabwi/screens/house_items_screen.dart';
import 'features/seerah_nabwi/screens/miracles_screen.dart';
import 'features/seerah_nabwi/screens/naat_screen.dart';
import 'features/seerah_nabwi/screens/physical_attributes_screen.dart';
import 'features/seerah_nabwi/screens/social_conduct_screen.dart';
import 'features/seerah_nabwi/screens/weapons_screen.dart';
import 'features/seerah_nabwi/screens/rings_screen.dart';
import 'features/seerah_nabwi/screens/perfumes_screen.dart';
import 'features/seerah_nabwi/screens/moral_screen.dart';
import 'features/seerah_nabwi/screens/life_chronicle_screen.dart';
import 'features/seerah_nabwi/screens/lineage_tree_screen.dart';
import 'features/seerah_nabwi/screens/clothing_screen.dart';
import 'features/seerah_nabwi/screens/animals_screen.dart';
import 'features/quran_hadith/screens/surah_list_screen.dart';
import 'features/quran_hadith/screens/juzz_list_screen.dart';
import 'features/quran_hadith/screens/quranhadith.dart';
import 'features/quran_hadith/screens/hadith_books_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: Get.key,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: PAppTheme.lightTheme,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? SizedBox.shrink(),
            if (Get.isRegistered<VoiceNavigationController>()) VoiceOverlay(),
          ],
        );
      },
      home: const SplashScreen(),
      getPages: [
        // Onboarding
        GetPage(name: '/onboarding', page: () => OnBoardingScreen()),

        // Authentication
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),

        // Main Modules
        GetPage(name: '/quran-hadith', page: () => QuranHadith()),
        GetPage(name: '/islamic-tube', page: () => IslamicMusicPlayerScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/peace-guider', page: () => ChatScreen()),
        GetPage(name: '/more-main', page: () => MoreMainScreen()),
        GetPage(
            name: '/notifications', page: () => const NotificationsScreen()),
        GetPage(name: '/app-settings', page: () => const AppSettingsScreen()),
        GetPage(name: '/about-us', page: () => const AboutUsScreen()),
        GetPage(name: '/subscription', page: () => const SubscriptionScreen()),

        // Quran & Hadith
        GetPage(name: '/surah-list', page: () => SurahListScreen()),
        GetPage(name: '/juzz-list', page: () => JuzzListScreen()),
        GetPage(name: '/hadith-books', page: () => HadithBooksScreen()),

        // Home
        GetPage(name: '/boycott-products', page: () => BoycottProductsScreen()),
        GetPage(name: '/prayer-times', page: () => const PrayerTimesScreen()),
        GetPage(
            name: '/islamic-calendar',
            page: () => const IslamicCalendarScreen()),
        GetPage(name: '/qibla-direction', page: () => QiblaDirectionScreen()),
        GetPage(name: '/nearby-mosque', page: () => NearbyMosqueScreen()),
        GetPage(name: '/dua', page: () => DuaScreen()),
        GetPage(name: '/zikar', page: () => ZikarScreen()),
        GetPage(name: '/darood', page: () => DaroodScreen()),
        GetPage(name: '/asma-ul-husna', page: () => AsmaUlHusnaScreen()),
        GetPage(name: '/kalmas-eman', page: () => KalmasScreen()),
        GetPage(name: '/jummah', page: () => JummahScreen()),
        GetPage(name: '/eidain', page: () => EidainScreen()),
        GetPage(name: '/marriage', page: () => MarriageScreen()),
        GetPage(name: '/funeral', page: () => FuneralScreen()),
        GetPage(
            name: '/pilgrimage-guidance',
            page: () => PilgrimageGuidanceScreen()),

        // Seerah Nabwi (Prophet's Life)
        GetPage(name: '/seerah-nabwi', page: () => SeerahNabwiOuterScreen()),
        GetPage(name: '/kids', page: () => MainKidsScreen()),
        GetPage(name: '/quran-listening', page: () => QuranListeningScreen()),
        GetPage(name: '/naat', page: () => NaatScreen()),
        GetPage(name: '/life-chronicle', page: () => LifeChronicleScreen()),
        GetPage(name: '/lineage-tree', page: () => LineageTreeScreen()),
        GetPage(
            name: '/physical-attributes',
            page: () => PhysicalAttributesScreen()),
        GetPage(name: '/perfumes', page: () => PerfumesScreen()),
        GetPage(
            name: '/personal-possessions',
            page: () => PersonalPossessionsScreen()),
        GetPage(name: '/clothing', page: () => ClothingScreen()),
        GetPage(name: '/weapons', page: () => WeaponsScreen()),
        GetPage(name: '/house-items', page: () => HouseItemsScreen()),
        GetPage(name: '/animals', page: () => AnimalsScreen()),
        GetPage(name: '/rings', page: () => RingsScreen()),
        GetPage(name: '/miracles', page: () => MiraclesScreen()),
        GetPage(name: '/moral', page: () => MoralScreen()),
        GetPage(name: '/social-conduct', page: () => SocialConductScreen()),

        // Kids Feature
        GetPage(name: '/learn-namaz', page: () => LearnNamazScreen()),
        GetPage(name: '/learn-wudu', page: () => LearnWuduScreen()),
        GetPage(name: '/good-words', page: () => GoodWordsScreen()),
        GetPage(name: '/kids-stories', page: () => MainStoryScreen()),
        GetPage(name: '/general-stories', page: () => GeneralStoryScreen()),
        GetPage(name: '/prophet-stories', page: () => ProphetStoryScreen()),
        GetPage(name: '/sahaba-stories', page: () => SahabaStoryScreen()),
        GetPage(name: '/quiz', page: () => QuizScreen()),

        // App Support Module
        GetPage(name: '/app-support', page: () => const AppSupportScreen()),
        GetPage(
            name: '/app-support/manual',
            page: () => const ManualPaymentScreen()),
        GetPage(
            name: '/app-support/success',
            page: () => const SupportSuccessScreen()),
        GetPage(
            name: '/app-support/history',
            page: () => const SupportHistoryScreen()),
      ],
    );
  }
}

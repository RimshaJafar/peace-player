import 'package:ecommerce_app/features/home/controllers/home_controller.dart';
// import removed: MainScreenDrawer not used in HomeScreen
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/cards/home_random_ayah_hadith_card.dart';
import 'package:ecommerce_app/common/widgets/cards/home_feature_card.dart';
import 'package:ecommerce_app/common/layouts/home_header.dart';
import 'package:ecommerce_app/common/widgets/fab/rotating_fab_menu.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:ecommerce_app/utils/local_storage/storage_utility.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:ecommerce_app/common/controllers/app_language_controller.dart';

// Worship screens
import 'package:ecommerce_app/features/worships/screens/dua_screen.dart';
import 'package:ecommerce_app/features/worships/screens/zikar_screen.dart';
import 'package:ecommerce_app/features/worships/screens/darood_screen.dart';
import 'package:ecommerce_app/features/worships/screens/asma_ul_husna_screen.dart';
import 'package:ecommerce_app/features/worships/screens/kalmas_screen.dart';
// Nearby & utility screens
import 'package:ecommerce_app/features/qibla/screens/qibla_direction_screen.dart';
import 'package:ecommerce_app/features/mosque/screens/nearby_mosque_screen.dart';
import 'package:ecommerce_app/features/home/screens/boycott_products_screen.dart';
import 'package:ecommerce_app/features/digital_will/screens/digital_will_landing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());
  final PLocalStorage _storage = PLocalStorage();
  final AppLanguageController _languageController =
      Get.isRegistered<AppLanguageController>()
          ? Get.find<AppLanguageController>()
          : Get.put(AppLanguageController());
  final randomVerseTileSurahName = 'ar';
  @override
  void initState() {
    super.initState();
    controller.fetchHomeRandomVerse();
    controller.fetchHomeRandomHadith();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: MainScreenDrawer(), // removed to move drawer to MoreMainScreen
      floatingActionButton: const RotatingFabMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          /// Header with Image and Drawer Icon (shared HomeHeader + PrimaryHeaderContainer)
          const HomeHeader(),

          /// Refreshable Scroll Content
          Expanded(
            child: Obx(() {
              final textLanguageCode =
                  _languageController.textLanguageCode.value;
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchHomeRandomVerse();
                  await controller.fetchHomeRandomHadith();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Worship icons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DuaScreen()),
                              ),
                              child: Image.asset('assets/icons/Dua.png',
                                  width: 50, height: 50),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ZikarScreen()),
                              ),
                              child: Image.asset('assets/icons/zikar.png',
                                  width: 50, height: 50),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DaroodScreen()),
                              ),
                              child: Image.asset('assets/icons/darood.png',
                                  width: 50, height: 50),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AsmaUlHusnaScreen()),
                              ),
                              child: Image.asset('assets/icons/Asmaulhusna.png',
                                  width: 50, height: 50),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => KalmasScreen()),
                              ),
                              child: Image.asset('assets/icons/Kalmas.png',
                                  width: 50, height: 50),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Feature cards - 2 per row
                        Row(
                          children: [
                            Expanded(
                              child: HomeFeatureCard(
                                title: 'Digital Will',
                                iconPath: 'assets/icons/digital_will.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const DigitalWillLandingScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: HomeFeatureCard(
                                title: 'Boycott Products',
                                iconPath: 'assets/icons/boycott.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const BoycottProductsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: HomeFeatureCard(
                                title: 'Qibla Direction',
                                iconPath: 'assets/icons/qibla_direction.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const QiblaDirectionScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: HomeFeatureCard(
                                title: 'Nearby Mosque',
                                iconPath: 'assets/icons/Mosque.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NearbyMosqueScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        VerseCard(
                          title: "Gem of Divine",
                          text: controller.peaceVerse.value?.textArabic ?? '',
                          urduTranslation: controller.peaceVerse.value
                                      ?.translations[textLanguageCode]
                                  ?['default'] ??
                              '',
                          translationLanguageCode: textLanguageCode,
                          surahNumber: controller.peaceVerse.value?.surahNumber,
                          surahName: controller.peaceVerse.value
                                  ?.surahName[randomVerseTileSurahName] ??
                              '',
                          ayahNumberInSurah:
                              controller.peaceVerse.value?.ayahNumberInSurah,
                        ),
                        const SizedBox(height: 16),
                        VerseCard(
                          title: "Pearl of Sunnah",
                          text: controller.peaceSunnah.value?.textArabic ?? '',
                          urduTranslation: controller.peaceSunnah.value
                                  ?.translations[textLanguageCode] ??
                              '',
                          translationLanguageCode: textLanguageCode,
                          reference: controller.peaceSunnah.value
                                  ?.bookName[textLanguageCode] ??
                              '',
                          status: controller.peaceSunnah.value?.status ?? '',
                          hadithNumber:
                              controller.peaceSunnah.value?.hadithNumber,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

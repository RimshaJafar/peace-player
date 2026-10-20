import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/worships_life_cards.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'animals_screen.dart';
import 'clothing_screen.dart';
import 'house_items_screen.dart';
import 'perfumes_screen.dart';
import 'rings_screen.dart';
import 'weapons_screen.dart';

class PersonalPossessionsScreen extends StatelessWidget {
  const PersonalPossessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final isUrduTitle = titleLanguageCode == 'ur';
    final List<Map<String, dynamic>> possessionItems = [
      {
        'urdu': 'ہتھیار',
        'english': 'Weapons',
        'icon': 'assets/icons/weapons.png',
        'builder': const WeaponsScreen(),
      },
      {
        'urdu': 'جانور',
        'english': 'Animals',
        'icon': 'assets/icons/animals.png',
        'builder': const AnimalsScreen(),
      },
      {
        'urdu': 'لباس',
        'english': 'Clothing',
        'icon': 'assets/icons/clothing.png',
        'builder': const ClothingScreen(),
      },
      {
        'urdu': 'انگشتر',
        'english': 'Rings',
        'icon': 'assets/icons/rings.png',
        'builder': const RingsScreen(),
      },
      {
        'urdu': 'گھریلو اشیاء',
        'english': 'House Items',
        'icon': 'assets/icons/household_items.png',
        'builder': const HouseItemsScreen(),
      },
      {
        'urdu': 'خوشبو',
        'english': 'Perfumes',
        'icon': 'assets/icons/perfumes.png',
        'builder': const PerfumesScreen(),
      },
    ];

    return Scaffold(
      appBar: PAppBar(
        title: Text(
          'Personal Possessions',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: const ReferenceAyahHadithBox(
              featureKey: 'personal_possession',
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: PSizes.isTablet(context) ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: possessionItems.length,
              itemBuilder: (context, index) {
                final item = possessionItems[index];
                final title = AppLanguageHelper.pickText({
                  'urdu': item['urdu']?.toString() ?? '',
                  'english': item['english']?.toString() ?? '',
                }, titleLanguageCode);
                return Card(
                  elevation: 4,
                  color: const Color(0XFFE6F0EF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => item['builder'] as Widget,
                        ),
                      );
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              item['icon'],
                              width: 70,
                              height: 70,
                              color: Colors.black,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              textDirection: TextDirectionUtils.directionFor(
                                  titleLanguageCode),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: isUrduTitle
                                  ? GoogleFonts.notoNastaliqUrdu(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0XFF333333),
                                    )
                                  : GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0XFF333333),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

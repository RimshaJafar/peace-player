import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/kids_card.dart';
import 'package:ecommerce_app/common/widgets/containers/kids_module_cards_container.dart';
import 'package:ecommerce_app/features/kids/screens/good_words_screen.dart';
import 'package:ecommerce_app/features/kids/screens/learn_namaz_screen.dart';
import 'package:ecommerce_app/features/kids/screens/learn_wudu_screen.dart';
import 'package:ecommerce_app/features/kids/screens/main_story_screen.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';

class MainKidsScreen extends StatelessWidget {
  const MainKidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final heroWidth =
        (PSizes.screenWidth(context) - 32).clamp(280.0, 340.0).toDouble();
    final compactHeight = PSizes.isCompactHeight(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PAppBar(
        title: Text(
          'Kids Module',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF77ACA2),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          /// Kids Module Image
          Center(
            child: SizedBox(
              width: heroWidth,
              height: PSizes.kidsHeroHeight(context),
              child: Image.asset(
                'assets/images/kids/mainscreen.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => const Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          /// Container with rounded top corners
          KidsModuleCardsContainer(
            gradientColors: const [
              Color(0xFFF1D5C6),
              Color(0xFFE5BCA7),
            ],
            borderColor: const Color(0xFFD39778),
            child: GridView.count(
              crossAxisCount: PSizes.adaptiveGridCount(context),
              crossAxisSpacing: PSizes.gridViewSpacing,
              mainAxisSpacing: PSizes.gridViewSpacing,
              padding: EdgeInsets.only(
                top: PSizes.compactSpace(context, 32.0, 16.0),
              ),
              shrinkWrap: !compactHeight,
              physics: compactHeight
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              children: [
                /// Card 1: Good Words
                KidsCard(
                  cardColor: const Color(0xFFCAA5CB),
                  iconPath: 'assets/icons/words.png',
                  text: 'Good Words',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GoodWordsScreen(),
                      ),
                    );
                  },
                ),

                /// Card 2: Learn Namaz
                KidsCard(
                  cardColor: const Color(0xFFE48586),
                  iconPath: 'assets/icons/namaz.png',
                  text: 'Learn Namaz',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LearnNamazScreen(),
                      ),
                    );
                  },
                ),

                /// Card 3: Learn Wudu
                KidsCard(
                  cardColor: const Color(0xFF749BC2),
                  iconPath: 'assets/icons/wudu.png',
                  text: 'Learn Wudu',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LearnWuduScreen(),
                      ),
                    );
                  },
                ),

                /// Card 4: Story Time
                KidsCard(
                  cardColor: const Color(0xFFD97D55),
                  iconPath: 'assets/icons/story.png',
                  text: 'Story Time!',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainStoryScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/kids_card.dart';
import 'package:ecommerce_app/common/widgets/containers/kids_module_cards_container.dart';
import 'package:ecommerce_app/features/kids/controllers/kids_stories_controller.dart';
import 'package:ecommerce_app/features/kids/models/kids_story_category_model.dart';
import 'package:ecommerce_app/features/kids/screens/prophet_story_screen.dart';
import 'package:ecommerce_app/features/kids/screens/sahaba_story_screen.dart';
import 'package:ecommerce_app/features/kids/screens/general_story_screen.dart';
import 'package:ecommerce_app/features/kids/screens/quiz_screen.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:get/get.dart';

class MainStoryScreen extends StatefulWidget {
  const MainStoryScreen({super.key});

  @override
  State<MainStoryScreen> createState() => _MainStoryScreenState();
}

class _MainStoryScreenState extends State<MainStoryScreen> {
  final KidsStoriesController _storiesController =
      Get.put(KidsStoriesController());
  bool _isOpeningQuiz = false;

  @override
  void initState() {
    super.initState();
    _storiesController.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final heroWidth =
        (PSizes.screenWidth(context) - 32).clamp(280.0, 340.0).toDouble();
    final compactHeight = PSizes.isCompactHeight(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PAppBar(
        title: Text(
          'Stories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFD97D55),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          /// Stories Image
          Center(
            child: SizedBox(
              width: heroWidth,
              height: PSizes.kidsHeroHeight(context),
              child: Image.asset(
                'assets/images/kids/kids_stories.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => const Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),

          /// Container with rounded top corners
          KidsModuleCardsContainer(
            gradientColors: const [
              Color(0xFFF5DFA8),
              Color(0xFFE9C574),
            ],
            borderColor: const Color(0xFFD09B3E),
            child: Obx(() {
              final categories = _storiesController.categories;
              if (_storiesController.isCategoriesLoading.value &&
                  categories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final cards = _buildCategoryCards(categories)
                ..add(_buildQuizCard(context));

              return GridView.count(
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
                children: cards,
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryCards(List<KidsStoryCategory> categories) {
    if (categories.isEmpty) {
      return _buildStaticCategoryCards();
    }

    const order = <String>[
      'prophet_stories',
      'sahaba_stories',
      'general_stories',
    ];
    final sorted = categories.toList()
      ..sort((a, b) {
        final aIndex = order.indexOf(a.categoryKey);
        final bIndex = order.indexOf(b.categoryKey);
        return aIndex.compareTo(bIndex);
      });

    final cards = <Widget>[];
    for (final category in sorted) {
      final card = _buildCategoryCard(category);
      if (card != null) {
        cards.add(card);
      }
    }

    return cards.isEmpty ? _buildStaticCategoryCards() : cards;
  }

  KidsCard? _buildCategoryCard(KidsStoryCategory category) {
    final displayTitle = _englishTitleForKey(category.categoryKey);

    switch (category.categoryKey) {
      case 'prophet_stories':
        return KidsCard(
          cardColor: const Color(0xFF77ACA2),
          iconPath: 'assets/icons/prophet.png',
          text: displayTitle,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProphetStoryScreen(),
              ),
            );
          },
        );
      case 'sahaba_stories':
        return KidsCard(
          cardColor: const Color(0xFFE48586),
          iconPath: 'assets/icons/sahaba.png',
          text: displayTitle,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SahabaStoryScreen(),
              ),
            );
          },
        );
      case 'general_stories':
        return KidsCard(
          cardColor: const Color(0xFFCAA5CB),
          iconPath: 'assets/icons/general.png',
          text: displayTitle,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GeneralStoryScreen(),
              ),
            );
          },
        );
      default:
        return null;
    }
  }

  List<Widget> _buildStaticCategoryCards() {
    return [
      KidsCard(
        cardColor: const Color(0xFF77ACA2),
        iconPath: 'assets/icons/prophet.png',
        text: "Prophet's",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProphetStoryScreen(),
            ),
          );
        },
      ),
      KidsCard(
        cardColor: const Color(0xFFE48586),
        iconPath: 'assets/icons/sahaba.png',
        text: "Sahaba's",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SahabaStoryScreen(),
            ),
          );
        },
      ),
      KidsCard(
        cardColor: const Color(0xFFCAA5CB),
        iconPath: 'assets/icons/general.png',
        text: 'General',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GeneralStoryScreen(),
            ),
          );
        },
      ),
    ];
  }

  KidsCard _buildQuizCard(BuildContext context) {
    return KidsCard(
      cardColor: const Color(0xFF749BC2),
      iconPath: 'assets/icons/quiz.png',
      text: 'Quiz',
      onTap: _openStandaloneQuiz,
    );
  }

  Future<void> _openStandaloneQuiz() async {
    if (_isOpeningQuiz || !mounted) {
      return;
    }

    _isOpeningQuiz = true;
    final navigator = Navigator.of(context);

    try {
      await navigator.push(
        MaterialPageRoute(
          builder: (_) => QuizScreen(key: UniqueKey()),
        ),
      );
    } finally {
      _isOpeningQuiz = false;
    }
  }

  String _englishTitleForKey(String categoryKey) {
    switch (categoryKey) {
      case 'prophet_stories':
        return "Prophet's";
      case 'sahaba_stories':
        return "Sahaba's";
      case 'general_stories':
        return 'General';
      default:
        return 'Stories';
    }
  }
}

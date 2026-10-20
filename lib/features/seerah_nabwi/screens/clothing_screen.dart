import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/layouts/possession_detail_layout.dart';
import 'package:ecommerce_app/features/seerah_nabwi/controllers/seerah_nabwi_controller.dart';
import 'package:ecommerce_app/features/seerah_nabwi/models/seerah_feature_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/possession_category_translations.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';

class ClothingScreen extends StatefulWidget {
  const ClothingScreen({super.key});

  @override
  State<ClothingScreen> createState() => _ClothingScreenState();
}

class _ClothingScreenState extends State<ClothingScreen> {
  final SeerahNabwiController controller = Get.put(SeerahNabwiController());
  late AudioTTSSTTController audioController;
  static const String _mainTag = 'possessions';
  static const String _subTag = 'clothes';

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioTTSSTTController>();
    _loadData();
  }

  Future<void> _loadData() async {
    await controller.fetchSeerahFeatures(mainTag: _mainTag, subTag: _subTag);
    final categoriesResponse = await controller.fetchSeerahCategories(
      mainTag: _mainTag,
      subTag: _subTag,
    );
    final categories = categoriesResponse?.items ?? [];
    for (final category in categories) {
      await controller.fetchSeerahFeaturesByCategory(
        mainTag: _mainTag,
        subTag: _subTag,
        category: category.category,
      );
    }
  }

  List<Map<String, String>> _mapItems(List<SeerahFeatureItem> items) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    return items
        .map((item) => {
              'title':
                  AppLanguageHelper.pickText(item.title, titleLanguageCode),
              'content':
                  AppLanguageHelper.pickText(item.text, textLanguageCode),
            })
        .where((e) =>
            (e['title'] ?? '').isNotEmpty || (e['content'] ?? '').isNotEmpty)
        .toList();
  }

  Map<String, List<Map<String, String>>> _buildCategorizedData(
      SeerahNabwiController seerahController) {
    final data = <String, List<Map<String, String>>>{};
    final allKey = '${_mainTag}_$_subTag';
    final allItems = seerahController.getFeatureItems(allKey);
    data['All'] = _mapItems(allItems);

    final categoriesKey = '${_mainTag}_${_subTag}_categories';
    final categories = seerahController.getCategoryItems(categoriesKey);
    for (final category in categories) {
      final categoryKey = '${_mainTag}_${_subTag}_${category.category}';
      final categoryItems = seerahController.getFeatureItems(categoryKey);
      if (categoryItems.isNotEmpty) {
        data[category.category] = _mapItems(categoryItems);
      }
    }
    return data.isEmpty ? {'All': []} : data;
  }

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final ttsTextLanguageCode = textLanguageCode == 'ur' ? 'ur' : 'en';
    return Scaffold(
      appBar: PAppBar(
        title: Text(
          'Clothing',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: GetBuilder<SeerahNabwiController>(
        builder: (seerahController) {
          final allKey = '${_mainTag}_$_subTag';
          final isLoading = seerahController.isFeatureLoading(allKey);
          final categorizedData = _buildCategorizedData(seerahController);
          final categoryLabels = PosessionCategoryTranslations.labelsFor(
              categorizedData.keys, titleLanguageCode);

          if (isLoading && (categorizedData['All']?.isEmpty ?? true)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categorizedData['All']?.isEmpty ?? true) {
            return const Center(
              child: Text('No data available'),
            );
          }

          return PossessionDetailLayout(
            imagePath: 'assets/images/content/clothing.png',
            categorizedData: categorizedData,
            categoryLabels: categoryLabels,
            onPlayAudio: (content, index) {
              if (content.isNotEmpty) {
                audioController.textToSpeechSingleLanguage(content, index,
                    language: ttsTextLanguageCode);
              }
            },
          );
        },
      ),
    );
  }
}

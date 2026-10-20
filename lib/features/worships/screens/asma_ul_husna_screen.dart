import 'package:ecommerce_app/common/layouts/simple_tabs.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/worships_life_cards.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/dropdown_list_tile.dart';
import 'package:ecommerce_app/features/home/controllers/home_controller.dart';
import 'package:ecommerce_app/features/home/models/worship_item_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AsmaUlHusnaScreen extends StatefulWidget {
  const AsmaUlHusnaScreen({super.key});

  @override
  State<AsmaUlHusnaScreen> createState() => _AsmaUlHusnaScreenState();
}

class _AsmaUlHusnaScreenState extends State<AsmaUlHusnaScreen> {
  int selectedTabIndex = 0; // 0 => Asma (Allah), 1 => Muhammad
  final HomeController controller = Get.find<HomeController>();
  late AudioTTSSTTController audioController;

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioTTSSTTController>();
    // Fetch asmaulhusna worship items (includes both allah and prophet names)
    controller.fetchWorshipByTag('asmaulhusna');
  }

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    return Scaffold(
      appBar: PAppBar(
        title: Text(
          'Asma-ul-Husna',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: const ReferenceAyahHadithBox(
                featureKey: 'asma',
              ),
            ),
            const SizedBox(height: 16),
            SimpleTabs(
              selectedIndex: selectedTabIndex,
              onTabSelected: (i) => setState(() => selectedTabIndex = i),
              tabs: const ['Allah', 'Muhammad'],
            ),
            Expanded(
              child: GetBuilder<HomeController>(
                builder: (homeController) {
                  final isLoading = homeController.isTagLoading('asmaulhusna');
                  final allItems =
                      homeController.getTagWorshipItems('asmaulhusna');

                  // Filter by sub-tag (allah or prophet)
                  final subTag = selectedTabIndex == 0 ? 'allah' : 'prophet';
                  final items =
                      homeController.filterWorshipBySubTag(allItems, subTag);

                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (items.isEmpty) {
                    return _emptyState(
                      selectedTabIndex == 0
                          ? 'No Allah names found'
                          : 'No Prophet names found',
                    );
                  }

                  return _buildList(items);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<WorshipItem> items) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final audioId = item.id.hashCode;
        final title = AppLanguageHelper.pickText(item.title, titleLanguageCode);
        final translation =
            AppLanguageHelper.pickText(item.translations, textLanguageCode);

        return DropdownListTile(
          key: ValueKey('asma_${selectedTabIndex}_${item.id}'),
          index: index + 1,
          title: title.isNotEmpty ? title : (item.textArabic ?? '—'),
          arabic: item.textArabic,
          translation: translation,
          isSaved: false,
          showBookmark: false,
          centerText: true,
          onPlayAudio: () {
            final arabic = item.textArabic ?? '';
            final playText =
                [arabic, translation].where((t) => t.isNotEmpty).join(' | ');
            if (playText.isNotEmpty) {
              audioController.textToSpeech(playText, audioId);
            }
          },
        );
      },
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark_border, color: Colors.grey, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

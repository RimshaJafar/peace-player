import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/common/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:ecommerce_app/common/layouts/simple_tabs.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/worships_life_cards.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/dropdown_list_tile.dart';
import 'package:ecommerce_app/features/home/controllers/home_controller.dart';
import 'package:ecommerce_app/features/home/models/worship_item_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZikarScreen extends StatefulWidget {
  const ZikarScreen({super.key});

  @override
  State<ZikarScreen> createState() => _ZikarScreenState();
}

class _ZikarScreenState extends State<ZikarScreen> {
  int selectedTabIndex = 0; // Default to Zikar
  final HomeController controller = Get.find<HomeController>();
  late AudioTTSSTTController audioController;

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioTTSSTTController>();
    if (controller.worshipSimpleItems.isEmpty) {
      controller.fetchWorshipSimple();
    }
    if (controller.worshipSavedItems.isEmpty) {
      controller.fetchWorshipSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    return Scaffold(
      appBar: PAppBar(
        title: Text(
          'Zikar',
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
                featureKey: 'azkar',
              ),
            ),
            const SizedBox(height: 16),
            // Tabs with full width bg
            SimpleTabs(
              selectedIndex: selectedTabIndex,
              onTabSelected: (i) => setState(() => selectedTabIndex = i),
              tabs: const ['Zikar', 'Saved Zikar'],
            ),
            // Tab content
            Expanded(
              child: Obx(() {
                final loading = selectedTabIndex == 0
                    ? controller.isWorshipLoadingSimple.value
                    : controller.isWorshipLoadingSaved.value;
                if (loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = selectedTabIndex == 0
                    ? controller.filterWorshipByTag(
                        controller.worshipSimpleItems, 'zikr')
                    : controller.filterWorshipByTag(
                        controller.worshipSavedItems, 'zikr');
                if (list.isEmpty) {
                  return _emptyState(
                    selectedTabIndex == 0
                        ? 'No zikar found'
                        : 'No saved zikar yet',
                  );
                }
                return _buildList(list);
              }),
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
        final saved = controller.worshipSavedItems.any((e) => e.id == item.id);
        final audioId = item.id.hashCode;
        final title = AppLanguageHelper.pickText(item.title, titleLanguageCode);
        final translation =
            AppLanguageHelper.pickText(item.translations, textLanguageCode);

        return DropdownListTile(
          key: ValueKey('zikar_${selectedTabIndex}_${item.id}'),
          index: index + 1,
          title: title.isNotEmpty ? title : '—',
          arabic: item.textArabic,
          translation: translation,
          isSaved: saved,
          source: item.source,
          onSaveToggle: () => controller.toggleWorshipSaved(item),
          onDelete: () async {
            final confirmed = await DeleteConfirmationDialog.show(
              context: context,
              title: 'Delete Zikar',
              message: 'Are you sure you want to delete this zikar?',
            );
            if (confirmed == true) {
              await controller.deleteWorship(item.id);
            }
          },
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

import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/worships_life_cards.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/dropdown_list_tile.dart';
import 'package:ecommerce_app/common/layouts/simple_tabs.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/home/controllers/home_controller.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';

class EidainScreen extends StatefulWidget {
  const EidainScreen({super.key});

  @override
  State<EidainScreen> createState() => _EidainScreenState();
}

class _EidainScreenState extends State<EidainScreen> {
  final Color primaryColor = const Color(0xFFEFA88A);
  final HomeController controller = Get.find<HomeController>();
  late AudioTTSSTTController audioController;
  int selectedIndex = 0; // 0 = Fitr, 1 = Azha

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioTTSSTTController>();
    // Fetch life events for both Eids
    controller.fetchLifeEventsByTag('eidain', 'eid_ul_fitr');
    controller.fetchLifeEventsByTag('eidain', 'eid_ul_adha');
  }

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final ttsTextLanguageCode = textLanguageCode == 'ur' ? 'ur' : 'en';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PAppBar(
        title: Text(
          'Eidain',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        showBackArrow: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const ReferenceAyahHadithBox(
              featureKey: 'eidein',
              borderColor: Color(0xFFEFA88A),
            ),
          ),
          const SizedBox(height: 16),
          SimpleTabs(
            selectedIndex: selectedIndex,
            onTabSelected: (index) => setState(() => selectedIndex = index),
            tabs: const ['Eid-ul-Fitr', 'Eid-ul-Adha'],
            backgroundColor: primaryColor,
            selectedTabColor: Colors.white,
            unselectedTabColor: const Color.fromARGB(255, 0, 0, 0),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GetBuilder<HomeController>(
              builder: (homeController) {
                // Match the composite key used in fetchLifeEventsByTag (mainTag_subTag)
                final subTag =
                    selectedIndex == 0 ? 'eid_ul_fitr' : 'eid_ul_adha';
                final key = 'eidain_$subTag';
                final isLoading = homeController.isLifeEventLoading(key);
                final items = homeController.getLifeEventItems(key);

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No steps found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, idx) {
                    final item = items[idx];
                    final audioId = (item.step ?? idx).hashCode;
                    final title = AppLanguageHelper.pickText(
                        item.title, titleLanguageCode);
                    final content =
                        AppLanguageHelper.pickText(item.text, textLanguageCode);
                    return DropdownListTile(
                      key: ValueKey(
                          'eidain_${selectedIndex}_${item.step ?? idx}'),
                      index: item.step ?? idx + 1,
                      title: title.isNotEmpty ? title : '—',
                      content: content,
                      tileColor: primaryColor,
                      showActions: false,
                      onPlayAudio: () {
                        if (content.isNotEmpty) {
                          audioController.textToSpeechSingleLanguage(
                              content, audioId,
                              language: ttsTextLanguageCode);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

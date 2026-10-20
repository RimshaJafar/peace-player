import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/worships_life_cards.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/dropdown_list_tile.dart';
import 'package:ecommerce_app/features/seerah_nabwi/controllers/seerah_nabwi_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';

class PhysicalAttributesScreen extends StatefulWidget {
  const PhysicalAttributesScreen({super.key});

  @override
  State<PhysicalAttributesScreen> createState() =>
      _PhysicalAttributesScreenState();
}

class _PhysicalAttributesScreenState extends State<PhysicalAttributesScreen> {
  final SeerahNabwiController controller = Get.put(SeerahNabwiController());
  late AudioTTSSTTController audioController;
  static const String _mainTag = 'attributes';
  static const String _subTag = 'none';

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioTTSSTTController>();
    controller.fetchSeerahFeatures(mainTag: _mainTag, subTag: _subTag);
  }

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final ttsTextLanguageCode = textLanguageCode == 'ur' ? 'ur' : 'en';

    return Scaffold(
      appBar: PAppBar(
        title: Text(
          'Physical Attributes',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: GetBuilder<SeerahNabwiController>(
        builder: (seerahController) {
          final key = '${_mainTag}_$_subTag';
          final isLoading = seerahController.isFeatureLoading(key);
          final items = seerahController.getFeatureItems(key);

          return Column(
            children: [
              // DuaCard at the top (Static)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: ReferenceAyahHadithBox(
                  featureKey: 'physical_attributes',
                  borderColor: Color(0xFF329070),
                ),
              ),
              // ListView below
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                        ? const Center(
                            child: Text('No data available'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final title = AppLanguageHelper.pickText(
                                  item.title, titleLanguageCode);
                              final content = AppLanguageHelper.pickText(
                                  item.text, textLanguageCode);
                              final step = item.step ?? index + 1;

                              return DropdownListTile(
                                title: title,
                                content: content,
                                index: step,
                                tileColor: const Color(0xFF329070),
                                showActions: false,
                                onPlayAudio: () {
                                  if (content.isNotEmpty) {
                                    audioController.textToSpeechSingleLanguage(
                                        content, step,
                                        language: ttsTextLanguageCode);
                                  }
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

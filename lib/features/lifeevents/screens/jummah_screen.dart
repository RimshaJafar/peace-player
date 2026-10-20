import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/worships_life_cards.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/dropdown_list_tile.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/home/controllers/home_controller.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';

class JummahScreen extends StatefulWidget {
  const JummahScreen({super.key});

  @override
  State<JummahScreen> createState() => _JummahScreenState();
}

class _JummahScreenState extends State<JummahScreen> {
  final Color primaryColor = const Color(0xFF3C98A0);
  final HomeController controller = Get.find<HomeController>();
  late AudioTTSSTTController audioController;

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioTTSSTTController>();
    // Fetch life events for Jummah
    controller.fetchLifeEventsByTag('jumuah', 'general');
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
          'Jummah',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReferenceAyahHadithBox(
                featureKey: 'Jummah',
                borderColor: Color(0xFF3C98A0),
              ),
              SizedBox(height: 24),
              Text(
                'Steps',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 16),
              GetBuilder<HomeController>(
                builder: (homeController) {
                  final isLoading =
                      homeController.isLifeEventLoading('jumuah_general');
                  final items =
                      homeController.getLifeEventItems('jumuah_general');

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

                  return Column(
                    children: [
                      ...List.generate(
                        items.length,
                        (index) {
                          final item = items[index];
                          final audioId = (item.step ?? index).hashCode;
                          final title = AppLanguageHelper.pickText(
                              item.title, titleLanguageCode);
                          final content = AppLanguageHelper.pickText(
                              item.text, textLanguageCode);
                          return DropdownListTile(
                            index: item.step ?? index + 1,
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
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

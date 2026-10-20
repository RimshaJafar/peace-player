import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/containers/kids_screen_background.dart';
import 'package:ecommerce_app/common/widgets/containers/namaz_content_container.dart';
import 'package:ecommerce_app/common/widgets/cards/namaz_step_card.dart';
import 'package:ecommerce_app/common/widgets/video/network_video_player.dart';
import 'package:ecommerce_app/features/kids/controllers/kids_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';

class LearnWuduScreen extends StatefulWidget {
  const LearnWuduScreen({super.key});

  @override
  State<LearnWuduScreen> createState() => _LearnWuduScreenState();
}

class _LearnWuduScreenState extends State<LearnWuduScreen> {
  final KidsController controller = Get.put(KidsController());
  late AudioTTSSTTController audioController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioTTSSTTController>();
    controller.fetchLearnSteps('wudu');
  }

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final isUrduText = textLanguageCode == 'ur';
    return Scaffold(
      backgroundColor: const Color(0xFFE9F3EF),
      appBar: const PAppBar(
        title: Text(
          'Wudu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF749BC2),
        showBackArrow: true,
      ),
      body: KidsScreenBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Obx(() {
              if (controller.isLearnStepsLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.learnSteps.isEmpty) {
                return const Center(child: Text('No data available'));
              }
              final steps = controller.learnSteps;
              return NamazContentContainer(
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return _buildWuduStep(
                      stepNumber: '${step.step}/${steps.length}',
                      imageUrl: step.imageUrl,
                      cardIndex: index,
                      stepTitle: AppLanguageHelper.pickText(
                          step.title, titleLanguageCode),
                      stepDescription: AppLanguageHelper.pickText(
                          step.text, textLanguageCode),
                      isUrdu: isUrduText,
                      ttsLanguageCode: textLanguageCode,
                      isVideoActive: index == _currentPage,
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildWuduStep({
    required String stepNumber,
    required String imageUrl,
    required int cardIndex,
    required String stepTitle,
    required String stepDescription,
    required bool isUrdu,
    required String ttsLanguageCode,
    required bool isVideoActive,
  }) {
    const accentColor = Color(0xFF749BC2);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Step Number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.layers_rounded,
                  color: accentColor,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  stepNumber,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF456B90),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Wudu Step Video
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F3),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.90),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: NetworkVideoPlayer(
                url: imageUrl,
                isActive: isVideoActive,
                accentColor: accentColor,
                debugLabel: 'learn-wudu step $stepNumber',
              ),
            ),
          ),
          const SizedBox(height: 26),

          // Wudu Step Card with gradient
          Expanded(
            flex: 4,
            child: NamazStepCard(
              cardIndex: cardIndex,
              onPlayAudio: () {
                final stepDesc = stepDescription;
                if (stepDesc.isNotEmpty) {
                  audioController.textToSpeechSingleLanguage(
                      stepDesc, cardIndex,
                      language: ttsLanguageCode == 'ur' ? 'ur' : 'en');
                }
              },
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(54, 24, 54, 0),
                    child: Text(
                      stepTitle,
                      textDirection:
                          isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      style: isUrdu
                          ? GoogleFonts.notoNastaliqUrdu(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF444444),
                              height: 1.5,
                            )
                          : GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF444444),
                              height: 1.3,
                            ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              stepDescription,
                              textDirection: isUrdu
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: isUrdu
                                  ? GoogleFonts.notoNastaliqUrdu(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      height: 1.8,
                                    )
                                  : GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      height: 1.6,
                                    ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

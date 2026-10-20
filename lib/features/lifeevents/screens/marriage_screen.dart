import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/worships_life_cards.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/dropdown_list_tile.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/home/controllers/home_controller.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';

class MarriageScreen extends StatefulWidget {
  const MarriageScreen({super.key});

  @override
  State<MarriageScreen> createState() => _MarriageScreenState();
}

class _MarriageScreenState extends State<MarriageScreen> {
  final Color primaryColor = const Color(0xFFBE5C94);
  final HomeController controller = Get.find<HomeController>();
  late AudioTTSSTTController audioController;

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioTTSSTTController>();
    // Fetch life events for marriage
    controller.fetchLifeEventsByTag('marriage', 'general');
  }

  final List<Map<String, String>> stepsData = [
    {
      'title': 'نیت اور دعا',
      'content':
          'شادی کے لیے نیت صاف رکھیں۔\nاللہ سے نیک اور مطمئن ساتھی کی دعا کریں تاکہ زندگی میں سکون اور خوشیاں حاصل ہوں۔\n\nنماز استخارہ: اگر آپ کسی شخص سے شادی کرنے کا فیصلہ کر رہے ہیں اور شک یا ہچکچاہٹ ہے تو اللہ سے رہنمائی طلب کرنے کے لیے نماز استخارہ پڑھیں۔ استخارہ کے ذریعے اللہ کی مرضی معلوم کرنے کی کوشش کریں۔\n\nاستخارہ کا مقصد اللہ سے کسی بھی اہم معاملے، خصوصاً شادی میں، خیر اور درست فیصلہ مانگنا ہے۔ دو رکعت پڑھ کر دل کا سکون یا بےچینی ہی اللہ کی جانب سے رہنمائی کا اشارہ ہوتا ہے۔'
    },
    {
      'title': 'رشتہ تلاش کرنا',
      'content':
          '• نیک سیرت والی لڑکی/لڑکے کی تلاش کریں\n• خاندار کی اخلاقیات کا خیال رکھیں\n• دونوں فریقین سے ملاقات کریں\n• اعتماد سے فیصلہ کریں'
    },
    {
      'title': 'اسلامی رسوم',
      'content':
          '• نکاح خطبہ پڑھوائیں\n• شرعی شہادت موجود ہو\n• والدین کی موافقت لیں\n• محرم رشتہ سے رضامندی حاصل کریں'
    },
    {
      'title': 'شادی کی تقریب',
      'content':
          '• اسلامی آداب کی پاسداری کریں\n• بے پردگی سے بچیں\n• موسیقی سے اجتناب کریں\n• سادگی کو ترجیح دیں'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final ttsTextLanguageCode = textLanguageCode == 'ur' ? 'ur' : 'en';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PAppBar(
        title: Text(
          'Marriage',
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
              // Top Ayah Card
              const ReferenceAyahHadithBox(
                featureKey: 'marriage',
                borderColor: Color(0xFFBE5C94),
              ),
              SizedBox(height: 24),

              // Steps Title
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
                      homeController.isLifeEventLoading('marriage_general');
                  final items =
                      homeController.getLifeEventItems('marriage_general');

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

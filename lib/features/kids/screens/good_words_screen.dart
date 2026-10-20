import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/good_words_card.dart';
import 'package:ecommerce_app/features/kids/controllers/kids_controller.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GoodWordsScreen extends StatefulWidget {
  const GoodWordsScreen({super.key});

  @override
  State<GoodWordsScreen> createState() => _GoodWordsScreenState();
}

class _GoodWordsScreenState extends State<GoodWordsScreen>
    with SingleTickerProviderStateMixin {
  final KidsController kidsController = Get.put(KidsController());
  late AudioTTSSTTController audioController;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 0;

  final List<Map<String, String>> _textPairs = const [
    {
      'arabic': 'وَقُولُوا لِلنَّاسِ حُسْنًا',
      'urdu': 'لوگوں کے ساتھ حسن سلوک کے ساتھ بات کرو۔',
      'english': 'Speak kindly to people.',
    },
    {
      'arabic': 'وَقُل رَّبِّ زِدۡنِی عِلۡمࣰا',
      'urdu': 'اور کہو: اے میرے رب! مجھے مزید علم عطا فرما۔',
      'english': 'And say: My Lord, increase me in knowledge.',
    },
    {
      'arabic': 'إِنَّ ٱللَّهَ مَعَ ٱلصَّـٰبِرِينَ',
      'urdu': 'بے شک اللہ صبر کرنے والوں کے ساتھ ہے۔',
      'english': 'Indeed, Allah is with the patient.',
    },
  ];

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioTTSSTTController>();
    kidsController.fetchIslamicTerms();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-1.5, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _textPairs.length;
        });
        _controller.reset();
        _scheduleNextSlide();
      }
    });

    _scheduleNextSlide();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final referenceLanguageCode =
        AppLanguageHelper.referenceAyahHadithLanguageCode();
    final isArabic = referenceLanguageCode == 'ar';
    final isUrduTranslation = textLanguageCode == 'ur';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PAppBar(
        title: Text(
          'Good Words',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFCAA5CB),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/kids/goodwords.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 120,
                      left: 20,
                      right: 20,
                      bottom: 50,
                    ),
                    child: ClipRect(
                      child: Center(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _pickReferenceText(
                                  _textPairs[_currentIndex],
                                  referenceLanguageCode,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: isArabic || isUrduTranslation
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                style: isArabic
                                    ? GoogleFonts.amiri(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        height: 1.6,
                                      )
                                    : isUrduTranslation
                                        ? GoogleFonts.notoNastaliqUrdu(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF808080),
                                            height: 1.7,
                                          )
                                        : GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF808080),
                                            height: 1.5,
                                          ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (kidsController.isIslamicTermsLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (kidsController.islamicTerms.isEmpty) {
                return const Center(child: Text('No data available'));
              }
              return Column(
                children: List.generate(
                  kidsController.islamicTerms.length,
                  (i) {
                    final term = kidsController.islamicTerms[i];
                    final translation = AppLanguageHelper.pickText(
                      term.translations,
                      textLanguageCode,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Transform.translate(
                        offset: const Offset(0, 0),
                        child: Center(
                          child: GoodWordsCard(
                            arabicText: term.textArabic,
                            translationText: translation,
                            translationIsUrdu: isUrduTranslation,
                            arabicColor: Colors.white,
                            urduColor: Colors.black,
                            cardIndex: i,
                            onPlayAudio: () {
                              final arabic = term.textArabic ?? '';
                              final playText = [arabic, translation]
                                  .where((t) => t.isNotEmpty)
                                  .join(' | ');
                              if (playText.isNotEmpty) {
                                audioController.textToSpeech(playText, i);
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _scheduleNextSlide() {
    if (_textPairs.length <= 1) {
      return;
    }
    Future.delayed(const Duration(seconds: 7), () {
      if (!mounted || _textPairs.length <= 1) {
        return;
      }
      if (!_controller.isAnimating) {
        _controller.forward();
      }
    });
  }

  String _pickReferenceText(
    Map<String, String> values,
    String languageCode,
  ) {
    if (languageCode == 'ar') {
      return values['arabic'] ?? values['english'] ?? values['urdu'] ?? '';
    }
    if (languageCode == 'ur') {
      return values['urdu'] ?? values['english'] ?? values['arabic'] ?? '';
    }
    if (languageCode == 'en') {
      return values['english'] ?? values['urdu'] ?? values['arabic'] ?? '';
    }
    return values['english'] ?? values['urdu'] ?? values['arabic'] ?? '';
  }
}

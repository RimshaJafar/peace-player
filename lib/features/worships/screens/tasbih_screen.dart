import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';

class TasbihScreen extends StatefulWidget {
  final String? arabicText;
  final String? urduText;
  const TasbihScreen({super.key, this.arabicText, this.urduText});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int counter = 0;
  int currentTasbihIndex = 0;
  late AudioTTSSTTController audioController;
  late UserController userController;
  late AuthenticationRepository authRepo;
  late List<Map<String, String>> tasbihList;
  final storage = GetStorage();
  late String storageKey;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioTTSSTTController>();
    userController = Get.find<UserController>();
    authRepo = Get.find<AuthenticationRepository>();

    // Get current user ID
    if (authRepo.isLoggedInRx.value && userController.user.value.id != null) {
      currentUserId = userController.user.value.id;
    }

    // Initialize tasbihList with passed data or default
    if (widget.arabicText != null && widget.urduText != null) {
      tasbihList = [
        {
          'arabic': widget.arabicText!,
          'urdu': widget.urduText!,
          'english': '',
        },
      ];
    } else {
      tasbihList = [
        {
          'arabic': 'اللَّهُ أَكْبَرُ',
          'urdu': 'اللہ سب سے بڑا ہے',
          'english': 'Allah is the Greatest',
        },
      ];
    }

    // Create unique user-specific storage key
    final arabicHash = tasbihList[0]['arabic']?.hashCode ?? 0;
    storageKey = currentUserId != null
        ? '${currentUserId}_tasbih_count_$arabicHash'
        : 'tasbih_count_$arabicHash';

    // Load saved counter value
    counter = storage.read(storageKey) ?? 0;
  }

  void _saveCounter() {
    storage.write(storageKey, counter);
  }

  void _incrementCounter() {
    setState(() {
      counter++;
      _saveCounter();
    });
    _debugLog('Counter incremented to: $counter');
  }

  void _decrementCounter() {
    if (counter > 0) {
      setState(() {
        counter--;
        _saveCounter();
      });
      _debugLog('Counter decremented to: $counter');
    }
  }

  void _resetCounter() {
    setState(() {
      counter = 0;
      _saveCounter();
    });
  }

  Future<void> _playTasbihAudio() async {
    final currentTasbih = tasbihList[currentTasbihIndex];
    final arabic = currentTasbih['arabic'] ?? '';
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final translation =
        AppLanguageHelper.pickText(currentTasbih, textLanguageCode);

    final playText =
        [arabic, translation].where((t) => t.isNotEmpty).join(' | ');

    // Use a fixed ID (0) for tasbih audio
    if (playText.isNotEmpty) {
      await audioController.textToSpeech(playText, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTasbih = tasbihList[currentTasbihIndex];
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final translationText =
        AppLanguageHelper.pickText(currentTasbih, textLanguageCode);
    final isUrdu = textLanguageCode == 'ur';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4A2C37),
              const Color(0xFFF2ECB6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Main content area - Top Tasbih Box and Image (tap to increment)
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Top Tasbih Box
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 340,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white.withValues(alpha: 0.95),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            currentTasbih['arabic']!,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.amiri(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF4A2C37),
                                            ),
                                          ),
                                          if (translationText.isNotEmpty) ...[
                                            const SizedBox(height: 16),
                                            Text(
                                              translationText,
                                              textAlign: TextAlign.center,
                                              textDirection: TextDirectionUtils
                                                  .directionFor(
                                                textLanguageCode,
                                              ),
                                              style: isUrdu
                                                  ? GoogleFonts
                                                      .notoNastaliqUrdu(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )
                                                  : GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Speaker button for audio - positioned half outside on bottom left
                          Positioned(
                            bottom: -25,
                            left: 15,
                            child: GestureDetector(
                              onTap: _playTasbihAudio,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF4A2C37),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Obx(() {
                                  final isPlaying = audioController
                                          .currentPlayingMessageId.value ==
                                      0;
                                  return Icon(
                                    isPlaying ? Icons.pause : Icons.volume_up,
                                    color: Colors.white,
                                    size: 24,
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Spacer to center the tasbih image
                    const Spacer(flex: 2),

                    // Tasbih Image - Flexible to fit available space
                    Flexible(
                      flex: 5,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _debugLog('Image tapped - incrementing');
                          _incrementCounter();
                        },
                        child: Image.asset(
                          'assets/images/content/tasbih.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Spacer to center the tasbih image
                    const Spacer(),
                  ],
                ),
              ),

              // Bottom section - using Stack to control z-index properly
              SizedBox(
                height: 110 + 27.5, // Bar height + half button height
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Bottom bar - positioned at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: double.infinity,
                        height: 110,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A2C37),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Counter display
                              Container(
                                width: 140,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    counter.toString(),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Refresh square button
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  _debugLog('Reset button tapped');
                                  _resetCounter();
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white.withValues(alpha: 0.2),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.refresh,
                                    size: 35,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Minus button - positioned on top, overlapping the bar
                    Positioned(
                      left: 20,
                      top: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _debugLog('Minus button tapped - decrementing');
                          _decrementCounter();
                        },
                        child: Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 32,
                            color: Color(0xFF4A2C37),
                          ),
                        ),
                      ),
                    ),

                    // Plus button - positioned on top, overlapping the bar
                    Positioned(
                      right: 20,
                      top: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _debugLog('Plus button tapped - incrementing');
                          _incrementCounter();
                        },
                        child: Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 32,
                            color: Color(0xFF4A2C37),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _debugLog(String message) {
    if (kDebugMode) debugPrint(message);
  }
}

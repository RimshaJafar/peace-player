import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar_action_button.dart';
import 'package:ecommerce_app/common/widgets/bottom_sheets/qari_audio_picker.dart';
import 'package:ecommerce_app/common/widgets/bottom_sheets/surah_picker.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/common/widgets/quran_listening/quran_info_box.dart';
import 'package:ecommerce_app/common/widgets/quran_listening/quran_listening_search_bar.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/helpers/billing_gate_helper.dart';
import 'package:ecommerce_app/features/billing/services/billing_api_service.dart';
import 'package:ecommerce_app/features/billing/widgets/billing_usage_button.dart';
import 'package:ecommerce_app/features/quran_hadith/controllers/quran_hadith_controller.dart';
import 'package:ecommerce_app/features/quran_listening/models/quran_listening_command_request.dart';
import 'package:ecommerce_app/features/quran_listening/services/quran_listening_service.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:ecommerce_app/utils/local_storage/storage_utility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuranListeningScreen extends StatefulWidget {
  const QuranListeningScreen({super.key});

  @override
  State<QuranListeningScreen> createState() => _QuranListeningScreenState();
}

class _QuranListeningScreenState extends State<QuranListeningScreen> {
  final QuranHadithController controller = Get.put(QuranHadithController());
  final PLocalStorage _storage = PLocalStorage();
  final int selectedTabIndex = 0;
  int currentNumber = 1; // Current surah number
  int totalNumber = 114;
  late ScrollController _textScrollController;

  // Audio settings
  late String selectedAudioLanguage;
  late String selectedReciter;

  // Audio player
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  int _currentAyahIndex = 0; // which ayah audio is currently playing

  // AI command integration
  late final AudioTTSSTTController _audioController;
  late final QuranListeningService _commandService;
  late final TextEditingController _commandTextController;
  bool _isCommandLoading = false;

  // Duration tracking per ayah
  List<Duration> _ayahDurations = []; // duration of each ayah audio
  List<Duration> _originalEstimates =
      []; // keep original estimates for recalibration
  Set<int> _realDurationIndices = {}; // which ayahs have real durations
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero; // global position across all ayahs
  Duration _currentAyahLocalPosition =
      Duration.zero; // position within current ayah

  // Text scroll sync
  final GlobalKey _textKey = GlobalKey();
  bool _audioLoaded = false;
  bool _isLoadingSurah = false;
  String _surahLoadError = '';
  String _audioLoadError = '';

  // Surah info
  String _surahName = '';
  int _totalAyahs = 0;

  @override
  void initState() {
    super.initState();
    _loadDefaultsFromStorage();
    _textScrollController = ScrollController();
    _audioPlayer = AudioPlayer();

    if (!Get.isRegistered<AudioTTSSTTController>()) {
      Get.put(AudioTTSSTTController());
    }
    _audioController = Get.find<AudioTTSSTTController>();
    _commandService = QuranListeningService();
    _commandTextController = TextEditingController();

    // Listen to audio position updates
    _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        _currentAyahLocalPosition = position;
        // Calculate global position: sum of all previous ayah durations + current position
        Duration preceding = Duration.zero;
        for (int i = 0;
            i < _currentAyahIndex && i < _ayahDurations.length;
            i++) {
          preceding += _ayahDurations[i];
        }
        _currentPosition = preceding + position;
      });
      _syncTextScroll();
    });

    // When current ayah finishes, play next one
    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      unawaited(_playNextAyah());
    }, onError: (Object error, StackTrace stackTrace) {
      _handlePlaybackError(error, stackTrace);
    });

    // Listen to duration of currently loaded ayah & recalibrate estimates
    _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) return;
      if (_currentAyahIndex < _ayahDurations.length) {
        setState(() {
          _ayahDurations[_currentAyahIndex] = duration;
          _realDurationIndices.add(_currentAyahIndex);

          // Recalibrate remaining estimates using average ratio of real vs original
          if (_originalEstimates.isNotEmpty &&
              _realDurationIndices.isNotEmpty) {
            double totalRatio = 0;
            int ratioCount = 0;
            for (final idx in _realDurationIndices) {
              if (idx < _originalEstimates.length &&
                  _originalEstimates[idx].inMilliseconds > 0) {
                totalRatio += _ayahDurations[idx].inMilliseconds /
                    _originalEstimates[idx].inMilliseconds;
                ratioCount++;
              }
            }
            if (ratioCount > 0) {
              final avgRatio = totalRatio / ratioCount;
              for (int i = 0; i < _ayahDurations.length; i++) {
                if (!_realDurationIndices.contains(i) &&
                    i < _originalEstimates.length) {
                  _ayahDurations[i] = Duration(
                    milliseconds:
                        (_originalEstimates[i].inMilliseconds * avgRatio)
                            .round(),
                  );
                }
              }
            }
          }

          _totalDuration = _ayahDurations.fold(Duration.zero, (a, b) => a + b);
        });
      }
    });

    // Fetch surahs for picker, audio urls for picker
    controller.fetchSurahs();
    controller.fetchAudioUrls();

    // Load initial surah
    _loadSurah(currentNumber);
  }

  void _loadDefaultsFromStorage() {
    selectedAudioLanguage =
        _storage.readData<String>(QuranHadithSettingsKeys.reciterLanguage) ??
            QuranHadithDefaults.surahsAyahsTilesDefaultRecitationLanguage;
    selectedReciter = _storage
            .readData<String>(QuranHadithSettingsKeys.reciterName) ??
        QuranHadithDefaults.surahsAyahsTilesDefaultRecitationLanguageReciter;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _commandTextController.dispose();
    _textScrollController.dispose();
    super.dispose();
  }

  // ─── LOAD SURAH DATA ───────────────────────────────────────────
  Future<void> _loadSurah(int surahNumber) async {
    if (_isLoadingSurah) return;
    _isLoadingSurah = true;
    try {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _currentAyahIndex = 0;
        _currentPosition = Duration.zero;
        _currentAyahLocalPosition = Duration.zero;
        _totalDuration = Duration.zero;
        _ayahDurations = [];
        _originalEstimates = [];
        _realDurationIndices = {};
        _audioLoaded = false;
        _surahLoadError = '';
        _audioLoadError = '';
      });

      await controller.fetchSurahAyahs(surahNumber);
      if (!mounted) return;
      if (controller.ayahError.value.isNotEmpty) {
        setState(() {
          _surahLoadError = controller.ayahError.value;
        });
        return;
      }

      if (controller.surahAyahs.isNotEmpty) {
        final firstAyah = controller.surahAyahs.first;
        _surahName =
            firstAyah.surahName['ar'] ?? firstAyah.surahName['en'] ?? '';
        _totalAyahs = controller.surahAyahs.length;
      } else {
        _surahName = '';
        _totalAyahs = 0;
      }
      setState(() {});

      if (_textScrollController.hasClients) {
        _textScrollController.jumpTo(0);
      }

      await _loadAudioForCurrentSurah(surahNumber);
    } catch (error, stackTrace) {
      _logDebug('Surah loading failed.', error, stackTrace);
      if (!mounted) return;
      final friendly = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load this Surah. Please try again.',
      );
      setState(() {
        _surahLoadError = friendly;
      });
      PLoaders.errorSnackBar(
        title: 'Surah Load Failed',
        message: friendly,
        context: context,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingSurah = false);
      } else {
        _isLoadingSurah = false;
      }
    }
  }

  // ─── PLAYBACK CONTROLS ─────────────────────────────────────────
  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        if (mounted) setState(() => _isPlaying = false);
      } else {
        if (controller.surahAudios.isEmpty) {
          PLoaders.warningSnackBar(
            title: 'Audio Unavailable',
            message: 'Audio unavailable. Try another reciter or retry.',
            context: context,
          );
          return;
        }

        if (_currentAyahLocalPosition == Duration.zero &&
            _currentAyahIndex < controller.surahAudios.length) {
          await _playAyahAtIndex(_currentAyahIndex);
        } else {
          await _audioPlayer.resume();
        }
        if (mounted) setState(() => _isPlaying = true);
      }
    } catch (error, stackTrace) {
      _handlePlaybackError(error, stackTrace);
    }
  }

  Future<void> _playAyahAtIndex(int index) async {
    if (index >= controller.surahAudios.length) {
      // Finished all ayahs
      setState(() {
        _isPlaying = false;
        _currentAyahIndex = 0;
        _currentPosition = Duration.zero;
        _currentAyahLocalPosition = Duration.zero;
      });
      if (_textScrollController.hasClients) {
        _textScrollController.jumpTo(0);
      }
      return;
    }

    final audio = controller.surahAudios[index];
    setState(() => _currentAyahIndex = index);

    try {
      await _audioPlayer.stop();
      await _audioPlayer
          .play(UrlSource(audio.audioUrl, mimeType: 'audio/mpeg'));
    } catch (error, stackTrace) {
      _handlePlaybackError(error, stackTrace);
    }
  }

  Future<void> _playNextAyah() async {
    final nextIndex = _currentAyahIndex + 1;
    if (nextIndex < controller.surahAudios.length) {
      await _playAyahAtIndex(nextIndex);
    } else {
      // All ayahs finished
      setState(() {
        _isPlaying = false;
        _currentAyahIndex = 0;
        _currentPosition = Duration.zero;
        _currentAyahLocalPosition = Duration.zero;
      });
      if (_textScrollController.hasClients) {
        _textScrollController.jumpTo(0);
      }
    }
  }

  Future<void> _playPreviousAyah() async {
    final previousIndex = _currentAyahIndex - 1;
    if (previousIndex >= 0) {
      await _playAyahAtIndex(previousIndex);
    }
  }

  // ─── SLIDER SEEK ───────────────────────────────────────────────
  void _onSliderChanged(double value) {
    if (_totalDuration == Duration.zero) return;

    final seekPosition = Duration(
      milliseconds: (value * _totalDuration.inMilliseconds).round(),
    );

    // Find which ayah this position falls into
    Duration cumulative = Duration.zero;
    for (int i = 0; i < _ayahDurations.length; i++) {
      if (cumulative + _ayahDurations[i] > seekPosition) {
        final localPos = seekPosition - cumulative;
        setState(() {
          _currentAyahIndex = i;
          _currentPosition = seekPosition;
          _currentAyahLocalPosition = localPos;
        });

        if (_isPlaying) {
          unawaited(_playAndSeek(i, localPos));
        }
        return;
      }
      cumulative += _ayahDurations[i];
    }
  }

  // ─── TEXT SCROLL SYNC ──────────────────────────────────────────
  void _syncTextScroll() {
    if (!_isPlaying) return;
    if (!_textScrollController.hasClients) return;
    if (controller.surahAyahs.isEmpty) return;

    final totalAyahs = controller.surahAyahs.length;
    if (totalAyahs == 0) return;

    // Calculate progress fraction (0.0 to 1.0) based on current ayah index + local progress
    double ayahFraction = 0.0;
    if (_currentAyahIndex < _ayahDurations.length &&
        _ayahDurations[_currentAyahIndex].inMilliseconds > 0) {
      ayahFraction = _currentAyahLocalPosition.inMilliseconds /
          _ayahDurations[_currentAyahIndex].inMilliseconds;
    }
    final overallProgress = (_currentAyahIndex + ayahFraction) / totalAyahs;

    final maxScroll = _textScrollController.position.maxScrollExtent;
    final targetScroll = maxScroll * overallProgress;

    unawaited(
      _animateTextScroll(targetScroll.clamp(0.0, maxScroll)),
    );
  }

  Future<void> _animateTextScroll(double targetScroll) async {
    try {
      await _textScrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[QuranListening] Text scroll animation failed: $error');
        debugPrint(stackTrace.toString());
      }
    }
  }

  // ─── HELPERS ───────────────────────────────────────────────────
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _sliderValue {
    if (_totalDuration == Duration.zero) return 0.0;
    return (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  String _buildCombinedText() {
    if (controller.surahAyahs.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
    buffer.writeln();

    for (final ayah in controller.surahAyahs) {
      buffer.write(
          '${ayah.textArabic} ﴿${_toArabicNumeral(ayah.ayahNumberInSurah)}﴾ ');
    }
    return buffer.toString().trim();
  }

  String _toArabicNumeral(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }

  // ─── SEARCH ─────────────────────────────────────────────────────
  void _onSearchSurah(String query) {
    final number = int.tryParse(query);
    if (number != null && number >= 1 && number <= totalNumber) {
      setState(() => currentNumber = number);
      _loadSurah(number);
    } else {
      if (!mounted) return;
      PLoaders.warningSnackBar(
        title: 'Invalid Surah',
        message: 'Enter a valid surah number (1-114)',
        context: context,
      );
    }
  }

  Future<void> _handleSendCommand() async {
    final command = _commandTextController.text.trim();
    if (command.isEmpty) {
      if (!mounted) return;
      PLoaders.warningSnackBar(
        title: 'Command Required',
        message: 'Please enter a command',
        context: context,
      );
      return;
    }

    _commandTextController.clear();
    await _processListeningCommand(command);
  }

  Future<void> _processListeningCommand(String command) async {
    if (_isCommandLoading) return;
    if (!await BillingGateHelper.ensureFeatureAccess(
      BillingFeatureKeys.quranListeningAgent,
    )) {
      return;
    }
    setState(() => _isCommandLoading = true);

    try {
      final response = await _commandService.sendCommand(
        QuranListeningCommandRequest(text: command),
      );

      if (!mounted) return;

      if (!response.success) {
        PLoaders.errorSnackBar(
          title: 'Command Error',
          message: response.message.isNotEmpty
              ? response.message
              : 'Unable to process command. Please try again.',
          context: context,
        );
        return;
      }

      if (response.confidence < 0.5) {
        PLoaders.warningSnackBar(
          title: 'Low Confidence',
          message:
              'Command confidence is low. Please try again with clearer phrasing.',
          context: context,
        );
      }

      if (response.action == 'play_surah' && response.surahNumber != null) {
        setState(() => currentNumber = response.surahNumber!);
        await _loadSurah(response.surahNumber!);
        await _togglePlayPause();
        if (!mounted) return;
        PLoaders.successSnackBar(
          title: 'Playing',
          message:
              'Playing Surah ${response.surahName ?? response.surahNumber.toString()}',
          context: context,
        );
        return;
      }

      if (response.action == 'play_ayah' &&
          response.surahNumber != null &&
          response.ayahNumber != null) {
        setState(() => currentNumber = response.surahNumber!);
        await _loadSurah(response.surahNumber!);
        if (!mounted) return;
        final ayahIndex = response.ayahNumber! - 1; // Zero-based index
        if (ayahIndex >= 0 && ayahIndex < controller.surahAudios.length) {
          await _playAyahAtIndex(ayahIndex);
        } else {
          PLoaders.warningSnackBar(
            title: 'Invalid Ayah',
            message: 'Invalid Ayah number for this Surah',
            context: context,
          );
          return;
        }
        if (!mounted) return;
        PLoaders.successSnackBar(
          title: 'Playing',
          message:
              'Playing Surah ${response.surahName ?? response.surahNumber.toString()} Ayah ${response.ayahNumber}',
          context: context,
        );
        return;
      }
    } on BillingApiException catch (error) {
      BillingGateHelper.handleException(error);
    } catch (error, stackTrace) {
      _logDebug('Listening command failed.', error, stackTrace);
      if (mounted) {
        PLoaders.errorSnackBar(
          title: 'Command Error',
          message: AppErrorMessage.fromException(
            error,
            fallback: 'Unable to process the command. Please try again.',
          ),
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCommandLoading = false);
      }
    }
  }

  Future<void> _handleMicTap() async {
    try {
      final state = _audioController.voiceState.value;
      if (state == VoiceInputState.idle) {
        await _audioController.startVoiceInput();
        return;
      }

      if (state == VoiceInputState.recording) {
        final result = await _audioController.stopVoiceAndConvert();
        if (result?.text.trim().isNotEmpty ?? false) {
          _commandTextController.text = result!.text.trim();
          _commandTextController.selection = TextSelection.collapsed(
            offset: _commandTextController.text.length,
          );
          await _processListeningCommand(result.text.trim());
        }
      }
    } catch (error, stackTrace) {
      _logDebug('Microphone action failed.', error, stackTrace);
      if (!mounted) return;
      PLoaders.errorSnackBar(
        title: 'Voice Input Failed',
        message: 'Unable to use voice input. Please try again.',
        context: context,
      );
    }
  }

  Future<void> _handleCancelVoice() async {
    try {
      await _audioController.cancelVoiceInput();
    } catch (error, stackTrace) {
      _logDebug('Voice cancellation failed.', error, stackTrace);
    }
  }

  Widget _buildQuranInfoBox({required bool compact}) {
    return QuranInfoBox(
      selectedTabIndex: selectedTabIndex,
      currentNumber: currentNumber,
      totalNumber: totalNumber,
      surahName: _surahName,
      totalAyahs: _totalAyahs,
      compact: compact,
      onSearch: _onSearchSurah,
      onDecrement: () async {
        if (currentNumber > 1) {
          setState(() => currentNumber--);
          await _loadSurah(currentNumber);
        }
      },
      onIncrement: () async {
        if (currentNumber < totalNumber) {
          setState(() => currentNumber++);
          await _loadSurah(currentNumber);
        }
      },
    );
  }

  Widget _buildQuranTextPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD2E3DF),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Obx(() {
        if (controller.isSurahAyahsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_surahLoadError.isNotEmpty && controller.surahAyahs.isEmpty) {
          return _buildRetryState(
            message: _surahLoadError,
            onRetry: () => _loadSurah(currentNumber),
          );
        }
        if (controller.surahAyahs.isEmpty) {
          return const Center(child: Text('No ayahs available'));
        }
        final combinedText = _buildCombinedText();
        return SingleChildScrollView(
          controller: _textScrollController,
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  combinedText,
                  key: _textKey,
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C5D4E),
                    height: 1.8,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAudioProgressSection() {
    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF329070),
              inactiveTrackColor: Colors.grey[300],
              thumbColor: const Color(0xFF329070),
              thumbShape: const RoundSliderThumbShape(
                elevation: 4.0,
                enabledThumbRadius: 8.0,
              ),
              trackHeight: 8.0,
            ),
            child: Slider(
              value: _sliderValue,
              min: 0.0,
              max: 1.0,
              onChanged: _onSliderChanged,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Previous Ayah',
          icon: const Icon(Icons.fast_rewind),
          iconSize: 34,
          color: Colors.grey.shade700,
          disabledColor: Colors.grey.shade400,
          onPressed: _currentAyahIndex <= 0 ? null : _playPreviousAyah,
        ),
        const SizedBox(width: 16),
        IconButton(
          tooltip: _isPlaying ? 'Pause' : 'Play',
          icon: _isPlaying
              ? const Icon(
                  Icons.pause_circle_filled,
                  size: 56,
                  color: Color(0xFF329070),
                )
              : const Icon(
                  Icons.play_circle_fill,
                  size: 56,
                  color: Color(0xFF329070),
                ),
          padding: EdgeInsets.zero,
          onPressed: _audioLoaded ? _togglePlayPause : null,
        ),
        const SizedBox(width: 16),
        IconButton(
          tooltip: 'Next Ayah',
          icon: const Icon(Icons.fast_forward),
          iconSize: 34,
          color: Colors.grey.shade700,
          disabledColor: Colors.grey.shade400,
          onPressed: controller.surahAudios.isEmpty ||
                  _currentAyahIndex >= controller.surahAudios.length - 1
              ? null
              : _playNextAyah,
        ),
      ],
    );
  }

  Widget _buildListeningContent({required bool compact}) {
    if (compact) {
      return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuranInfoBox(compact: true),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: _buildQuranTextPanel(),
            ),
            if (_audioLoadError.isNotEmpty) _buildAudioErrorState(),
            const SizedBox(height: 4),
            _buildAudioProgressSection(),
            const SizedBox(height: 4),
            _buildPlaybackControls(),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildQuranInfoBox(compact: false),
        const SizedBox(height: 12),
        Expanded(child: _buildQuranTextPanel()),
        if (_audioLoadError.isNotEmpty) _buildAudioErrorState(),
        const SizedBox(height: 4),
        _buildAudioProgressSection(),
        const SizedBox(height: 4),
        _buildPlaybackControls(),
      ],
    );
  }

  // ─── BUILD ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PAppBar(
        gradient: PColors.linearGradient,
        leadingWidth: MediaQuery.of(context).size.width,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    AppBarActionButton(
                      text: 'Surah',
                      onTap: () => _showSurahPicker(),
                    ),
                    AppBarActionButton(
                      text: 'Qari Audio',
                      onTap: () => _showAudioUrlPicker(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            const BillingUsageButton(
              featureKey: BillingFeatureKeys.quranListeningAgent,
              featureLabel: 'Quran Listening Agent',
              unitLabel: 'requests',
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFD9D9D9).withOpacity(0.4),
      body: Column(
        children: [
          /// Background container with content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isKeyboardOpen =
                        MediaQuery.viewInsetsOf(context).bottom > 0;
                    final bool useCompactLayout =
                        isKeyboardOpen || constraints.maxHeight < 420;

                    return _buildListeningContent(compact: useCompactLayout);
                  },
                ),
              ),
            ),
          ),

          /// Fixed bottom section with gradient and search bar
          Container(
            decoration: const BoxDecoration(
              gradient: PColors.linearGradient,
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 22),
            child: QuranListeningSearchBar(
              textController: _commandTextController,
              voiceState: _audioController.voiceState.value,
              isCommandLoading: _isCommandLoading,
              onMicTap: _handleMicTap,
              onSend: _handleSendCommand,
              onCancel: _handleCancelVoice,
            ),
          ),
        ],
      ),
    );
  }

  // ─── PICKERS ───────────────────────────────────────────────────
  void _showSurahPicker() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SurahPicker(
        surahs: controller.surahs,
        isLoading: controller.isLoading,
        selectedSurahNumber: currentNumber,
        onSelect: (surah) {
          setState(() {
            currentNumber = surah.surahNumber;
          });
          _loadSurah(surah.surahNumber);
        },
      ),
    );
  }

  void _showAudioUrlPicker() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QariAudioPicker(
        audioUrls: controller.audioUrls,
        isLoading: controller.isLoading,
        selectedReciter: selectedReciter,
        onSelect: (reciter) {
          setState(() {
            selectedAudioLanguage = 'ar';
            selectedReciter = reciter;
          });
          // Reload audio for current surah with new qari
          _reloadAudio();
        },
      ),
    );
  }

  Future<void> _reloadAudio() async {
    try {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _currentAyahIndex = 0;
        _currentPosition = Duration.zero;
        _currentAyahLocalPosition = Duration.zero;
        _totalDuration = Duration.zero;
        _ayahDurations = [];
        _originalEstimates = [];
        _realDurationIndices = {};
        _audioLoaded = false;
        _audioLoadError = '';
      });
      await _loadAudioForCurrentSurah(currentNumber);
      if (_textScrollController.hasClients) {
        _textScrollController.jumpTo(0);
      }
    } catch (error, stackTrace) {
      _logDebug('Audio reload failed.', error, stackTrace);
      if (!mounted) return;
      setState(() {
        _audioLoadError = 'Audio unavailable. Try another reciter or retry.';
      });
    }
  }

  Future<void> _loadAudioForCurrentSurah(int surahNumber) async {
    try {
      await controller.fetchSurahAudioUrls(
        surahNumber,
        selectedAudioLanguage,
        selectedReciter,
      );
      if (!mounted) return;
      if (controller.audioError.value.isNotEmpty ||
          controller.surahAudios.isEmpty) {
        setState(() {
          _audioLoadError = 'Audio unavailable. Try another reciter or retry.';
          _audioLoaded = false;
        });
        return;
      }

      _ayahDurations = List.generate(
        controller.surahAudios.length,
        (index) {
          if (index < controller.surahAyahs.length) {
            final charLength = controller.surahAyahs[index].textArabic.length;
            return Duration(
              milliseconds: (charLength * 200).clamp(3000, 60000),
            );
          }
          return const Duration(seconds: 5);
        },
      );
      _originalEstimates = List.from(_ayahDurations);
      _realDurationIndices = {};
      _totalDuration = _ayahDurations.fold(Duration.zero, (a, b) => a + b);
      setState(() {
        _audioLoaded = true;
        _audioLoadError = '';
      });
    } catch (error, stackTrace) {
      _logDebug('Surah audio loading failed.', error, stackTrace);
      if (!mounted) return;
      setState(() {
        _audioLoaded = false;
        _audioLoadError = 'Audio unavailable. Try another reciter or retry.';
      });
    }
  }

  Widget _buildAudioErrorState() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              _audioLoadError,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: _reloadAudio,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Future<void> _playAndSeek(int index, Duration position) async {
    try {
      await _playAyahAtIndex(index);
      await _audioPlayer.seek(position);
    } catch (error, stackTrace) {
      _handlePlaybackError(error, stackTrace);
    }
  }

  void _handlePlaybackError(Object error, [StackTrace? stackTrace]) {
    _logDebug('Audio playback failed.', error, stackTrace);
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _audioLoadError = 'Audio unavailable. Try another reciter or retry.';
    });
    PLoaders.errorSnackBar(
      title: 'Playback Failed',
      message:
          'Unable to play this audio. Please retry or choose another reciter.',
      context: context,
    );
  }

  void _logDebug(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode) return;
    debugPrint('[QuranListening] $message');
    if (error != null) debugPrint(error.toString());
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }
}

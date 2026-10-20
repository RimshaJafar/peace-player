import 'dart:async';
import 'dart:math' as math;

import 'package:ecommerce_app/features/reference_ayah_hadith/controllers/reference_ayah_hadith_controller.dart';
import 'package:ecommerce_app/features/reference_ayah_hadith/models/reference_ayah_hadith_model.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ReferenceAyahHadithBox extends StatefulWidget {
  final String featureKey;
  final Color borderColor;
  final double height;
  final double width;

  const ReferenceAyahHadithBox({
    super.key,
    required this.featureKey,
    this.borderColor = const Color(0xFF1C5D4E),
    this.height = 230,
    this.width = 375,
  });

  @override
  State<ReferenceAyahHadithBox> createState() => _ReferenceAyahHadithBoxState();
}

class _ReferenceAyahHadithBoxState extends State<ReferenceAyahHadithBox> {
  late final ReferenceAyahHadithController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ReferenceAyahHadithController>()
        ? Get.find<ReferenceAyahHadithController>()
        : Get.put(ReferenceAyahHadithController());
    _controller.fetchByFeature(widget.featureKey);
  }

  @override
  void didUpdateWidget(covariant ReferenceAyahHadithBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.featureKey != widget.featureKey) {
      _controller.fetchByFeature(widget.featureKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReferenceAyahHadithController>(
      id: _controller.buildId(widget.featureKey),
      builder: (controller) {
        final isLoading = controller.isFeatureLoading(widget.featureKey);
        final data = controller.getFeatureData(widget.featureKey);
        final referenceLanguageCode =
            AppLanguageHelper.referenceAyahHadithLanguageCode();
        final items =
            _ReferenceCardItem.fromResponse(data, referenceLanguageCode);

        if (isLoading && items.isEmpty) {
          return _buildShell(
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (items.isEmpty) {
          return _buildShell(
            child: const Center(child: Text('No references available')),
          );
        }

        return _ReferenceAyahHadithCard(
          items: items,
          borderColor: widget.borderColor,
          height: widget.height,
          width: widget.width,
        );
      },
    );
  }

  Widget _buildShell({required Widget child}) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.borderColor,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReferenceCardItem {
  final String arabic;
  final Map<String, String> translations;
  final String referenceLabel;

  const _ReferenceCardItem({
    required this.arabic,
    required this.translations,
    required this.referenceLabel,
  });

  static List<_ReferenceCardItem> fromResponse(
    ReferenceAyahHadithResponse? response,
    String referenceLanguageCode,
  ) {
    if (response == null) {
      return const [];
    }

    final items = <_ReferenceCardItem>[];

    for (final quran in response.quranReferences) {
      final surahName =
          _pickSurahName(quran.reference.surahName, referenceLanguageCode);
      final refLabel = _formatQuranReference(
        surahName,
        quran.reference.surahNumber,
        quran.reference.ayahNumberInSurah,
      );
      items.add(
        _ReferenceCardItem(
          arabic: quran.text,
          translations: _flattenTranslations(quran.translations),
          referenceLabel: refLabel,
        ),
      );
    }

    for (final hadith in response.hadithReferences) {
      final bookName =
          _pickBookName(hadith.reference.bookName, referenceLanguageCode);
      final refLabel = _formatHadithReference(
        bookName,
        hadith.reference.hadithNumber,
      );
      items.add(
        _ReferenceCardItem(
          arabic: hadith.text,
          translations: _flattenTranslations(hadith.translations),
          referenceLabel: refLabel,
        ),
      );
    }

    return items;
  }

  static Map<String, String> _flattenTranslations(
      Map<String, Map<String, String>> translations) {
    return {
      'en': translations['en']?['default'] ?? '',
      'ur': translations['ur']?['default'] ?? '',
    };
  }

  static String _pickSurahName(
      Map<String, String> surahName, String languageCode) {
    final order = <String>[];
    if (languageCode == 'ar') {
      order.addAll(['ar', 'en', 'meaning']);
    } else if (languageCode == 'en') {
      order.addAll(['en', 'ar', 'meaning']);
    } else {
      order.addAll(['ar', 'en', 'meaning']);
    }

    for (final key in order) {
      final value = surahName[key];
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  static String _pickBookName(
      Map<String, String> bookName, String languageCode) {
    if (languageCode == 'ur') {
      return bookName['ur'] ?? bookName['en'] ?? '';
    }
    if (languageCode == 'en') {
      return bookName['en'] ?? bookName['ur'] ?? '';
    }
    return bookName['en'] ?? bookName['ur'] ?? '';
  }

  static String _formatQuranReference(
      String surahName, int surahNumber, int ayahNumber) {
    final numberPart = (surahNumber > 0 && ayahNumber > 0)
        ? '$surahNumber:$ayahNumber'
        : surahNumber > 0
            ? '$surahNumber'
            : '';

    if (surahName.isNotEmpty && numberPart.isNotEmpty) {
      return '$surahName $numberPart';
    }
    if (surahName.isNotEmpty) {
      return surahName;
    }
    return numberPart;
  }

  static String _formatHadithReference(String bookName, int hadithNumber) {
    final numberPart = hadithNumber > 0 ? hadithNumber.toString() : '';
    if (bookName.isNotEmpty && numberPart.isNotEmpty) {
      return '$bookName $numberPart';
    }
    if (bookName.isNotEmpty) {
      return bookName;
    }
    if (numberPart.isNotEmpty) {
      return 'Hadith $numberPart';
    }
    return '';
  }
}

class _ReferenceAyahHadithCard extends StatefulWidget {
  final List<_ReferenceCardItem> items;
  final Color borderColor;
  final double height;
  final double width;

  const _ReferenceAyahHadithCard({
    required this.items,
    required this.borderColor,
    required this.height,
    required this.width,
  });

  @override
  State<_ReferenceAyahHadithCard> createState() =>
      _ReferenceAyahHadithCardState();
}

class _ReferenceAyahHadithCardState extends State<_ReferenceAyahHadithCard>
    with SingleTickerProviderStateMixin {
  static const _normalDisplayDuration = Duration(seconds: 10);
  static const _topPauseDuration = Duration(seconds: 3);
  static const _bottomPauseDuration = Duration(seconds: 3);
  static const _contentPadding = EdgeInsets.fromLTRB(16, 20, 16, 16);
  static const double _scrollPixelsPerSecond = 20;
  static const double _overflowTolerance = 0.5;
  static const int _maxScrollAdjustmentPasses = 5;

  late final AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();

  int _currentIndex = 0;
  int _cycleGeneration = 0;
  int? _activeLayoutSignature;
  int? _pendingLayoutSignature;
  Timer? _delayTimer;
  Completer<void>? _delayCompleter;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-1.5, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant _ReferenceAyahHadithCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_haveSameItems(oldWidget.items, widget.items)) {
      _currentIndex = 0;
      _cancelActiveCycle();
    } else if (_currentIndex >= widget.items.length) {
      _currentIndex = 0;
      _cancelActiveCycle();
    }
  }

  @override
  void dispose() {
    _cycleGeneration++;
    _cancelPendingDelay();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _cancelActiveCycle() {
    _cycleGeneration++;
    _cancelPendingDelay();
    _activeLayoutSignature = null;
    _pendingLayoutSignature = null;
    _slideController.stop();
    _slideController.reset();
    _jumpScrollToTop();
  }

  bool _haveSameItems(
    List<_ReferenceCardItem> previous,
    List<_ReferenceCardItem> current,
  ) {
    if (previous.length != current.length) {
      return false;
    }

    for (var index = 0; index < previous.length; index++) {
      final oldItem = previous[index];
      final newItem = current[index];
      if (oldItem.arabic != newItem.arabic ||
          oldItem.referenceLabel != newItem.referenceLabel ||
          oldItem.translations.length != newItem.translations.length) {
        return false;
      }
      for (final entry in oldItem.translations.entries) {
        if (newItem.translations[entry.key] != entry.value) {
          return false;
        }
      }
    }
    return true;
  }

  void _scheduleDisplayCycle(_ReferenceLayoutMetrics metrics) {
    if (_activeLayoutSignature == metrics.signature ||
        _pendingLayoutSignature == metrics.signature) {
      return;
    }

    _pendingLayoutSignature = metrics.signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _pendingLayoutSignature != metrics.signature ||
          _currentIndex != metrics.itemIndex) {
        return;
      }

      _pendingLayoutSignature = null;
      _startDisplayCycle(metrics);
    });
  }

  void _startDisplayCycle(_ReferenceLayoutMetrics metrics) {
    final generation = ++_cycleGeneration;
    _cancelPendingDelay();
    _activeLayoutSignature = metrics.signature;
    _slideController.stop();
    _slideController.reset();
    _jumpScrollToTop();
    unawaited(_runDisplayCycle(metrics, generation));
  }

  Future<void> _runDisplayCycle(
    _ReferenceLayoutMetrics metrics,
    int generation,
  ) async {
    var scrollDistance = _actualScrollDistance(metrics.estimatedScrollDistance);
    final initiallyOverflows =
        metrics.isOverflowing || scrollDistance > _overflowTolerance;

    if (initiallyOverflows) {
      if (!await _waitForCycle(
        _topPauseDuration,
        metrics,
        generation,
      )) {
        return;
      }

      scrollDistance = _actualScrollDistance(metrics.estimatedScrollDistance);
      if (scrollDistance > _overflowTolerance &&
          !await _animateVerticalScroll(
            scrollDistance,
            metrics,
            generation,
          )) {
        return;
      }

      if (!await _waitForCycle(
        _bottomPauseDuration,
        metrics,
        generation,
      )) {
        return;
      }
    } else {
      if (!await _waitForCycle(
        _normalDisplayDuration,
        metrics,
        generation,
      )) {
        return;
      }

      // A late font/layout update can make previously fitting text overflow.
      // Recheck the actual scroll extent before allowing the horizontal slide.
      scrollDistance = _actualScrollDistance(metrics.estimatedScrollDistance);
      if (scrollDistance > _overflowTolerance) {
        if (!await _animateVerticalScroll(
          scrollDistance,
          metrics,
          generation,
        )) {
          return;
        }
        if (!await _waitForCycle(
          _bottomPauseDuration,
          metrics,
          generation,
        )) {
          return;
        }
      }
    }

    if (!_isCycleCurrent(metrics, generation) || widget.items.length <= 1) {
      return;
    }

    try {
      await _slideController.forward(from: 0).orCancel;
    } on TickerCanceled {
      return;
    }

    if (!_isCycleCurrent(metrics, generation)) {
      return;
    }

    _jumpScrollToTop();
    _slideController.reset();
    _activeLayoutSignature = null;
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.items.length;
    });
  }

  Future<bool> _waitForCycle(
    Duration duration,
    _ReferenceLayoutMetrics metrics,
    int generation,
  ) async {
    _cancelPendingDelay();
    final completer = Completer<void>();
    _delayCompleter = completer;
    _delayTimer = Timer(duration, () {
      if (identical(_delayCompleter, completer)) {
        _delayCompleter = null;
        _delayTimer = null;
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    await completer.future;
    return _isCycleCurrent(metrics, generation);
  }

  void _cancelPendingDelay() {
    _delayTimer?.cancel();
    _delayTimer = null;
    final completer = _delayCompleter;
    _delayCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  Future<bool> _animateVerticalScroll(
    double distance,
    _ReferenceLayoutMetrics metrics,
    int generation,
  ) async {
    if (!_isCycleCurrent(metrics, generation) ||
        !_scrollController.hasClients) {
      return false;
    }

    var remainingDistance = distance;
    var adjustmentPass = 0;
    while (remainingDistance > _overflowTolerance &&
        adjustmentPass < _maxScrollAdjustmentPasses) {
      adjustmentPass++;
      if (!_isCycleCurrent(metrics, generation) ||
          !_scrollController.hasClients) {
        return false;
      }

      final position = _scrollController.positions.last;
      final targetOffset = position.maxScrollExtent;
      remainingDistance = targetOffset - position.pixels;
      if (remainingDistance <= _overflowTolerance) {
        return true;
      }

      final durationMilliseconds = math.max(
        800,
        (remainingDistance / _scrollPixelsPerSecond * 1000).round(),
      );

      try {
        await _scrollController.animateTo(
          targetOffset,
          duration: Duration(milliseconds: durationMilliseconds),
          curve: Curves.linear,
        );
      } catch (_) {
        return false;
      }

      if (!_isCycleCurrent(metrics, generation)) {
        return false;
      }
      final updatedPosition = _scrollController.positions.last;
      remainingDistance =
          updatedPosition.maxScrollExtent - updatedPosition.pixels;
    }
    return remainingDistance <= _overflowTolerance &&
        _isCycleCurrent(metrics, generation);
  }

  bool _isCycleCurrent(
    _ReferenceLayoutMetrics metrics,
    int generation,
  ) {
    return mounted &&
        generation == _cycleGeneration &&
        _activeLayoutSignature == metrics.signature &&
        _currentIndex == metrics.itemIndex;
  }

  double _actualScrollDistance(double fallback) {
    if (!_scrollController.hasClients) {
      return fallback;
    }
    return _scrollController.positions.last.maxScrollExtent;
  }

  void _jumpScrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentItem = widget.items[_currentIndex];
    final referenceLanguageCode =
        AppLanguageHelper.referenceAyahHadithLanguageCode();
    final isArabic = referenceLanguageCode == 'ar';
    final isUrdu = referenceLanguageCode == 'ur';
    final isRtl = isArabic || isUrdu;
    final mainText = isArabic
        ? currentItem.arabic
        : _pickTranslation(currentItem.translations, referenceLanguageCode);
    final textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final mainTextStyle = isArabic
        ? GoogleFonts.amiri(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1.7,
          )
        : isUrdu
            ? GoogleFonts.notoNastaliqUrdu(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                height: 1.9,
              )
            : GoogleFonts.poppins(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                height: 1.6,
              );
    final referenceTextStyle = isArabic
        ? GoogleFonts.amiri(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            height: 1.4,
          )
        : isUrdu
            ? GoogleFonts.notoNastaliqUrdu(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                height: 1.4,
              )
            : GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                height: 1.4,
              );
    final textScaler = MediaQuery.textScalerOf(context);
    final locale = Localizations.maybeLocaleOf(context);

    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.borderColor,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRect(
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: _contentPadding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.hasBoundedWidth
                    ? constraints.maxWidth
                    : math.max(0.0, widget.width - _contentPadding.horizontal);
                final availableHeight = constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : math.max(0.0, widget.height - _contentPadding.vertical);
                final mainTextHeight = _measureTextHeight(
                  text: mainText,
                  style: mainTextStyle,
                  direction: textDirection,
                  textScaler: textScaler,
                  locale: locale,
                  maxWidth: availableWidth,
                );
                final referenceTextHeight = currentItem.referenceLabel.isEmpty
                    ? 0.0
                    : _measureTextHeight(
                        text: currentItem.referenceLabel,
                        style: referenceTextStyle,
                        direction: textDirection,
                        textScaler: textScaler,
                        locale: locale,
                        maxWidth: availableWidth,
                      );
                final measuredContentHeight = mainTextHeight +
                    (currentItem.referenceLabel.isEmpty
                        ? 0.0
                        : 12.0 + referenceTextHeight);
                final estimatedScrollDistance = math.max(
                  0.0,
                  measuredContentHeight - availableHeight,
                );
                final metrics = _ReferenceLayoutMetrics(
                  itemIndex: _currentIndex,
                  isOverflowing: estimatedScrollDistance > _overflowTolerance,
                  estimatedScrollDistance: estimatedScrollDistance,
                  signature: Object.hash(
                    _currentIndex,
                    mainText,
                    currentItem.referenceLabel,
                    referenceLanguageCode,
                    availableWidth.toStringAsFixed(2),
                    availableHeight.toStringAsFixed(2),
                    measuredContentHeight.toStringAsFixed(2),
                    textScaler.scale(mainTextStyle.fontSize ?? 14),
                    textScaler.scale(referenceTextStyle.fontSize ?? 14),
                    locale?.toLanguageTag(),
                  ),
                );
                _scheduleDisplayCycle(metrics);

                return SingleChildScrollView(
                  key: ValueKey(metrics.signature),
                  controller: _scrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  clipBehavior: Clip.hardEdge,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: availableHeight),
                    child: Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              mainText,
                              textAlign: TextAlign.center,
                              textDirection: textDirection,
                              textScaler: textScaler,
                              locale: locale,
                              style: mainTextStyle,
                            ),
                            if (currentItem.referenceLabel.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                currentItem.referenceLabel,
                                textAlign: TextAlign.center,
                                textDirection: textDirection,
                                textScaler: textScaler,
                                locale: locale,
                                style: referenceTextStyle,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _pickTranslation(
      Map<String, String> translations, String languageCode) {
    final primary = translations[languageCode] ?? '';
    if (primary.isNotEmpty) {
      return primary;
    }
    if (languageCode == 'ur') {
      return translations['en'] ?? '';
    }
    if (languageCode == 'en') {
      return translations['ur'] ?? '';
    }
    return translations['en'] ?? translations['ur'] ?? '';
  }

  double _measureTextHeight({
    required String text,
    required TextStyle style,
    required TextDirection direction,
    required TextScaler textScaler,
    required Locale? locale,
    required double maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: direction,
      textScaler: textScaler,
      locale: locale,
      textWidthBasis: TextWidthBasis.parent,
    )..layout(maxWidth: maxWidth);
    final height = painter.height;
    painter.dispose();
    return height;
  }
}

class _ReferenceLayoutMetrics {
  final int itemIndex;
  final bool isOverflowing;
  final double estimatedScrollDistance;
  final int signature;

  const _ReferenceLayoutMetrics({
    required this.itemIndex,
    required this.isOverflowing,
    required this.estimatedScrollDistance,
    required this.signature,
  });
}

import 'dart:async';
import 'dart:math' as math;
import 'package:ecommerce_app/features/islamic_prayer/controllers/prayer_times_controller.dart';
import 'package:ecommerce_app/features/islamic_prayer/models/prayer_times_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final controller = Get.put(PrayerTimesController());
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.applyDefaultMadhab();
    });
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      controller.fetchPrayerTimes();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.prayerTimes.value == null) {
                  return _buildShimmer();
                }
                if (controller.hasError.value &&
                    controller.prayerTimes.value == null) {
                  return _buildError();
                }
                return _buildContent();
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF2EA77D),
            Color(0xFF167553),
            Color(0xFF064833),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _PrayerPatternPainter(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Prayer Times',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    const base = Color(0xFFEAF1EF);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
      children: List.generate(
          6,
          (_) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              )),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Color(0xFF087152),
              ),
            ),
            const SizedBox(height: PSizes.lg),
            const Text(
              'Unable to load prayer times',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF082F28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: PColors.textSecondary),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: controller.fetchPrayerTimes,
              style: ElevatedButton.styleFrom(
                backgroundColor: PColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final pt = controller.prayerTimes.value;
    if (pt == null) return const SizedBox.shrink();

    const cardBg = Colors.white;
    const textCol = Color(0xFF101828);

    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _PrayerLayoutMetrics.fromConstraints(constraints);

        return Padding(
          padding: EdgeInsets.only(
            top: metrics.contentTop,
            bottom: metrics.contentBottom,
          ),
          child: Column(
            children: [
              _buildCountdownCard(pt, metrics),
              Expanded(
                child: _buildPrayerList(pt, cardBg, textCol, metrics),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdownCard(
    PrayerTimesResponse pt,
    _PrayerLayoutMetrics metrics,
  ) {
    final zawalTime = _shiftPrayerTime(
      pt.dhuhr,
      const Duration(minutes: -10),
    );
    final currentPrayer = _effectiveCurrentPrayer(pt);
    final nextPrayer = controller.displayNextPrayer(pt);
    final nextPrayerTime = controller.displayNextPrayerTime(pt);

    return SizedBox(
      height: metrics.heroHeight,
      width: double.infinity,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: metrics.heroMargin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(metrics.heroRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF064833).withValues(alpha: 0.20),
              blurRadius: metrics.heroElevation,
              offset: Offset(0, metrics.heroElevation * 0.45),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(metrics.heroRadius),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              metrics.heroPaddingX,
              metrics.heroPaddingTop,
              metrics.heroPaddingX,
              metrics.heroPaddingBottom,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF167F59),
                  Color(0xFF075C42),
                  Color(0xFF033F30),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PrayerPatternPainter(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      child: Column(
                        children: [
                          SizedBox(
                            height: metrics.solarRowHeight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildSolarMarker(
                                  icon: Icons.wb_twilight_rounded,
                                  label: 'Sunrise',
                                  time: pt.sunrise,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  textAlign: TextAlign.center,
                                  metrics: metrics,
                                ),
                                SizedBox(width: metrics.solarMarkerGap),
                                _buildSolarMarker(
                                  icon: Icons.wb_sunny_outlined,
                                  label: 'Zawal',
                                  time: zawalTime,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  textAlign: TextAlign.center,
                                  metrics: metrics,
                                ),
                                SizedBox(width: metrics.solarMarkerGap),
                                _buildSolarMarker(
                                  icon: Icons.nights_stay_outlined,
                                  label: 'Sunset',
                                  time: pt.maghrib,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  textAlign: TextAlign.center,
                                  metrics: metrics,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: metrics.heroSectionGap),
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.02),
                                  Colors.white.withValues(alpha: 0.22),
                                  Colors.white.withValues(alpha: 0.02),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: metrics.heroMiddleGap),
                          SizedBox(
                            height: metrics.currentPrayerRowHeight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: metrics.heroSideSlotWidth,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: metrics.nextIconBox,
                                      height: metrics.nextIconBox,
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                            metrics.nextIconRadius),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.18),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.schedule_rounded,
                                        color: Colors.white,
                                        size: metrics.nextIconSize,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          currentPrayer.isNotEmpty
                                              ? 'Current: $currentPrayer'
                                              : 'Next prayer',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: const Color(0xFFBDE3B2)
                                                .withValues(alpha: 0.92),
                                            fontSize: metrics.nextLabelFont,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: metrics.nextLabelGap),
                                        Text(
                                          nextPrayer,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: metrics.nextPrayerFont,
                                            fontWeight: FontWeight.w700,
                                            height: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: metrics.heroSideSlotWidth,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: metrics.timePillHorizontal,
                                        vertical: metrics.timePillVertical,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(
                                            metrics.timePillRadius),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.22),
                                        ),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          _safeTime(nextPrayerTime),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: metrics.timePillFont,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: metrics.countdownTopGap),
                          Expanded(
                            child: Center(
                              child: Obx(() {
                                if (controller.countdown.value.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _CountdownText(
                                        value: controller.countdown.value,
                                        fontSize: metrics.countdownFont,
                                      ),
                                      SizedBox(height: metrics.untilGap),
                                      Text(
                                        'Until $nextPrayer',
                                        style: TextStyle(
                                          color: const Color(0xFFBDE3B2)
                                              .withValues(alpha: 0.92),
                                          fontSize: metrics.untilFont,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSolarMarker({
    required IconData icon,
    required String label,
    required String time,
    required CrossAxisAlignment crossAxisAlignment,
    required TextAlign textAlign,
    required _PrayerLayoutMetrics metrics,
  }) {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: metrics.solarTileHorizontalPadding,
          vertical: metrics.solarTileVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(metrics.solarTileRadius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Container(
                width: metrics.solarIconBox,
                height: metrics.solarIconBox,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(metrics.solarIconRadius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFFE49A),
                  size: metrics.solarIconSize,
                ),
              ),
              SizedBox(height: metrics.solarLabelGap),
              Text(
                label,
                textAlign: textAlign,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: metrics.solarLabelFont,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
              SizedBox(height: metrics.solarTimeGap),
              Text(
                _safeTime(time),
                textAlign: textAlign,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ).copyWith(fontSize: metrics.solarTimeFont),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _safeTime(String time) {
    final trimmedTime = time.trim();
    return trimmedTime.isEmpty ? '--:--' : trimmedTime;
  }

  String _effectiveCurrentPrayer(PrayerTimesResponse pt) {
    final apiCurrentPrayer = controller.displayCurrentPrayer(pt);
    if (pt.prayerList.any((prayer) => prayer.name == apiCurrentPrayer)) {
      return apiCurrentPrayer;
    }

    final now = DateTime.now();
    final prayerStarts = pt.prayerList
        .map((prayer) {
          final parsed = _parseDisplayTime(prayer.time);
          if (parsed == null) return null;
          return MapEntry(
            prayer.name,
            DateTime(
              now.year,
              now.month,
              now.day,
              parsed.dateTime.hour,
              parsed.dateTime.minute,
            ),
          );
        })
        .whereType<MapEntry<String, DateTime>>()
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    if (prayerStarts.isEmpty) return '';

    var currentPrayer = prayerStarts.last.key;
    for (final prayer in prayerStarts) {
      if (!now.isBefore(prayer.value)) {
        currentPrayer = prayer.key;
      }
    }

    return currentPrayer;
  }

  String _shiftPrayerTime(String time, Duration offset) {
    final parsed = _parseDisplayTime(time);
    if (parsed == null) return _safeTime(time);

    final shiftedTime = parsed.dateTime.add(offset);
    return parsed.hasMeridiem
        ? _format12Hour(shiftedTime)
        : _format24Hour(shiftedTime);
  }

  _ParsedPrayerTime? _parseDisplayTime(String time) {
    final cleanedTime = time.trim().toUpperCase();
    final match = RegExp(r'(\d{1,2})\s*:\s*(\d{2})').firstMatch(cleanedTime);
    if (match == null) return null;

    var hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null) return null;

    final isAM = RegExp(r'A\.?M\.?').hasMatch(cleanedTime);
    final isPM = RegExp(r'P\.?M\.?').hasMatch(cleanedTime);
    final hasMeridiem = isAM || isPM;

    if (hasMeridiem) {
      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
    }

    return _ParsedPrayerTime(
      DateTime(2000, 1, 1, hour, minute),
      hasMeridiem: hasMeridiem,
    );
  }

  String _format12Hour(DateTime time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    var hour = time.hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _format24Hour(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMadhabSelector(_PrayerLayoutMetrics metrics) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => _MadhabChip(
              label: 'SHAFI',
              selected: controller.selectedMadhab.value == 'standard',
              onTap: () => controller.setMadhab('standard'),
              metrics: metrics,
            )),
        SizedBox(width: metrics.chipGap),
        Obx(() => _MadhabChip(
              label: 'HANAFI',
              selected: controller.selectedMadhab.value == 'hanafi',
              onTap: () => controller.setMadhab('hanafi'),
              metrics: metrics,
            )),
        if (controller.isLoading.value) ...[
          SizedBox(width: metrics.chipGap),
          SizedBox(
            width: metrics.loadingSize,
            height: metrics.loadingSize,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: PColors.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScheduleHeader(
    PrayerTimesResponse pt,
    _PrayerLayoutMetrics metrics,
  ) {
    final title = Text(
      'Today\'s Prayer Schedule',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: metrics.scheduleTitleFont,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF062B24),
      ),
    );

    final count = Text(
      '${pt.prayerList.length} prayers',
      maxLines: 1,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: metrics.scheduleCountFont,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6F7479),
      ),
    );

    if (metrics.inlineScheduleControls) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: title),
                SizedBox(width: metrics.scheduleCountGap),
                count,
              ],
            ),
          ),
          SizedBox(width: metrics.scheduleControlGap),
          _buildMadhabSelector(metrics),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: title),
            SizedBox(width: metrics.scheduleCountGap),
            count,
          ],
        ),
        SizedBox(height: metrics.selectorHeaderGap),
        Align(
          alignment: Alignment.centerRight,
          child: _buildMadhabSelector(metrics),
        ),
      ],
    );
  }

  Widget _buildPrayerList(
    PrayerTimesResponse pt,
    Color cardBg,
    Color textCol,
    _PrayerLayoutMetrics metrics,
  ) {
    final prayers = pt.prayerList;
    final currentPrayer = _effectiveCurrentPrayer(pt);
    final nextPrayer = controller.displayNextPrayer(pt);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: metrics.listHorizontalPadding),
      child: Column(
        children: [
          SizedBox(height: metrics.scheduleTopGap),
          SizedBox(
            height: metrics.scheduleToolbarHeight,
            child: _buildScheduleHeader(pt, metrics),
          ),
          SizedBox(height: metrics.scheduleGap),
          Expanded(
            child: Column(
              children: List.generate(prayers.length, (i) {
                final prayer = prayers[i];
                final isCurrent = prayer.name == currentPrayer;
                final isNext = prayer.name == nextPrayer;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i == prayers.length - 1 ? 0 : metrics.rowGap,
                    ),
                    child: _buildPrayerRow(
                      prayer,
                      isCurrent,
                      isNext,
                      cardBg,
                      textCol,
                      metrics,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRow(
    PrayerEntry prayer,
    bool isCurrent,
    bool isNext,
    Color cardBg,
    Color textCol,
    _PrayerLayoutMetrics metrics,
  ) {
    final rowBg = isCurrent
        ? const Color(0xFFEAF7F2)
        : isNext
            ? const Color(0xFFFFFFFF)
            : cardBg;
    final rowBorder = isCurrent ? const Color(0xFF24956F) : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rowBorder, width: isCurrent ? 1.4 : 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF072F26).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: metrics.rowAccentWidth,
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFF087A5A)
                    : isNext
                        ? const Color(0xFF2DB78D)
                        : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: metrics.rowHorizontalPadding,
                ),
                child: Row(
                  children: [
                    _prayerIcon(prayer.name, isCurrent, metrics),
                    SizedBox(width: metrics.rowIconGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            prayer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isCurrent || isNext
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: metrics.rowTitleFont,
                              color:
                                  isCurrent ? const Color(0xFF087A5A) : textCol,
                            ),
                          ),
                          if (isCurrent || isNext)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                isCurrent ? 'Current prayer' : 'Upcoming',
                                style: TextStyle(
                                  fontSize: metrics.rowSubtitleFont,
                                  color: isCurrent
                                      ? const Color(0xFF087A5A)
                                      : const Color(0xFF168861),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: metrics.rowTimeWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              prayer.time,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: metrics.rowTimeFont,
                                color: isCurrent
                                    ? const Color(0xFF087A5A)
                                    : textCol,
                              ),
                            ),
                          ),
                          if (isCurrent && metrics.showCurrentBadge)
                            _CurrentBadge(metrics: metrics),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prayerIcon(
    String name,
    bool isCurrent,
    _PrayerLayoutMetrics metrics,
  ) {
    IconData icon;
    Color color;
    Color bg;

    if (isCurrent) {
      color = const Color(0xFF087A5A);
      bg = const Color(0xFFD7EFE7);
    } else {
      color = const Color(0xFF168861);
      bg = const Color(0xFFEAF3F0);
    }

    switch (name) {
      case 'Fajr':
        icon = Icons.wb_twilight;
        break;
      case 'Dhuhr':
        icon = Icons.wb_cloudy;
        break;
      case 'Asr':
        icon = Icons.cloud;
        break;
      case 'Maghrib':
        icon = Icons.nights_stay;
        break;
      case 'Isha':
        icon = Icons.nightlight_round;
        break;
      default:
        icon = Icons.access_time;
    }

    return Container(
      width: metrics.rowIconBox,
      height: metrics.rowIconBox,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: metrics.rowIconSize),
    );
  }
}

class _PrayerLayoutMetrics {
  const _PrayerLayoutMetrics({
    required this.contentTop,
    required this.contentBottom,
    required this.heroHeight,
    required this.heroMargin,
    required this.heroRadius,
    required this.heroElevation,
    required this.heroPaddingX,
    required this.heroPaddingTop,
    required this.heroPaddingBottom,
    required this.heroSectionGap,
    required this.heroMiddleGap,
    required this.solarRowHeight,
    required this.solarMarkerGap,
    required this.solarTileHorizontalPadding,
    required this.solarTileVerticalPadding,
    required this.solarTileRadius,
    required this.solarIconBox,
    required this.solarIconRadius,
    required this.solarIconSize,
    required this.solarLabelGap,
    required this.solarLabelFont,
    required this.solarTimeGap,
    required this.solarTimeFont,
    required this.nextIconBox,
    required this.nextIconRadius,
    required this.nextIconSize,
    required this.currentPrayerRowHeight,
    required this.heroSideSlotWidth,
    required this.nextLabelFont,
    required this.nextLabelGap,
    required this.nextPrayerFont,
    required this.timePillHorizontal,
    required this.timePillVertical,
    required this.timePillRadius,
    required this.timePillFont,
    required this.countdownTopGap,
    required this.countdownFont,
    required this.untilGap,
    required this.untilFont,
    required this.chipMinWidth,
    required this.chipHeight,
    required this.chipGap,
    required this.chipHorizontalPadding,
    required this.chipFont,
    required this.loadingSize,
    required this.listHorizontalPadding,
    required this.scheduleTopGap,
    required this.scheduleToolbarHeight,
    required this.scheduleTitleFont,
    required this.scheduleCountFont,
    required this.scheduleCountGap,
    required this.scheduleControlGap,
    required this.selectorHeaderGap,
    required this.inlineScheduleControls,
    required this.scheduleGap,
    required this.rowGap,
    required this.rowAccentWidth,
    required this.rowHorizontalPadding,
    required this.rowIconGap,
    required this.rowIconBox,
    required this.rowIconSize,
    required this.rowTitleFont,
    required this.rowSubtitleFont,
    required this.rowTimeFont,
    required this.rowTimeWidth,
    required this.showCurrentBadge,
    required this.badgeTopGap,
    required this.badgeHorizontalPadding,
    required this.badgeVerticalPadding,
    required this.badgeFont,
  });

  final double contentTop;
  final double contentBottom;
  final double heroHeight;
  final double heroMargin;
  final double heroRadius;
  final double heroElevation;
  final double heroPaddingX;
  final double heroPaddingTop;
  final double heroPaddingBottom;
  final double heroSectionGap;
  final double heroMiddleGap;
  final double solarRowHeight;
  final double solarMarkerGap;
  final double solarTileHorizontalPadding;
  final double solarTileVerticalPadding;
  final double solarTileRadius;
  final double solarIconBox;
  final double solarIconRadius;
  final double solarIconSize;
  final double solarLabelGap;
  final double solarLabelFont;
  final double solarTimeGap;
  final double solarTimeFont;
  final double nextIconBox;
  final double nextIconRadius;
  final double nextIconSize;
  final double currentPrayerRowHeight;
  final double heroSideSlotWidth;
  final double nextLabelFont;
  final double nextLabelGap;
  final double nextPrayerFont;
  final double timePillHorizontal;
  final double timePillVertical;
  final double timePillRadius;
  final double timePillFont;
  final double countdownTopGap;
  final double countdownFont;
  final double untilGap;
  final double untilFont;
  final double chipMinWidth;
  final double chipHeight;
  final double chipGap;
  final double chipHorizontalPadding;
  final double chipFont;
  final double loadingSize;
  final double listHorizontalPadding;
  final double scheduleTopGap;
  final double scheduleToolbarHeight;
  final double scheduleTitleFont;
  final double scheduleCountFont;
  final double scheduleCountGap;
  final double scheduleControlGap;
  final double selectorHeaderGap;
  final bool inlineScheduleControls;
  final double scheduleGap;
  final double rowGap;
  final double rowAccentWidth;
  final double rowHorizontalPadding;
  final double rowIconGap;
  final double rowIconBox;
  final double rowIconSize;
  final double rowTitleFont;
  final double rowSubtitleFont;
  final double rowTimeFont;
  final double rowTimeWidth;
  final bool showCurrentBadge;
  final double badgeTopGap;
  final double badgeHorizontalPadding;
  final double badgeVerticalPadding;
  final double badgeFont;

  factory _PrayerLayoutMetrics.fromConstraints(BoxConstraints constraints) {
    final height =
        constraints.maxHeight.isFinite ? constraints.maxHeight : 620.0;
    final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
    final compact = height < 650 || width < 340;
    final scale = math.min(width / 390, height / 720).clamp(0.64, 1.0);

    final contentTop = compact ? 8.0 : (14 * scale);
    final contentBottom = compact ? 6.0 : (10 * scale);
    var heroHeight = (height * (compact ? 0.355 : 0.38))
        .clamp(178.0, compact ? 208.0 : 286.0);

    final inlineScheduleControls = width >= 460;
    final chipHeight = (36 * scale).clamp(26.0, 34.0);
    final selectorHeaderGap = (5 * scale).clamp(3.0, 6.0);
    final scheduleTopGap = (9 * scale).clamp(6.0, 10.0);
    final scheduleHeaderHeight = (22 * scale).clamp(18.0, 24.0);
    final scheduleToolbarHeight = inlineScheduleControls
        ? math.max(scheduleHeaderHeight, chipHeight)
        : scheduleHeaderHeight +
            selectorHeaderGap +
            chipHeight +
            (compact ? 5.0 : 3.0);
    final scheduleGap = (7 * scale).clamp(5.0, 7.0);
    final rowGap = (10 * scale).clamp(6.0, 10.0);

    double rowHeightFor(double cardHeight) {
      final availableRowsHeight = height -
          contentTop -
          contentBottom -
          cardHeight -
          scheduleTopGap -
          scheduleToolbarHeight -
          scheduleGap -
          (rowGap * 4);
      return availableRowsHeight / 5;
    }

    var rowHeight = rowHeightFor(heroHeight);
    if (rowHeight < 43) {
      heroHeight = math.max(164.0, heroHeight - ((43 - rowHeight) * 5));
      rowHeight = rowHeightFor(heroHeight);
    }
    rowHeight = rowHeight.clamp(40.0, compact ? 58.0 : 72.0);

    final rowIconBox = (rowHeight * 0.56).clamp(27.0, 48.0);

    return _PrayerLayoutMetrics(
      contentTop: contentTop,
      contentBottom: contentBottom,
      heroHeight: heroHeight,
      heroMargin: (16 * scale).clamp(10.0, 16.0),
      heroRadius: (24 * scale).clamp(18.0, 24.0),
      heroElevation: compact ? 6 : 14,
      heroPaddingX: (16 * scale).clamp(10.0, 18.0),
      heroPaddingTop: compact
          ? (10 * scale).clamp(6.0, 9.0)
          : (14 * scale).clamp(8.0, 18.0),
      heroPaddingBottom: compact
          ? (18 * scale).clamp(12.0, 16.0)
          : (34 * scale).clamp(14.0, 42.0),
      heroSectionGap:
          compact ? (6 * scale).clamp(3.0, 5.0) : (12 * scale).clamp(5.0, 18.0),
      heroMiddleGap:
          compact ? (6 * scale).clamp(3.0, 5.0) : (12 * scale).clamp(5.0, 16.0),
      solarRowHeight: compact
          ? (70 * scale).clamp(58.0, 68.0)
          : (82 * scale).clamp(66.0, 84.0),
      solarMarkerGap: (8 * scale).clamp(5.0, 10.0),
      solarTileHorizontalPadding:
          compact ? (5 * scale).clamp(3.0, 5.0) : (9 * scale).clamp(5.0, 11.0),
      solarTileVerticalPadding:
          compact ? (4 * scale).clamp(3.0, 4.5) : (6 * scale).clamp(4.0, 7.0),
      solarTileRadius: (16 * scale).clamp(11.0, 18.0),
      solarIconBox: compact
          ? (34 * scale).clamp(25.0, 32.0)
          : (42 * scale).clamp(30.0, 44.0),
      solarIconRadius: compact
          ? (12 * scale).clamp(8.0, 11.0)
          : (17 * scale).clamp(10.0, 20.0),
      solarIconSize: compact
          ? (19 * scale).clamp(13.0, 17.0)
          : (23 * scale).clamp(16.0, 24.0),
      solarLabelGap:
          compact ? (3 * scale).clamp(1.5, 3.0) : (5 * scale).clamp(2.0, 6.0),
      solarLabelFont: compact
          ? (12 * scale).clamp(8.5, 10.0)
          : (12 * scale).clamp(9.0, 13.0),
      solarTimeGap:
          compact ? (2 * scale).clamp(1.0, 2.0) : (4 * scale).clamp(1.0, 6.0),
      solarTimeFont: compact
          ? (14 * scale).clamp(10.0, 12.5)
          : (15 * scale).clamp(11.0, 16.0),
      nextIconBox: compact
          ? (30 * scale).clamp(22.0, 28.0)
          : (34 * scale).clamp(27.0, 36.0),
      nextIconRadius: compact
          ? (10 * scale).clamp(7.0, 10.0)
          : (14 * scale).clamp(9.0, 16.0),
      nextIconSize: compact
          ? (17 * scale).clamp(12.0, 15.0)
          : (19 * scale).clamp(14.0, 21.0),
      currentPrayerRowHeight: compact
          ? (38 * scale).clamp(30.0, 36.0)
          : (45 * scale).clamp(34.0, 46.0),
      heroSideSlotWidth: compact
          ? (70 * scale).clamp(54.0, 64.0)
          : (92 * scale).clamp(66.0, 106.0),
      nextLabelFont: compact
          ? (12 * scale).clamp(8.5, 10.0)
          : (13 * scale).clamp(9.5, 14.0),
      nextLabelGap: compact ? 0 : (2 * scale).clamp(0.0, 3.0),
      nextPrayerFont: compact
          ? (27 * scale).clamp(18.0, 22.0)
          : (27 * scale).clamp(20.0, 29.0),
      timePillHorizontal: compact
          ? (10 * scale).clamp(6.0, 9.0)
          : (15 * scale).clamp(8.0, 18.0),
      timePillVertical:
          compact ? (6 * scale).clamp(3.0, 5.0) : (10 * scale).clamp(4.0, 12.0),
      timePillRadius: compact
          ? (14 * scale).clamp(8.0, 12.0)
          : (18 * scale).clamp(10.0, 20.0),
      timePillFont: compact
          ? (13 * scale).clamp(9.5, 11.0)
          : (13 * scale).clamp(10.0, 14.0),
      countdownTopGap:
          compact ? (3 * scale).clamp(1.0, 3.0) : (10 * scale).clamp(2.0, 18.0),
      countdownFont: compact
          ? (50 * scale).clamp(34.0, 40.0)
          : (48 * scale).clamp(34.0, 52.0),
      untilGap:
          compact ? (3 * scale).clamp(1.0, 3.0) : (8 * scale).clamp(2.0, 12.0),
      untilFont: compact
          ? (12 * scale).clamp(8.5, 10.5)
          : (16 * scale).clamp(10.0, 20.0),
      chipMinWidth: (74 * scale).clamp(58.0, 80.0),
      chipHeight: chipHeight,
      chipGap: (7 * scale).clamp(5.0, 7.0),
      chipHorizontalPadding: (12 * scale).clamp(7.0, 13.0),
      chipFont: (13 * scale).clamp(10.0, 13.5),
      loadingSize: (16 * scale).clamp(12.0, 16.0),
      listHorizontalPadding: (20 * scale).clamp(16.0, 22.0),
      scheduleTopGap: scheduleTopGap,
      scheduleToolbarHeight: scheduleToolbarHeight,
      scheduleTitleFont: (17 * scale).clamp(13.0, 18.0),
      scheduleCountFont: (13 * scale).clamp(10.0, 14.0),
      scheduleCountGap: (8 * scale).clamp(6.0, 10.0),
      scheduleControlGap: (14 * scale).clamp(10.0, 16.0),
      selectorHeaderGap: selectorHeaderGap,
      inlineScheduleControls: inlineScheduleControls,
      scheduleGap: scheduleGap,
      rowGap: rowGap,
      rowAccentWidth: compact ? 3.0 : 5.0,
      rowHorizontalPadding: (16 * scale).clamp(10.0, 20.0),
      rowIconGap: (20 * scale).clamp(10.0, 24.0),
      rowIconBox: rowIconBox,
      rowIconSize: rowIconBox * 0.55,
      rowTitleFont: (rowHeight * 0.29).clamp(12.5, 20.0),
      rowSubtitleFont: (rowHeight * 0.20).clamp(8.5, 13.0),
      rowTimeFont: (rowHeight * 0.28).clamp(12.0, 19.0),
      rowTimeWidth: (82 * scale).clamp(68.0, 94.0),
      showCurrentBadge: rowHeight >= 49,
      badgeTopGap: (4 * scale).clamp(2.0, 5.0),
      badgeHorizontalPadding: (9 * scale).clamp(6.0, 10.0),
      badgeVerticalPadding: (3 * scale).clamp(1.5, 3.0),
      badgeFont: (9 * scale).clamp(7.0, 10.0),
    );
  }
}

class _ParsedPrayerTime {
  final DateTime dateTime;
  final bool hasMeridiem;

  const _ParsedPrayerTime(this.dateTime, {required this.hasMeridiem});
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge({required this.metrics});

  final _PrayerLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: metrics.badgeTopGap),
      padding: EdgeInsets.symmetric(
        horizontal: metrics.badgeHorizontalPadding,
        vertical: metrics.badgeVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF087A5A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'CURRENT',
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: Colors.white,
          fontSize: metrics.badgeFont,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          height: 1,
        ),
      ),
    );
  }
}

class _MadhabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final _PrayerLayoutMetrics metrics;

  const _MadhabChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(
          minWidth: metrics.chipMinWidth,
          minHeight: metrics.chipHeight,
        ),
        padding:
            EdgeInsets.symmetric(horizontal: metrics.chipHorizontalPadding),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF31B78D),
                    Color(0xFF087A5A),
                    Color(0xFF065842),
                  ],
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : const Color(0xFF168861).withValues(alpha: 0.80),
            width: 1.1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF087A5A).withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF087A5A),
              fontSize: metrics.chipFont,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownText extends StatelessWidget {
  const _CountdownText({
    required this.value,
    required this.fontSize,
  });

  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: value
            .split('')
            .map(
              (char) => TextSpan(
                text: char,
                style: TextStyle(
                  color: char == ':' ? const Color(0xFFFFE49A) : Colors.white,
                ),
              ),
            )
            .toList(),
      ),
      maxLines: 1,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1,
        letterSpacing: 1,
      ),
    );
  }
}

class _PrayerPatternPainter extends CustomPainter {
  const _PrayerPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const step = 48.0;
    for (double x = -step; x < size.width + step; x += step) {
      for (double y = -step; y < size.height + step; y += step) {
        final center = Offset(x, y);
        _drawRosette(canvas, center, step * 0.42, paint);
      }
    }
  }

  void _drawRosette(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = i * 0.78539816339;
      final dx = radius * 0.65 * math.cos(angle);
      final dy = radius * 0.65 * math.sin(angle);
      path
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(
          center.dx + dx,
          center.dy + dy,
          center.dx + radius * math.cos(angle + 0.39269908169),
          center.dy + radius * math.sin(angle + 0.39269908169),
        );
    }
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, radius * 0.18, paint);
  }

  @override
  bool shouldRepaint(covariant _PrayerPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

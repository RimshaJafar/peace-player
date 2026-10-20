import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/islamic_prayer/controllers/islamic_calendar_controller.dart';
import 'package:ecommerce_app/features/islamic_prayer/models/islamic_calendar_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  final controller = Get.put(IslamicCalendarController());

  static const _weekdayHeaders = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PAppBar(
        title: const Text(
          'Islamic Calendar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.calendar.value == null) {
          return _buildShimmer();
        }
        if (controller.hasError.value && controller.calendar.value == null) {
          return _buildError();
        }
        return _buildContent();
      }),
    );
  }

  Widget _buildShimmer() {
    final base = Colors.grey.shade200;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(
                7,
                (_) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                                color: base,
                                borderRadius: BorderRadius.circular(4))),
                      ),
                    )),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.95,
            ),
            itemCount: 35,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.all(2.5),
              child: Container(
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
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
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  size: 48, color: Colors.red),
            ),
            const SizedBox(height: PSizes.lg),
            const Text(
              'Unable to load calendar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
              onPressed: controller.fetchCalendar,
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
    final cal = controller.calendar.value;
    if (cal == null) return const SizedBox.shrink();

    const textCol = PColors.textPrimary;

    return RefreshIndicator(
      color: PColors.primary,
      onRefresh: controller.fetchCalendar,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildMonthHeader(cal),
            const SizedBox(height: 8),
            _buildWeekdayHeaders(),
            const SizedBox(height: 4),
            _buildDaysGrid(cal, textCol),
            if (cal.days.any((d) => d.islamicEvents.isNotEmpty))
              _buildEventsSection(cal, textCol),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(IslamicCalendarResponse cal) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF329070), Color(0xFF1C5D4E), Color(0xFF0F3D32)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: controller.goToPreviousMonth,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 30,
            ),
            splashRadius: 22,
            splashColor: Colors.white.withValues(alpha: 0.15),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${cal.hijriMonthName} ${cal.hijriYear}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(cal.gregorianStart)} - ${_formatDate(cal.gregorianEnd)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.goToNextMonth,
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 30,
            ),
            splashRadius: 22,
            splashColor: Colors.white.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _weekdayHeaders.map((day) {
          final isFriday = day == 'Fri';
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isFriday ? FontWeight.w700 : FontWeight.w500,
                  color: isFriday ? PColors.primary : PColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaysGrid(IslamicCalendarResponse cal, Color textCol) {
    final days = cal.days;
    if (days.isEmpty) return const SizedBox.shrink();

    final firstWeekday = _weekdayIndex(days.first.weekday);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
        ),
        itemCount: firstWeekday + days.length,
        itemBuilder: (ctx, index) {
          if (index < firstWeekday) return const SizedBox.shrink();
          final dayIndex = index - firstWeekday;
          if (dayIndex >= days.length) return const SizedBox.shrink();
          return _buildDayCell(days[dayIndex], textCol);
        },
      ),
    );
  }

  Widget _buildDayCell(CalendarDay day, Color textCol) {
    final isToday = _isToday(day.gregorianDate);
    final hasEvents = day.islamicEvents.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isToday
              ? PColors.primary
              : hasEvents
                  ? PColors.primary.withValues(alpha: 0.06)
                  : null,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? null
              : hasEvents
                  ? Border.all(color: PColors.primary.withValues(alpha: 0.15))
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.day.toString(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday ? Colors.white : textCol,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatGregorian(day.gregorianDate),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: isToday ? Colors.white70 : PColors.textSecondary,
              ),
            ),
            if (hasEvents)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isToday ? Colors.white : PColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection(IslamicCalendarResponse cal, Color textCol) {
    final eventDays =
        cal.days.where((d) => d.islamicEvents.isNotEmpty).toList();
    const cardBg = Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: PColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event_note_rounded,
                    color: PColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Islamic Events',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textCol,
                ),
              ),
              const Spacer(),
              Text(
                '${eventDays.length} days',
                style: TextStyle(
                  fontSize: 13,
                  color: PColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...eventDays.map((day) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: PColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.day.toString(),
                            style: const TextStyle(
                              color: PColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            cal.hijriMonthName.substring(0, 3),
                            style: TextStyle(
                              color: PColors.primary.withValues(alpha: 0.6),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: day.islamicEvents
                            .map((event) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: PColors.primary
                                              .withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          event,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: textCol,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  int _weekdayIndex(String weekday) {
    switch (weekday.toLowerCase()) {
      case 'monday':
        return 0;
      case 'tuesday':
        return 1;
      case 'wednesday':
        return 2;
      case 'thursday':
        return 3;
      case 'friday':
        return 4;
      case 'saturday':
        return 5;
      case 'sunday':
        return 6;
      default:
        return 0;
    }
  }

  bool _isToday(String gregorianDate) {
    try {
      final date = DateTime.parse(gregorianDate);
      final now = DateTime.now();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } catch (_) {
      return false;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatGregorian(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return date.day.toString();
    } catch (_) {
      return '';
    }
  }
}

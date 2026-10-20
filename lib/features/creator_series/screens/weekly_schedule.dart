import 'package:ecommerce_app/features/creator_series/controllers/series_controller.dart';
import 'package:ecommerce_app/features/creator_series/controllers/creator_series_controller.dart';
import 'package:ecommerce_app/common/controllers/external_service_controller.dart';
import 'package:ecommerce_app/features/creator_series/models/series_video_model.dart';
import 'package:ecommerce_app/features/creator_series/screens/videodetailscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';

class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  late final SeriesController _seriesController =
      Get.isRegistered<SeriesController>()
          ? Get.find<SeriesController>()
          : Get.put(SeriesController());
  late final CreatorSeriesController _creatorController =
      Get.isRegistered<CreatorSeriesController>()
          ? Get.find<CreatorSeriesController>()
          : Get.put(CreatorSeriesController());
  late final ExternalServiceController _externalController =
      Get.isRegistered<ExternalServiceController>()
          ? Get.find<ExternalServiceController>()
          : Get.put(ExternalServiceController());

  int selectedDay = 0;
  bool showAllSeries = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seriesController.fetchUpcomingSeries();
      _creatorController.fetchCreatorProfile();
      _externalController.fetchCountries();
    });
  }

  String? _resolveCreatorTimezone() {
    final profile = _creatorController.creatorProfile.value;
    if (profile == null || profile.country.trim().isEmpty) {
      return null;
    }

    final country =
        _externalController.getCountryByName(profile.country.trim());
    if (country == null || country.timezones.isEmpty) {
      return null;
    }

    return country.timezones.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          "Upcoming Videos",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        showBackArrow: true,
        gradient: PColors.linearGradient,
        centerTitle: true,
      ),
      body: Obx(
        () {
          final upcomingVideos = _seriesController.upcomingNext7Days.toList();
          final days = _buildScheduleDays(upcomingVideos);
          final activeDayIndex =
              selectedDay >= days.length ? days.length - 1 : selectedDay;
          final visibleVideos =
              showAllSeries ? upcomingVideos : upcomingVideos.take(3).toList();
          final String? timezoneLabel = _resolveCreatorTimezone();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Weekly Series',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatWeekRange(days),
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            color: Color(0xFF888888),
                          ),
                        ),
                        if (timezoneLabel != null)
                          Text(
                            'Timezone: $timezoneLabel',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 11,
                              color: Color(0xFF8A8A8A),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Day Selector
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: days.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      return DayCard(
                        label: day.label,
                        date: day.date,
                        dayName: day.name,
                        selected: activeDayIndex == index,
                        onTap: () => setState(() => selectedDay = index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Series Cards
                if (_seriesController.isUpcomingLoading.value &&
                    upcomingVideos.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(color: PColors.primary),
                    ),
                  )
                else if (visibleVideos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No upcoming series available',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: Color(0xFF888888),
                        ),
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    visibleVideos.length,
                    (index) {
                      final video = visibleVideos[index];
                      return Padding(
                        key: ValueKey(video.videoId.isNotEmpty
                            ? video.videoId
                            : 'series_$index'),
                        padding: const EdgeInsets.only(bottom: 18),
                        child: SeriesCard(
                          day: _formatSeriesDay(video, days),
                          title: video.displayTitle,
                          subtitle: 'By: ${video.displayCreatorName}',
                          image: video.thumbnailUrl,
                          selected: _isSameDate(video.scheduledDate,
                              days[activeDayIndex].dateTime),
                          onWatch: () => _openVideo(video),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),
                // Bottom Button
                if (!showAllSeries && upcomingVideos.length > 3)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide.none,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          showAllSeries = true;
                        });
                      },
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      label: const Text(
                        'View Full Weekly Series',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  List<_ScheduleDay> _buildScheduleDays(List<SeriesVideoModel> videos) {
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return _ScheduleDay(
        label: 'Day ${index + 1}',
        date: date.day,
        name: DateFormat('EEE').format(date),
        dateTime: date,
      );
    });
  }

  String _formatWeekRange(List<_ScheduleDay> days) {
    final firstDate = days.first.dateTime;
    final lastDate = days.last.dateTime;
    return '${DateFormat('d MMMM yyyy').format(firstDate)} - ${DateFormat('d MMMM yyyy').format(lastDate)}';
  }

  String _formatSeriesDay(
    SeriesVideoModel video,
    List<_ScheduleDay> scheduleDays,
  ) {
    final scheduledDate = video.scheduledDate;
    final dayIndex = scheduleDays.indexWhere(
      (day) => _isSameDate(scheduledDate, day.dateTime),
    );
    final dayLabel = dayIndex == -1 ? 'Upcoming' : 'Day ${dayIndex + 1}';

    if (scheduledDate == null) {
      return dayLabel;
    }

    return '$dayLabel - ${DateFormat('EEE, MMM d').format(scheduledDate)}';
  }

  bool _isSameDate(DateTime? first, DateTime second) {
    if (first == null) return false;
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void _openVideo(SeriesVideoModel video) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoDetailScreen(video: video),
      ),
    );
  }
}

class _ScheduleDay {
  final String label;
  final int date;
  final String name;
  final DateTime dateTime;

  const _ScheduleDay({
    required this.label,
    required this.date,
    required this.name,
    required this.dateTime,
  });
}

class DayCard extends StatelessWidget {
  final String label;
  final int date;
  final String dayName;
  final bool selected;
  final VoidCallback onTap;

  const DayCard({
    Key? key,
    required this.label,
    required this.date,
    required this.dayName,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? PColors.linearGradient : null,
          color: selected ? null : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: PColors.primary.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.toString(),
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              dayName,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11,
                color: selected ? Colors.white : const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeriesCard extends StatelessWidget {
  final String day;
  final String title;
  final String subtitle;
  final String image;
  final bool selected;
  final VoidCallback? onWatch;

  const SeriesCard({
    Key? key,
    required this.day,
    required this.title,
    required this.subtitle,
    required this.image,
    this.selected = false,
    this.onWatch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? PColors.primary.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _SeriesCardImage(image: image),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                      ),
                      onPressed: onWatch ?? () {},
                      icon: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 20),
                      label: const Text(
                        'Watch',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCCCCCC)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark_border,
                          color: Color(0xFF888888), size: 20),
                      label: const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesCardImage extends StatelessWidget {
  final String image;

  const _SeriesCardImage({required this.image});

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return _fallbackImage();
    }

    if (image.startsWith('http')) {
      return Image.network(
        image,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 80,
            height: 80,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }

    return Image.asset(
      image,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallbackImage(),
    );
  }

  Widget _fallbackImage() {
    return Image.asset(
      'assets/images/content/home1.png',
      width: 80,
      height: 80,
      fit: BoxFit.cover,
    );
  }
}

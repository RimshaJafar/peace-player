import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/creator_series/controllers/creator_series_controller.dart';
import 'package:ecommerce_app/features/creator_series/controllers/series_controller.dart';
import 'package:ecommerce_app/features/creator_series/screens/apply_to_be_featured.dart';
import 'package:ecommerce_app/features/creator_series/screens/creator_profile.dart';
import 'package:ecommerce_app/features/creator_series/screens/register_creator.dart';
import 'package:ecommerce_app/features/creator_series/screens/videodetailscreen.dart';
import 'package:ecommerce_app/features/creator_series/screens/weekly_schedule.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/containers/primary_header_container.dart';
import 'package:ecommerce_app/features/home/widgets/creator_of_the_day_container.dart';
import 'package:ecommerce_app/features/islamic_prayer/controllers/home_islamic_controller.dart';
import 'package:ecommerce_app/features/islamic_prayer/screens/prayer_times_screen.dart';
import 'package:ecommerce_app/features/islamic_prayer/screens/islamic_calendar_screen.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:get/get.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final compact =
        PSizes.isSmallPhone(context) || PSizes.isCompactHeight(context);
    final creatorCardHeight = compact ? 220.0 : 250.0;

    return PrimaryHeaderContainer(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: compact ? 24 : 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // New background container behind CreatorOfTheDayContainer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: creatorCardHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Creator of the Day',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          // color: const Color(0xFFBBA66F),
                                          color: PColors.textSecondary),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: PColors.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Featured',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                        // Creator of the Day container
                        // Adjust height to fit inside background container
                        SizedBox(height: compact ? 130 : 150),
                        const CreatorOfTheDayContainer(),
                        const Positioned(
                          bottom: -12,
                          left: 8,
                          child: _WatchNowActionButton(),
                        ),
                        // Circular gradient buttons at bottom right
                        const Positioned(
                          bottom: -18,
                          right: 8,
                          child: _CreatorActionButtons(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Islamic Cards Row
                  _IslamicCards(),
                  const SizedBox(height: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchNowActionButton extends StatefulWidget {
  const _WatchNowActionButton();

  @override
  State<_WatchNowActionButton> createState() => _WatchNowActionButtonState();
}

class _WatchNowActionButtonState extends State<_WatchNowActionButton> {
  late final SeriesController _seriesController =
      Get.isRegistered<SeriesController>()
          ? Get.find<SeriesController>()
          : Get.put(SeriesController());

  Future<void> _openTodaySeries() async {
    await _seriesController.fetchTodaySeries(force: true);

    final video = _seriesController.todayVideo;
    if (!mounted) return;

    if (video == null) {
      PLoaders.warningSnackBar(
        title: 'Video Unavailable',
        message: 'Today featured video not available',
        context: context,
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoDetailScreen(video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact =
        PSizes.isSmallPhone(context) || PSizes.isCompactHeight(context);

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: PColors.primary.withValues(alpha: 0.8),
        shadowColor: Colors.transparent,
        minimumSize: Size(0, compact ? 36 : 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.transparent, width: 0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 7 : 9,
        ),
      ),
      icon: Image.asset(
        'assets/icons/play-button-arrowhead.png',
        width: compact ? 14 : 16,
        height: compact ? 14 : 16,
        color: Colors.white,
      ),
      label: Text(
        'Watch Now',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: compact ? 12 : 13,
        ),
      ),
      onPressed: _openTodaySeries,
    );
  }
}

class _CreatorActionButtons extends StatefulWidget {
  const _CreatorActionButtons();

  @override
  State<_CreatorActionButtons> createState() => _CreatorActionButtonsState();
}

class _CreatorActionButtonsState extends State<_CreatorActionButtons> {
  late final CreatorSeriesController _creatorController =
      Get.isRegistered<CreatorSeriesController>()
          ? Get.find<CreatorSeriesController>()
          : Get.put(CreatorSeriesController());

  @override
  void initState() {
    super.initState();
    _creatorController.fetchCreatorProfile();
  }

  @override
  Widget build(BuildContext context) {
    final compact =
        PSizes.isSmallPhone(context) || PSizes.isCompactHeight(context);
    final gap = compact ? 6.0 : 8.0;

    return Obx(() {
      final actions = <Widget>[
        GradientCircleButton(
          iconPath: 'assets/icons/add.png',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const RegisterCreatorScreen(),
              ),
            );
          },
        ),
        if (_creatorController.isCreatorRegistered.value &&
            _creatorController.creatorProfile.value != null)
          GradientCircleButton(
            icon: Icons.person,
            onPressed: () async {
              await _creatorController.ensureFirebaseUserId();
              if (!context.mounted) return;

              final firebaseUserId = _creatorController.firebaseUserId;
              if (firebaseUserId == null || firebaseUserId.isEmpty) return;

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreatorProfileScreen(
                    firebaseUserId: firebaseUserId,
                  ),
                ),
              );
            },
          ),
        if (_creatorController.canUploadCreatorVideos)
          GradientCircleButton(
            iconPath: 'assets/icons/video-upload.png',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ApplyToBeFeaturedScreen(),
                ),
              );
            },
          ),
        GradientCircleButton(
          iconPath: 'assets/icons/calendar.png',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const WeeklyScheduleScreen(),
              ),
            );
          },
        ),
      ];

      return Wrap(
        spacing: gap,
        runSpacing: gap,
        alignment: WrapAlignment.end,
        children: actions,
      );
    });
  }
}

class _IslamicCards extends StatelessWidget {
  _IslamicCards() {
    Get.lazyPut<HomeIslamicController>(() => HomeIslamicController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeIslamicController>();
    const borderColor = Color(0xFFE7D9B8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          /// Prayer Timing Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrayerTimesScreen(),
                  ),
                );
              },
              child: Container(
                height: 70,
                padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFFEFA), Color(0xFFF8F3E6)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.access_time_filled,
                          color: PColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Prayer Timing',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: PColors.textPrimary,
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.summary.value == null) {
                        return const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: PColors.primary),
                          ),
                        );
                      }
                      final s = controller.summary.value;
                      final text = s?.upcomingPrayer != null
                          ? '${s!.upcomingPrayer!.name} • ${s.upcomingPrayer!.time}'
                          : '--:--';
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: PColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            fontFamily: 'Roboto',
                            height: 1.0,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          /// Islamic Date Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const IslamicCalendarScreen(),
                  ),
                );
              },
              child: Container(
                height: 70,
                padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFFEFA), Color(0xFFF7F1E0)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.calendar_month,
                          color: PColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Islamic Date',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: PColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Roboto',
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.summary.value == null) {
                        return const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: PColors.primary),
                          ),
                        );
                      }
                      final s = controller.summary.value;
                      final text = (s?.hijriDate.isNotEmpty == true)
                          ? s!.hijriDate
                          : '--';
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: PColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            fontFamily: 'Roboto',
                            height: 1.0,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for circular gradient button
class GradientCircleButton extends StatelessWidget {
  final String? iconPath;
  final IconData? icon;

  final VoidCallback onPressed;
  const GradientCircleButton({
    super.key,
    this.iconPath,
    this.icon,
    required this.onPressed,
  }) : assert(iconPath != null || icon != null);

  @override
  Widget build(BuildContext context) {
    final compact =
        PSizes.isSmallPhone(context) || PSizes.isCompactHeight(context);
    final buttonSize = compact ? 34.0 : 40.0;
    final iconSize = compact ? 20.0 : 24.0;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: buttonSize,
        width: buttonSize,
        decoration: BoxDecoration(
          gradient: PColors.linearGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white, size: iconSize)
              : Image.asset(
                  iconPath!,
                  width: iconSize,
                  height: iconSize,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}

import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/creator_series/controllers/creator_videos_controller.dart';
import 'package:ecommerce_app/features/creator_series/models/creator_video_model.dart';
import 'package:ecommerce_app/features/creator_series/screens/videodetailscreen.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/features/creator_series/controllers/creator_series_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CreatorProfileScreen extends StatefulWidget {
  final String? firebaseUserId;

  const CreatorProfileScreen({Key? key, this.firebaseUserId}) : super(key: key);

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  late CreatorSeriesController _creatorController;
  late CreatorVideosController _creatorVideosController;

  @override
  void initState() {
    super.initState();
    _creatorController = Get.isRegistered<CreatorSeriesController>()
        ? Get.find<CreatorSeriesController>()
        : Get.put(CreatorSeriesController());
    _creatorVideosController = Get.isRegistered<CreatorVideosController>()
        ? Get.find<CreatorVideosController>()
        : Get.put(CreatorVideosController());

    _loadProfileAndContent();
  }

  Future<void> _loadProfileAndContent({bool force = false}) async {
    await _creatorController.fetchCreatorProfile(userId: widget.firebaseUserId);
    final profile = _creatorController.creatorProfile.value;
    final userId = widget.firebaseUserId ??
        profile?.firebaseUserId ??
        _creatorController.firebaseUserId;

    await _creatorVideosController.loadCreatorContent(
      userId: userId,
      force: force,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          if (_creatorController.isProfileLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_creatorController.profileError.value != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _creatorController.profileError.value ??
                        'Error loading profile',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadProfileAndContent(force: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = _creatorController.creatorProfile.value;
          final videos = _creatorVideosController.videos.toList();
          final schedule = _creatorVideosController.schedule.toList();
          if (profile == null) {
            return const Center(
              child: Text('No profile data available'),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  _HeaderSection(profile: profile),
                  const SizedBox(height: 66),
                  // Stats Row
                  _StatsRow(
                    profile: profile,
                    videoCount: videos.length,
                    scheduleCount: schedule.length,
                  ),
                  const SizedBox(height: 16),
                  // About Section
                  SectionCard(
                    title: 'About',
                    description:
                        profile.bio.isEmpty ? 'No bio provided' : profile.bio,
                  ),
                  const SizedBox(height: 16),
                  // Social Links
                  _SocialLinksSection(socialLinks: profile.socialLinks),
                  const SizedBox(height: 16),
                  // Content Category
                  SectionCard(
                    title: 'Content Category',
                    description: profile.contentCategory.isEmpty
                        ? 'Not specified'
                        : profile.contentCategory,
                  ),
                  const SizedBox(height: 20),
                  _CreatorVideosSection(
                    title: 'All Videos',
                    subtitle: '${videos.length} creator uploads',
                    videos: videos,
                    isLoading: _creatorVideosController.isVideosLoading.value,
                    error: _creatorVideosController.videosError.value,
                    emptyMessage: 'No videos uploaded yet',
                    creatorName: profile.fullName,
                    onRetry: () => _creatorVideosController.loadCreatorContent(
                      userId: profile.firebaseUserId,
                      force: true,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _CreatorScheduleSection(
                    videos: schedule,
                    isLoading: _creatorVideosController.isScheduleLoading.value,
                    error: _creatorVideosController.scheduleError.value,
                    creatorName: profile.fullName,
                    onRetry: () => _creatorVideosController.loadCreatorContent(
                      userId: profile.firebaseUserId,
                      force: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final dynamic profile;

  const _HeaderSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 240,
          decoration: BoxDecoration(
            gradient: PColors.linearGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.7),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        // Profile Card Overlap
        Positioned(
          left: 0,
          right: 0,
          bottom: -50,
          child: Center(child: ProfileHeaderCard(profile: profile)),
        ),
      ],
    );
  }
}

class ProfileHeaderCard extends StatelessWidget {
  final dynamic profile;

  const ProfileHeaderCard({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Hero(
                tag: 'profile-image',
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage('assets/images/content/user.png'),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Icon(Icons.verified, color: PColors.primary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            profile.fullName ?? 'Creator Name',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.country ?? 'Location',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final dynamic profile;
  final int videoCount;
  final int scheduleCount;

  const _StatsRow({
    Key? key,
    required this.profile,
    required this.videoCount,
    required this.scheduleCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(
            child: StatCard(number: profile.status ?? 'N/A', label: 'Status'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(number: videoCount.toString(), label: 'Videos'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              number: scheduleCount.toString(),
              label: 'Scheduled',
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String number;
  final String label;
  const StatCard({Key? key, required this.number, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? child;
  const SectionCard(
      {Key? key, required this.title, this.description, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                color: Color(0xFF888888),
                height: 1.5,
              ),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 8),
            child!,
          ],
        ],
      ),
    );
  }
}

class _CreatorVideosSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<CreatorVideoModel> videos;
  final bool isLoading;
  final String? error;
  final String emptyMessage;
  final String creatorName;
  final VoidCallback onRetry;

  const _CreatorVideosSection({
    required this.title,
    required this.subtitle,
    required this.videos,
    required this.isLoading,
    required this.error,
    required this.emptyMessage,
    required this.creatorName,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: title,
            subtitle: subtitle,
            icon: Icons.video_library_rounded,
          ),
          const SizedBox(height: 12),
          if (isLoading && videos.isEmpty)
            const _ContentLoadingStrip()
          else if (error != null && videos.isEmpty)
            _InlineContentMessage(
              icon: Icons.error_outline,
              message: error!,
              actionLabel: 'Retry',
              onAction: onRetry,
            )
          else if (videos.isEmpty)
            _InlineContentMessage(
              icon: Icons.video_collection_outlined,
              message: emptyMessage,
            )
          else
            SizedBox(
              height: 238,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: videos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _CreatorVideoCard(
                    video: videos[index],
                    creatorName: creatorName,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CreatorVideoCard extends StatelessWidget {
  final CreatorVideoModel video;
  final String creatorName;

  const _CreatorVideoCard({
    required this.video,
    required this.creatorName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openVideo(context),
      child: Container(
        width: 224,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: _CreatorVideoThumbnail(
                    thumbnailUrl: video.thumbnailUrl,
                    width: 224,
                    height: 126,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _StatusChip(label: video.displayStatus),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            video.displayTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            color: PColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 15,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          video.displayCategory,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _formatVideoDate(video.scheduledDate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
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
      ),
    );
  }

  void _openVideo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoDetailScreen(
          video: video.toSeriesVideo(creatorName: creatorName),
        ),
      ),
    );
  }
}

class _CreatorScheduleSection extends StatelessWidget {
  final List<CreatorVideoModel> videos;
  final bool isLoading;
  final String? error;
  final String creatorName;
  final VoidCallback onRetry;

  const _CreatorScheduleSection({
    required this.videos,
    required this.isLoading,
    required this.error,
    required this.creatorName,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final sortedVideos = [...videos]..sort((a, b) {
        final first = a.scheduledDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final second =
            b.scheduledDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return first.compareTo(second);
      });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Schedule',
            subtitle: '${videos.length} planned releases',
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 12),
          if (isLoading && videos.isEmpty)
            const _ContentLoadingStrip()
          else if (error != null && videos.isEmpty)
            _InlineContentMessage(
              icon: Icons.error_outline,
              message: error!,
              actionLabel: 'Retry',
              onAction: onRetry,
            )
          else if (videos.isEmpty)
            const _InlineContentMessage(
              icon: Icons.event_busy_rounded,
              message: 'No scheduled videos yet',
            )
          else
            Column(
              children: List.generate(
                sortedVideos.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == sortedVideos.length - 1 ? 0 : 12,
                  ),
                  child: _ScheduleTimelineItem(
                    video: sortedVideos[index],
                    creatorName: creatorName,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleTimelineItem extends StatelessWidget {
  final CreatorVideoModel video;
  final String creatorName;

  const _ScheduleTimelineItem({
    required this.video,
    required this.creatorName,
  });

  @override
  Widget build(BuildContext context) {
    final scheduledDate = video.scheduledDate;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VideoDetailScreen(
              video: video.toSeriesVideo(creatorName: creatorName),
            ),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ScheduleDatePill(date: scheduledDate),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDEDED)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _CreatorVideoThumbnail(
                      thumbnailUrl: video.thumbnailUrl,
                      width: 72,
                      height: 72,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                video.displayTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Container(
                                height: 26,
                                width: 26,
                                decoration: BoxDecoration(
                                  color: PColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          video.displayCategory,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _StatusChip(label: video.displayStatus),
                      ],
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

class _ScheduleDatePill extends StatelessWidget {
  final DateTime? date;

  const _ScheduleDatePill({required this.date});

  @override
  Widget build(BuildContext context) {
    final month = date == null ? '--' : DateFormat('MMM').format(date!);
    final day = date == null ? '--' : DateFormat('d').format(date!);

    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: PColors.linearGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: PColors.primary.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            month.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            day,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: PColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: PColors.primary, size: 21),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CreatorVideoThumbnail extends StatelessWidget {
  final String thumbnailUrl;
  final double width;
  final double height;

  const _CreatorVideoThumbnail({
    required this.thumbnailUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (thumbnailUrl.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    return Image.network(
      thumbnailUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => SizedBox(width: width, height: height),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: PColors.primary,
        ),
      ),
    );
  }
}

class _ContentLoadingStrip extends StatelessWidget {
  const _ContentLoadingStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: PColors.primary),
      ),
    );
  }
}

class _InlineContentMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _InlineContentMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          Icon(icon, color: PColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                color: Color(0xFF777777),
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

String _formatVideoDate(DateTime? date) {
  if (date == null) return 'Not scheduled';
  return DateFormat('MMM d, yyyy').format(date);
}

class _SocialLinksSection extends StatelessWidget {
  final dynamic socialLinks;

  const _SocialLinksSection({Key? key, required this.socialLinks})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Social Links',
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 16,
        runSpacing: 16,
        children: [
          SocialIconButton(
            iconPath: 'assets/logos/youtube.png',
            label: 'YouTube',
            url: socialLinks.youtubeUrl ?? '',
          ),
          SocialIconButton(
            iconPath: 'assets/logos/instagram.png',
            label: 'Instagram',
            url: socialLinks.instagramUrl ?? '',
          ),
          SocialIconButton(
            iconPath: 'assets/logos/facebook.png',
            label: 'Facebook',
            url: socialLinks.facebookUrl ?? '',
          ),
          SocialIconButton(
            iconPath: 'assets/logos/tiktok.png',
            label: 'TikTok',
            url: socialLinks.tiktokUrl ?? '',
          ),
        ],
      ),
    );
  }
}

class SocialIconButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final String url;

  const SocialIconButton(
      {Key? key, required this.iconPath, required this.label, this.url = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasUrl = url.trim().isNotEmpty;

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: hasUrl ? () => _openSocialLink(context) : null,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: !hasUrl
                  ? const Color(0xFFF5F5F5).withOpacity(0.5)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Image.asset(iconPath, width: 28, height: 28),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  Future<void> _openSocialLink(BuildContext context) async {
    final Uri? uri = _normalizeSocialUri(url);
    if (uri == null) {
      PLoaders.errorSnackBar(
        title: 'Invalid link',
        message: 'This $label link is not valid.',
        context: context,
      );
      return;
    }

    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      PLoaders.errorSnackBar(
        title: 'Could not open link',
        message: 'Please check the $label URL.',
        context: context,
      );
    }
  }

  Uri? _normalizeSocialUri(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final Uri? parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) {
      return parsed;
    }

    return Uri.tryParse('https://$trimmed');
  }
}

import 'package:ecommerce_app/features/creator_series/controllers/series_controller.dart';
import 'package:ecommerce_app/features/creator_series/models/series_video_model.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatorOfTheDayContainer extends StatefulWidget {
  const CreatorOfTheDayContainer({super.key});

  @override
  State<CreatorOfTheDayContainer> createState() =>
      _CreatorOfTheDayContainerState();
}

class _CreatorOfTheDayContainerState extends State<CreatorOfTheDayContainer> {
  late final SeriesController _seriesController =
      Get.isRegistered<SeriesController>()
          ? Get.find<SeriesController>()
          : Get.put(SeriesController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seriesController.fetchTodaySeries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double containerHeight = PSizes.compactSpace(context, 180.0, 155.0);
    return Obx(
      () {
        final todayVideo = _seriesController.todayVideo;

        return Container(
          height: containerHeight,
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background image
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _SeriesBackgroundImage(video: todayVideo),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeriesBackgroundImage extends StatelessWidget {
  final SeriesVideoModel? video;

  const _SeriesBackgroundImage({required this.video});

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = video?.thumbnailUrl ?? '';

    if (thumbnailUrl.isEmpty) {
      return _fallbackImage();
    }

    return Image.network(
      thumbnailUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (_, __, ___) => _fallbackImage(),
    );
  }

  Widget _fallbackImage() {
    return Image.asset(
      'assets/images/content/home1.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/containers/kids_screen_background.dart';
import 'package:ecommerce_app/common/widgets/containers/story_card_container.dart';
import 'package:ecommerce_app/common/controllers/app_language_controller.dart';
import 'package:ecommerce_app/features/kids/controllers/kids_stories_controller.dart';
import 'package:ecommerce_app/features/kids/screens/stories_player_screen.dart';
import 'package:ecommerce_app/features/islamic_tube/controllers/islamic_tube_controller.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:get/get.dart';

class SahabaStoryScreen extends StatefulWidget {
  const SahabaStoryScreen({super.key});

  @override
  State<SahabaStoryScreen> createState() => _SahabaStoryScreenState();
}

class _SahabaStoryScreenState extends State<SahabaStoryScreen> {
  final IslamicMusicController controller = Get.put(IslamicMusicController());
  final KidsStoriesController storiesController =
      Get.put(KidsStoriesController());
  final AppLanguageController languageController =
      Get.isRegistered<AppLanguageController>()
          ? Get.find<AppLanguageController>()
          : Get.put(AppLanguageController());
  static const String _playlistId =
      'PLo9E4_TcFmB7qRcVLwlLSh2IdMJKnC1RC'; // Replace with actual playlist ID
  static const String _categoryKey = 'sahaba_stories';

  static const palette = [
    Color(0xFFCAA5CB),
    Color(0xFF77ACA2),
    Color(0xFF749BC2),
    Color(0xFFD97D55),
  ];

  @override
  void initState() {
    super.initState();
    controller.fetchPlaylistVideos(_playlistId);
    storiesController.fetchStories(_categoryKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F3EF),
      appBar: const PAppBar(
        title: Text(
          "Sahaba's",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFE48586),
        showBackArrow: true,
      ),
      body: KidsScreenBackground(
        child: Padding(
          padding: EdgeInsets.all(PSizes.compactSpace(context, 16.0, 12.0)),
          child: Obx(() {
            final titleLanguageCode =
                languageController.titleLanguageCode.value;
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.searchError.isNotEmpty) {
              return Center(
                child: Text(
                  controller.searchError.value,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            final videos = controller.videoItem;
            final stories = storiesController.stories;
            if (videos.isEmpty) {
              return const Center(child: Text('No stories available'));
            }
            return GridView.builder(
              itemCount: videos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: PSizes.adaptiveGridCount(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: PSizes.compactSpace(context, 250.0, 225.0),
              ),
              itemBuilder: (context, index) {
                final video = videos[index];
                final story = index < stories.length ? stories[index] : null;
                final storyId = story?.storyId ?? index + 1;
                final storyTitle = story != null
                    ? AppLanguageHelper.pickText(
                        story.title,
                        titleLanguageCode,
                      )
                    : video.title;
                final displayTitle =
                    storyTitle.isNotEmpty ? storyTitle : video.title;
                final color = palette[index % palette.length];
                return StoryCardContainer(
                  title: displayTitle,
                  textDirection:
                      TextDirectionUtils.directionFor(titleLanguageCode),
                  bottomColor: color,
                  thumbnailUrl: video.thumbnailUrl,
                  playIconPath: 'assets/icons/play 7.png',
                  onTap: () => _openPlayer(
                      context, displayTitle, video.videoUrl, storyId),
                  onPlayTap: () => _openPlayer(
                      context, displayTitle, video.videoUrl, storyId),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _openPlayer(
    BuildContext context,
    String title,
    String videoUrl,
    int storyId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoriesPlayerScreen(
          title: title,
          videoUrl: videoUrl,
          themeColor: const Color(0xFFE48586),
          palette: palette,
          categoryKey: _categoryKey,
          storyId: storyId,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/containers/kids_screen_background.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/moral_list_tile.dart';
import 'package:ecommerce_app/features/kids/controllers/kids_stories_controller.dart';
import 'package:ecommerce_app/features/kids/screens/quiz_screen.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:ecommerce_app/common/controllers/app_language_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    as yt_flutter;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt_iframe;

class StoriesPlayerScreen extends StatefulWidget {
  const StoriesPlayerScreen({
    super.key,
    required this.title,
    required this.videoUrl,
    required this.themeColor,
    required this.palette,
    this.categoryKey,
    this.storyId,
  });

  final String title;
  final String videoUrl;
  final Color themeColor;
  final List<Color> palette;
  final String? categoryKey;
  final int? storyId;

  @override
  State<StoriesPlayerScreen> createState() => _StoriesPlayerScreenState();
}

class _StoriesPlayerScreenState extends State<StoriesPlayerScreen> {
  yt_flutter.YoutubePlayerController? _flutterController;
  yt_iframe.YoutubePlayerController? _webController;
  String? videoId;
  bool _playerInitialized = false;
  final KidsStoriesController _storiesController =
      Get.put(KidsStoriesController());
  StreamSubscription<String?>? _textLangSub;
  StreamSubscription<String?>? _titleLangSub;

  Color _paletteColor(int index) {
    if (widget.palette.isEmpty) return widget.themeColor;
    return widget.palette[index % widget.palette.length];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
    _loadStoryDetail();
    // Listen for global language changes and refresh displayed texts if needed
    final langController = Get.isRegistered<AppLanguageController>()
        ? Get.find<AppLanguageController>()
        : Get.put(AppLanguageController());
    _textLangSub =
        langController.textLanguageCode.listen((_) => setState(() {}));
    _titleLangSub =
        langController.titleLanguageCode.listen((_) => setState(() {}));
  }

  void _loadStoryDetail() {
    final categoryKey = widget.categoryKey;
    final storyId = widget.storyId;
    if (categoryKey == null || storyId == null) {
      return;
    }
    _storiesController.fetchStoryDetail(categoryKey, storyId);
  }

  // -------------------- PLAYER INIT --------------------
  void _initializePlayer() {
    videoId = _extractVideoIdFromUrl(widget.videoUrl);

    if (videoId == null || videoId!.isEmpty || videoId!.length != 11) {
      debugPrint(
          '❌ Invalid videoId: "$videoId" from URL: "${widget.videoUrl}"');
      setState(() {
        _playerInitialized = true;
      });
      return;
    }

    if (kIsWeb) {
      _webController = yt_iframe.YoutubePlayerController.fromVideoId(
        videoId: videoId!,
        autoPlay: true,
        params: const yt_iframe.YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
        ),
      );
    } else {
      _flutterController = yt_flutter.YoutubePlayerController(
        initialVideoId: videoId!,
        flags: const yt_flutter.YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
          controlsVisibleAtStart: true,
          hideControls: false,
          showLiveFullscreenButton: true,
        ),
      );
    }

    setState(() {
      _playerInitialized = true;
    });
  }

  // -------------------- VIDEO ID EXTRACTION --------------------
  String? _extractVideoIdFromUrl(String url) {
    if (url.isEmpty) return null;
    if (url.contains('youtube.com/watch?v=')) {
      return url.split('v=')[1].split('&')[0];
    }
    if (url.contains('youtu.be/')) {
      return url.split('youtu.be/')[1].split('?')[0];
    }
    if (url.contains('youtube.com/embed/')) {
      return url.split('embed/')[1].split('?')[0];
    }
    if (url.length == 11 && !url.contains('/')) {
      return url;
    }
    return null;
  }

  bool get _shouldResumeStoryAfterQuiz {
    if (kIsWeb) {
      final playerState = _webController?.value.playerState;
      return playerState == yt_iframe.PlayerState.playing ||
          playerState == yt_iframe.PlayerState.buffering;
    }

    final value = _flutterController?.value;
    return value?.isPlaying == true ||
        value?.playerState == yt_flutter.PlayerState.buffering;
  }

  Future<void> _pauseStoryPlayback() async {
    if (kIsWeb) {
      await _webController?.pauseVideo();
      return;
    }

    _flutterController?.pause();
  }

  Future<void> _resumeStoryPlayback() async {
    if (kIsWeb) {
      await _webController?.playVideo();
      return;
    }

    _flutterController?.play();
  }

  Future<void> _openQuiz(String displayTitle) async {
    final shouldResumeStory = _shouldResumeStoryAfterQuiz;

    await _pauseStoryPlayback();
    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          categoryKey: widget.categoryKey,
          storyId: widget.storyId,
          storyTitle: displayTitle,
        ),
      ),
    );

    if (!mounted || !shouldResumeStory) {
      return;
    }

    await _resumeStoryPlayback();
  }

  // -------------------- DISPOSE --------------------
  @override
  void dispose() {
    _flutterController?.dispose();
    _webController?.close();
    _textLangSub?.cancel();
    _titleLangSub?.cancel();
    super.dispose();
  }

  // -------------------- BUILD --------------------
  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final titleDirection = TextDirectionUtils.directionFor(titleLanguageCode);
    final textDirection = TextDirectionUtils.directionFor(textLanguageCode);
    final isTitleRtl = titleDirection == TextDirection.rtl;

    return Obx(() {
      final detail = _storiesController.storyDetail.value;
      final detailMatches = detail != null &&
          detail.categoryKey == widget.categoryKey &&
          detail.storyId == widget.storyId;
      final activeDetail = detailMatches ? detail : null;
      final detailTitle = activeDetail != null
          ? AppLanguageHelper.pickText(activeDetail.title, titleLanguageCode)
          : widget.title;
      final displayTitle = detailTitle.isNotEmpty ? detailTitle : widget.title;
      final moralItems = (activeDetail?.morals ?? [])
          .map((moral) =>
              AppLanguageHelper.pickText(moral.text, textLanguageCode))
          .where((text) => text.isNotEmpty)
          .toList();

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PAppBar(
          title: Text(
            displayTitle,
            textDirection: titleDirection,
            style: TextStyle(
              color: Colors.white,
              fontFamily: isTitleRtl ? 'Lateef' : 'Poppins',
              fontSize: isTitleRtl ? 29 : 25,
              height: isTitleRtl ? 1.25 : 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: widget.themeColor,
          showBackArrow: true,
        ),
        body: KidsScreenBackground(
          child: Column(
            children: [
              // -------------------- YOUTUBE PLAYER --------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF172126),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF263C48).withValues(alpha: 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: !_playerInitialized
                        ? const Center(child: CircularProgressIndicator())
                        : (videoId == null || videoId!.isEmpty)
                            ? Container(
                                color: const Color(0xFFEEF2F3),
                                child: const Center(
                                  child: Text(
                                    'Invalid video',
                                    style: TextStyle(
                                      color: Color(0xFF6E7F88),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            : kIsWeb
                                ? yt_iframe.YoutubePlayer(
                                    key: ValueKey(videoId),
                                    controller: _webController!,
                                    aspectRatio: 16 / 9,
                                  )
                                : yt_flutter.YoutubePlayer(
                                    key: ValueKey(videoId),
                                    controller: _flutterController!,
                                    showVideoProgressIndicator: true,
                                    progressIndicatorColor: widget.themeColor,
                                    progressColors:
                                        yt_flutter.ProgressBarColors(
                                      playedColor: widget.themeColor,
                                      handleColor: widget.themeColor
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // -------------------- STORY MORAL SECTION --------------------
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.96),
                        const Color(0xFFF3F8F6).withValues(alpha: 0.98),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.95),
                        width: 2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF526F83).withValues(alpha: 0.16),
                        blurRadius: 22,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                      child: Column(
                        children: [
                          Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB8C8C4),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color:
                                      widget.themeColor.withValues(alpha: 0.16),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lightbulb_rounded,
                                  color: widget.themeColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Story Moral',
                                style: GoogleFonts.fredoka(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF315A65),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _storiesController
                                        .isStoryDetailLoading.value &&
                                    activeDetail == null
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _storiesController
                                            .storyDetailError.isNotEmpty &&
                                        activeDetail == null
                                    ? const Center(
                                        child: Text('Unable to load morals'),
                                      )
                                    : moralItems.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No morals available',
                                              style: TextStyle(
                                                color: Color(0xFF6E7F88),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                        : Directionality(
                                            textDirection: textDirection,
                                            child: Scrollbar(
                                              child: ListView.separated(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .only(
                                                  end: 3,
                                                  bottom: 8,
                                                ),
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemCount: moralItems.length,
                                                separatorBuilder: (_, __) =>
                                                    const SizedBox(height: 12),
                                                itemBuilder: (context, index) =>
                                                    MoralListTile(
                                                  index: index + 1,
                                                  text: moralItems[index],
                                                  textDirection: textDirection,
                                                  backgroundColor:
                                                      _paletteColor(index),
                                                ),
                                              ),
                                            ),
                                          ),
                          ),
                          if (widget.categoryKey != null &&
                              widget.storyId != null) ...[
                            const SizedBox(height: 10),
                            _buildQuizButton(displayTitle),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuizButton(String displayTitle) {
    final buttonColor = Color.lerp(
      widget.themeColor,
      const Color(0xFF315A65),
      0.36,
    )!;

    return Material(
      color: Colors.transparent,
      child: Ink(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              buttonColor.withValues(alpha: 0.86),
              buttonColor,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.70),
          ),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openQuiz(displayTitle),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_rounded,
                color: Colors.white,
                size: 23,
              ),
              SizedBox(width: 10),
              Text(
                'Take Quiz',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

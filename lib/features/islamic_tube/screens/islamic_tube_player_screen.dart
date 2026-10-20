import 'package:ecommerce_app/features/islamic_tube/controllers/islamic_tube_controller.dart';
import 'package:ecommerce_app/features/islamic_tube/models/search_input_model.dart';
import 'package:ecommerce_app/features/islamic_tube/models/spiritual_need_model.dart';
import 'package:ecommerce_app/features/islamic_tube/models/video_item_model.dart';
import 'package:ecommerce_app/features/islamic_tube/screens/playlist_screen.dart';
import 'package:ecommerce_app/features/islamic_tube/screens/video_screen.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class IslamicMusicPlayerScreen extends StatefulWidget {
  const IslamicMusicPlayerScreen({super.key});

  @override
  State<IslamicMusicPlayerScreen> createState() =>
      IslamicMusicPlayerScreenState();
}

class IslamicMusicPlayerScreenState extends State<IslamicMusicPlayerScreen>
    with WidgetsBindingObserver, RouteAware {
  final IslamicMusicController islamicMusicController =
      Get.put(IslamicMusicController());
  final TextEditingController searchController = TextEditingController();
  List<VideoItem>? _savedVideoContent;
  String playlistSearchQuery = '';

  int maxResults = 10;
  final List<String> availableFilters = [
    'All',
    'Quran',
    'Naat',
    'Nasheed',
    'Kalaam',
    'Hamd',
    'Manqabat',
    'Qawwali',
    'Zikr',
    'Qasida',
    'Durood',
    'Azan'
  ];
  String selectedFilter = ''; // Only one filter at a time
  String? selectedSpiritualNeed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Fetch playlists when the screen initializes
    islamicMusicController.fetchPlaylists();
    // Load default videos on startup with a simple query
    _fetchMixedContent();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Called when this screen comes back to the foreground
    if (_savedVideoContent != null) {
      islamicMusicController.videoItem.value = _savedVideoContent!;
    } else {
      _fetchMixedContent();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When coming back to this screen, reload default content
      if (_savedVideoContent != null) {
        islamicMusicController.videoItem.value = _savedVideoContent!;
      }
    }
  }

  String _buildDefaultVideoQuery() {
    const baseQuery =
        'authentic Islamic Quran recitation Naat Nasheed Hamd Manqabat Islamic lectures spiritual guidance';

    if (selectedFilter.isNotEmpty && selectedFilter.toLowerCase() != 'all') {
      return '$selectedFilter $baseQuery';
    }

    return baseQuery;
  }

  String _buildDefaultShortsQuery() {
    const baseQuery =
        'Islamic short video Quran reminder Naat short Durood short Islamic status vertical video';

    if (selectedFilter.isNotEmpty && selectedFilter.toLowerCase() != 'all') {
      return '$selectedFilter $baseQuery';
    }

    return baseQuery;
  }

  Future<void> _fetchCombinedContent({
    required String videoQuery,
    required String shortsQuery,
    int videoMaxResults = 20,
    int shortsMaxResults = 5,
    List<String> filters = const [],
  }) async {
    // Fetch videos first
    final videosInput = SearchInput(
      query: videoQuery,
      maxResults: videoMaxResults,
      filters: filters,
    );

    await islamicMusicController.fetchSearchContent(videosInput);
    var videos = List<VideoItem>.from(islamicMusicController.videoItem);

    // Only proceed if we got videos, otherwise keep previous content
    if (videos.isEmpty) {
      islamicMusicController.isLoading.value = false;
      return;
    }

    // Fetch shorts with the exact same query
    final shortsInput = SearchInput(
      query: shortsQuery,
      maxResults: shortsMaxResults,
      filters: filters,
    );

    final shorts = await islamicMusicController.fetchSearchShorts(shortsInput);

    // Remove duplicates: filter out videos that are also in shorts
    final shortsUrlSet = shorts.map((s) => s.videoUrl).toSet();
    videos = videos.where((v) => !shortsUrlSet.contains(v.videoUrl)).toList();

    // Combine videos and shorts with dynamic layout logic
    final List<VideoItem> mixedContent = [];
    final totalVideos = videos.length;

    if (totalVideos > 4) {
      final belowCount = (totalVideos / 2).ceil();
      final aboveCount = totalVideos - belowCount;

      mixedContent.addAll(videos.take(aboveCount));
      mixedContent.addAll(shorts.take(shortsMaxResults));
      mixedContent.addAll(videos.skip(aboveCount).take(belowCount));
    } else {
      mixedContent.addAll(videos);
      mixedContent.addAll(shorts.take(shortsMaxResults));
    }

    islamicMusicController.videoItem.value = mixedContent;
    islamicMusicController.isLoading.value = false;
  }

  Future<void> _fetchMixedContent() async {
    islamicMusicController.isLoading.value = true;
    // Clear error only for default loads (not for manual search)
    if (searchController.text.isEmpty && selectedFilter.isNotEmpty) {
      islamicMusicController.searchError.value = '';
    }

    try {
      final videoQuery = _buildDefaultVideoQuery();
      final shortsQuery = _buildDefaultShortsQuery();
      await _fetchCombinedContent(
        videoQuery: videoQuery,
        shortsQuery: shortsQuery,
        videoMaxResults: 20,
        shortsMaxResults: 5,
        filters: [],
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[IslamicTube] Mixed content load failed: $error');
        debugPrint(stackTrace.toString());
      }
      if (searchController.text.isNotEmpty) {
        islamicMusicController.searchError.value =
            AppErrorMessage.fromException(
          error,
          fallback: 'Unable to load videos. Please try again.',
        );
      }
      islamicMusicController.isLoading.value = false;
    }
  }

  void search() {
    if (selectedSpiritualNeed != null) {
      setState(() => selectedSpiritualNeed = null);
    }
    islamicMusicController.isLoading.value = true;

    final searchText = searchController.text.trim();

    final videoQuery =
        searchText.isEmpty ? _buildDefaultVideoQuery() : searchText;
    final shortsQuery = searchText.isEmpty
        ? _buildDefaultShortsQuery()
        : '$searchText short video vertical';

    _fetchCombinedContent(
      videoQuery: videoQuery,
      shortsQuery: shortsQuery,
      videoMaxResults: maxResults,
      shortsMaxResults: 5,
      filters: selectedFilter.isNotEmpty ? [selectedFilter] : [],
    );
  }

  Future<void> _selectSpiritualNeed(SpiritualNeed need) async {
    setState(() {
      selectedSpiritualNeed = need.label;
      searchController.clear();
    });

    await _fetchCombinedContent(
      videoQuery: need.query,
      shortsQuery: need.query,
      videoMaxResults: maxResults,
      shortsMaxResults: 5,
      filters: selectedFilter.isNotEmpty ? [selectedFilter] : [],
    );
  }

  Future<void> _showSpiritualNeedsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.78,
          minChildSize: 0.55,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFFFCFEFD),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8D7D2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF60BEA8), Color(0xFF329070)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_outline_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What do you need today?',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF1C3D35),
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Choose how you feel and we’ll recommend Islamic content for your heart.',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF627C75),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF627C75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE1ECE8)),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final horizontalPadding =
                            constraints.maxWidth >= 600 ? 28.0 : 16.0;
                        final gridCount =
                            constraints.maxWidth >= 600 ? 3 : 2;
                        final childAspectRatio =
                            constraints.maxWidth >= 600 ? 1.05 : 1.12;

                        return GridView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            18,
                            horizontalPadding,
                            28,
                          ),
                          itemCount: spiritualNeeds.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCount,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemBuilder: (context, index) {
                            final need = spiritualNeeds[index];
                            final isSelected =
                                selectedSpiritualNeed == need.label;

                            return Semantics(
                              button: true,
                              selected: isSelected,
                              label: need.label,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF329070)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1C5D4E)
                                        : const Color(0xFFC8DDD7),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1C5D4E).withValues(
                                        alpha: isSelected ? 0.18 : 0.08,
                                      ),
                                      blurRadius: isSelected ? 12 : 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () {
                                      Navigator.of(sheetContext).pop();
                                      _selectSpiritualNeed(need);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white.withValues(
                                                      alpha: 0.16,
                                                    )
                                                  : const Color(0xFFEAF5F1),
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                            ),
                                            child: Icon(
                                              need.icon,
                                              size: 23,
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF329070),
                                            ),
                                          ),
                                          const SizedBox(height: 11),
                                          Text(
                                            need.label,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF294D44),
                                              fontSize: 14,
                                              height: 1.25,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Builds the playlist drawer with playlists from backend API.
  Widget _buildPlaylistDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFEEEEEE),
      child: Column(
        children: [
          // Header with Peace Player logo and search
          Container(
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF60BEA8),
                  Color(0xFF329070),
                  Color(0xFF1C5D4E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Image.asset(
                      "assets/logos/peace_logo.png",
                      height: 30,
                      width: 30,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Peace Player",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                Container(
                  height: 40,
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        playlistSearchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 14, bottom: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Playlists',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (islamicMusicController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (islamicMusicController.playlistError.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        islamicMusicController.playlistError.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: islamicMusicController.fetchPlaylists,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final playlistList =
                  islamicMusicController.playlists.where((playlist) {
                if (playlistSearchQuery.isEmpty) return true;
                return playlist.title
                    .toLowerCase()
                    .contains(playlistSearchQuery);
              }).toList();

              if (playlistList.isEmpty) {
                return const Center(
                    child: Text('No playlists found.',
                        style: TextStyle(color: Colors.black87)));
              }

              return ListView.builder(
                itemCount: playlistList.length,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemBuilder: (context, index) {
                  final playlist = playlistList[index];
                  return InkWell(
                    onTap: () {
                      // Save current content before navigating to playlist
                      final backupContent = List<VideoItem>.from(
                          islamicMusicController.videoItem);
                      Navigator.pop(context); // Close drawer
                      Get.to(
                        () => PlaylistScreen(playlist: playlist),
                        arguments: {'videoBackup': backupContent},
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final thumbnailWidth = constraints.maxWidth * 0.35;
                            return Row(
                              children: [
                                // Thumbnail - full height, 40% width
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: thumbnailWidth - 10,
                                      child: Image.network(
                                        playlist.thumbnailUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Playlist Title - scrollable inside tile
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: ClipRect(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: Text(
                                            playlist.title,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.visible,
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildPlaylistDrawer(),
      appBar: AppBar(
        title: const Text(
          "Soulful Sounds",
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF60BEA8), Color(0xFF329070), Color(0xFF1C5D4E)],
              stops: [0.08, 0.47, 0.85],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Tooltip(
              message: 'For Your Heart',
              child: Material(
                color: Colors.white.withValues(alpha: 0.16),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _showSpiritualNeedsSheet,
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      selectedSpiritualNeed == null
                          ? Icons.favorite_outline_rounded
                          : Icons.favorite_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: PSizes.md,
              right: PSizes.md,
              top: PSizes.md,
              bottom: PSizes.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2E3DF),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onSubmitted: (_) => search(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF329070),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          iconSize: 28,
                          tooltip: 'Search Islamic media',
                          onPressed: search,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: PSizes.spaceBtwItems),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: availableFilters.map((f) {
                      final isSelected = selectedFilter == f;
                      return Padding(
                        padding: EdgeInsets.only(right: PSizes.spaceBtwItems),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color.fromRGBO(119, 197, 162, 0.9)
                                : const Color(0XFFE6F0EF),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF329070)
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() {
                                  selectedSpiritualNeed = null;
                                  if (isSelected) {
                                    // Deselect the filter
                                    selectedFilter = '';
                                  } else {
                                    // Select this filter (deselects others automatically)
                                    selectedFilter = f;
                                    searchController
                                        .clear(); // Clear search when filter selected
                                  }
                                });
                                // Auto-fetch content for selected filter
                                _fetchMixedContent();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0XFF627C75),
                                  ),
                                  child: Text(f),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: PSizes.spaceBtwItems),
              ],
            ),
          ),

          // Content Area
          const Expanded(
            child: VideoScreen(),
          ),
        ],
      ),
    );
  }
}

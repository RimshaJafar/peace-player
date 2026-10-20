import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/seerah_nabwi/controllers/seerah_nabwi_controller.dart';
import 'package:ecommerce_app/features/seerah_nabwi/models/naat_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'naat_inner_screen.dart';

class NaatScreen extends StatefulWidget {
  const NaatScreen({super.key});

  @override
  State<NaatScreen> createState() => _NaatScreenState();
}

class _NaatScreenState extends State<NaatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SeerahNabwiController controller = Get.put(SeerahNabwiController());

  List<Naat> naatItems = [];
  List<Naat> filteredNaatItems = [];
  List<String> categories = ['All Naat'];
  String selectedCategory = 'All Naat';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterNaatItems);
  }

  Future<void> _loadData() async {
    // Fetch all naats and reciters
    await controller.fetchAllNaats();
    await controller.fetchAllReciters();

    setState(() {
      naatItems = controller.naats;
      filteredNaatItems = naatItems;

      // Build categories: "All Naat" first, then reciter names
      categories = ['All Naat'];
      categories.addAll(
        controller.reciters.map((reciter) => reciter.name).toList(),
      );
      selectedCategory = 'All Naat';
    });
  }

  void _filterNaatItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredNaatItems = naatItems;
      } else {
        filteredNaatItems = naatItems
            .where((naat) =>
                (naat.title['en'] ?? '').toLowerCase().contains(query) ||
                (naat.title['ur'] ?? '').toLowerCase().contains(query) ||
                (naat.reciter['en'] ?? '').toLowerCase().contains(query) ||
                (naat.reciter['ur'] ?? '').toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _onCategorySelected(String category) async {
    setState(() {
      selectedCategory = category;
    });

    if (category == 'All Naat') {
      setState(() {
        naatItems = controller.naats;
        _filterNaatItems();
      });
    } else {
      // Fetch naats by reciter
      final result = await controller.fetchNaatsByReciter(category);
      if (result != null) {
        setState(() {
          naatItems = result.naats;
          _filterNaatItems();
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    return Scaffold(
      appBar: PAppBar(
        title: Text(
          'Naat',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: GetBuilder<SeerahNabwiController>(
        builder: (seerahController) {
          final isLoading =
              seerahController.naatsLoading || seerahController.recitersLoading;

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Naat',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                    ),
                  ),
                ),
              ),
              // Category Bar
              if (categories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.hardEdge,
                      padding: EdgeInsets.zero,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category;
                        final isFirst = index == 0;
                        final isLast = index == categories.length - 1;

                        return Padding(
                          padding: EdgeInsets.only(
                            left: isFirst ? 0 : 0,
                            right: isLast ? 16 : 12,
                          ),
                          child: GestureDetector(
                            onTap: () => _onCategorySelected(category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF329070)
                                    : const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                const SizedBox(height: 10),
              // Padding between category bar and tiles
              const SizedBox(height: 12),
              // Naat List
              Expanded(
                child: isLoading && filteredNaatItems.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredNaatItems.isEmpty
                        ? Center(
                            child: Text(
                              'No Naat found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredNaatItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: NaatListCard(
                                  naat: filteredNaatItems[index],
                                  textLanguageCode: textLanguageCode,
                                  onPlayPressed: () {
                                    final naatIds = filteredNaatItems
                                        .map((naat) => naat.id)
                                        .toList();
                                    controller
                                        .fetchNaatDetail(
                                            filteredNaatItems[index].id)
                                        .then((detail) {
                                      if (detail != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NaatInnerScreen(
                                              naatId: detail.id,
                                              naatIds: naatIds,
                                              initialIndex: index,
                                            ),
                                          ),
                                        );
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class NaatListCard extends StatelessWidget {
  final Naat naat;
  final VoidCallback onPlayPressed;
  final String textLanguageCode;

  const NaatListCard({
    super.key,
    required this.naat,
    required this.onPlayPressed,
    required this.textLanguageCode,
  });

  @override
  Widget build(BuildContext context) {
    final title = AppLanguageHelper.pickText(naat.title, textLanguageCode);
    final reciter = AppLanguageHelper.pickText(naat.reciter, textLanguageCode);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFD2E3DF), // Updated tile background color
      child: InkWell(
        onTap: onPlayPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Left: Square Naat artwork
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF173F32).withValues(alpha: 0.16),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/content/naat_tile_image.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const ColoredBox(
                      color: Color(0xFF5F8466),
                      child: Icon(
                        Icons.music_note_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Center: Title and Subtitle
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              textDirection: TextDirectionUtils.directionFor(
                                  textLanguageCode),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 18,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              reciter,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              textDirection: TextDirectionUtils.directionFor(
                                  textLanguageCode),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Right: Play Button
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF329070),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: onPlayPressed,
                        padding: EdgeInsets.zero,
                        splashRadius: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

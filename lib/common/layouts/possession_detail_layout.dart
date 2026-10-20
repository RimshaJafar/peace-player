import 'package:ecommerce_app/common/widgets/list_tiles/dropdown_list_tile.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PossessionDetailLayout extends StatefulWidget {
  final String? imagePath;
  final List<String>? imagePaths;
  final Map<String, List<Map<String, String>>> categorizedData;
  final Map<String, String>? categoryLabels;
  final Function(String content, int index)? onPlayAudio;

  const PossessionDetailLayout({
    super.key,
    this.imagePath,
    this.imagePaths,
    required this.categorizedData,
    this.categoryLabels,
    this.onPlayAudio,
  }) : assert(imagePath != null || imagePaths != null,
            'Either imagePath or imagePaths must be provided');

  @override
  State<PossessionDetailLayout> createState() => _PossessionDetailLayoutState();
}

class _PossessionDetailLayoutState extends State<PossessionDetailLayout> {
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    // Set the first category as default
    selectedCategory = widget.categorizedData.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final currentData = widget.categorizedData[selectedCategory] ?? [];

    return Column(
      children: [
        // Top 30% for image
        SizedBox(
          height: height * 0.30,
          child: widget.imagePaths != null && widget.imagePaths!.length > 1
              ? widget.imagePaths!.length == 3
                  ? Column(
                      children: [
                        // First row - 2 images
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Image.asset(
                                    widget.imagePaths![1],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Image.asset(
                                    widget.imagePaths![2],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Second row - 1 image
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Image.asset(
                                    widget.imagePaths![0],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widget.imagePaths!.map((path) {
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Center(
                              child: Image.asset(
                                path,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
              : Center(
                  child: Image.asset(
                    widget.imagePath ?? widget.imagePaths!.first,
                    fit: BoxFit.contain,
                  ),
                ),
        ),
        // Bottom 70% with curved container
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFD2E3DF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Category Tabs
                if (widget.categorizedData.keys.length > 1)
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.04,
                        right: width * 0.04,
                        top: 16,
                        bottom: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.categorizedData.keys.map((category) {
                          final isSelected = selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color.fromRGBO(119, 197, 162, 0.9)
                                    : const Color(0XFFE6F0EF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF329070)
                                      : Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOutCubic,
                                      style: GoogleFonts.notoNastaliqUrdu(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0XFF627C75),
                                      ),
                                      child: Text(
                                        widget.categoryLabels?[category] ??
                                            category,
                                        textDirection:
                                            TextDirectionUtils.directionFor(
                                                titleLanguageCode),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                // Content List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: 8,
                    ),
                    itemCount: currentData.length,
                    itemBuilder: (context, index) {
                      final item = currentData[index];
                      return DropdownListTile(
                        title: item['title']!,
                        content: item['content'],
                        index: index + 1,
                        tileColor: const Color(0xFF329070),
                        showActions: false,
                        onPlayAudio: widget.onPlayAudio != null
                            ? () {
                                if ((item['content'] ?? '').isNotEmpty) {
                                  widget.onPlayAudio!(
                                      item['content']!, index + 1);
                                }
                              }
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

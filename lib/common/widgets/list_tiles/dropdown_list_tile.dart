import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/single_line_title_text.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/features/worships/screens/tasbih_screen.dart';

class DropdownListTile extends StatefulWidget {
  final String title;
  final String? arabic;
  final String? translation;
  final String? content; // fallback
  final int? index; // optional number badge
  final Color? tileColor; // custom tile color
  final bool showActions; // show bottom action row
  final bool isSaved;
  final bool showBookmark; // control bookmark icon visibility
  final String? source; // 'system' or 'agent'
  final bool centerText; // center text alignment
  final VoidCallback? onSaveToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onPlayAudio;

  const DropdownListTile({
    super.key,
    required this.title,
    this.arabic,
    this.translation,
    this.content,
    this.index,
    this.tileColor,
    this.showActions = true,
    this.isSaved = false,
    this.showBookmark = true, // default to showing bookmark
    this.source,
    this.centerText = false, // default to right-aligned
    // this.showMic = true, // default to showing mic
    this.onSaveToggle,
    this.onDelete,
    this.onPlayAudio,
  });

  @override
  State<DropdownListTile> createState() => _DropdownListTileState();
}

class _DropdownListTileState extends State<DropdownListTile>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _isExpanded = false;

  @override
  bool get wantKeepAlive => true;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final isRtl =
        TextDirectionUtils.directionFor(titleLanguageCode) == TextDirection.rtl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Collapsed Tile
        Tooltip(
          message: widget.title,
          triggerMode: TooltipTriggerMode.longPress,
          child: GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              width: double.infinity,
              height: 75,
              decoration: BoxDecoration(
                color: widget.tileColor ?? const Color(0xFF329070),
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                      )
                    : BorderRadius.circular(5),
              ),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  if (isRtl) _buildHeaderArrow(isRtl),
                  if (!isRtl && widget.index != null) _buildIndexBadge(isRtl),
                  _buildHeaderTitle(titleLanguageCode, isRtl),
                  if (isRtl && widget.index != null) _buildIndexBadge(isRtl),
                  if (!isRtl) _buildHeaderArrow(isRtl),
                ],
              ),
            ),
          ),
        ),
        // Expanded Dropdown Content
        if (_isExpanded)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.zero,
                topRight: Radius.zero,
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Mic Icon - Top Left
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: widget.onPlayAudio,
                    child: const Icon(
                      Icons.volume_up,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
                // Main Content
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        if (widget.arabic != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              widget.arabic!,
                              textDirection: TextDirection.rtl,
                              textAlign: widget.centerText
                                  ? TextAlign.center
                                  : TextAlign.right,
                              style: GoogleFonts.amiri(
                                color: Colors.black87,
                                fontSize: 20,
                                height: 2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (widget.translation != null ||
                            widget.content != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (widget.translation != null)
                                Text(
                                  widget.translation!,
                                  textDirection:
                                      TextDirectionUtils.directionFor(
                                          AppLanguageHelper.textLanguageCode()),
                                  textAlign: widget.centerText
                                      ? TextAlign.center
                                      : TextDirectionUtils.alignFor(
                                          AppLanguageHelper.textLanguageCode()),
                                  style: GoogleFonts.notoNastaliqUrdu(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    height: 2,
                                  ),
                                ),
                              if (widget.translation != null &&
                                  widget.content != null)
                                const SizedBox(height: 10),
                              if (widget.content != null)
                                Text(
                                  widget.content!,
                                  textDirection:
                                      TextDirectionUtils.directionFor(
                                          AppLanguageHelper.textLanguageCode()),
                                  textAlign: TextDirectionUtils.alignFor(
                                      AppLanguageHelper.textLanguageCode()),
                                  style: GoogleFonts.notoNastaliqUrdu(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    height: 2.5,
                                  ),
                                ),
                            ],
                          ),
                        if (widget.showActions) ...[
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                _buildGradientIconButton(
                                  assetPath: 'assets/icons/tasbih.png',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TasbihScreen(
                                          arabicText: widget.arabic,
                                          urduText: widget.translation,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const Spacer(),
                                if (widget.showBookmark)
                                  widget.source == 'agent'
                                      ? GestureDetector(
                                          onTap: widget.onDelete,
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 36,
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: widget.onSaveToggle,
                                          child: Icon(
                                            widget.isSaved
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            color: const Color(0xFF329070),
                                            size: 36,
                                          ),
                                        ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildHeaderArrow(bool isRtl) {
    final arrowAsset =
        _isExpanded ? 'assets/icons/down_arrow.png' : 'assets/icons/back1.png';
    final arrowWidget = Image.asset(
      arrowAsset,
      width: _isExpanded ? 32 : 20,
      height: _isExpanded ? 32 : 20,
      color: Colors.white,
    );
    return Padding(
      padding: EdgeInsets.only(left: isRtl ? 16 : 0, right: isRtl ? 0 : 16),
      child: (!_isExpanded && !isRtl)
          ? Transform.rotate(
              angle: math.pi,
              child: arrowWidget,
            )
          : arrowWidget,
    );
  }

  Widget _buildHeaderTitle(String titleLanguageCode, bool isRtl) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: isRtl ? 10 : 30, right: isRtl ? 30 : 10),
        child: SingleLineTitleText(
          title: widget.title,
          style: GoogleFonts.notoNastaliqUrdu(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.6,
          ),
          textAlign: TextDirectionUtils.alignFor(titleLanguageCode),
          textDirection: TextDirectionUtils.directionFor(titleLanguageCode),
        ),
      ),
    );
  }

  Widget _buildIndexBadge(bool isRtl) {
    return Padding(
      padding: EdgeInsets.only(left: isRtl ? 0 : 20, right: isRtl ? 20 : 0),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.index.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method for rounded gradient icon button
  Widget _buildGradientIconButton({
    required String assetPath,
    required VoidCallback onPressed,
  }) {
    final buttonColor = widget.tileColor ?? const Color(0xFF329070);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              buttonColor.withValues(alpha: 0.8),
              buttonColor,
              buttonColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 30,
            height: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

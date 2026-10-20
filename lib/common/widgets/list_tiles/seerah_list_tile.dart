import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/single_line_title_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeerahListTile extends StatelessWidget {
  const SeerahListTile({
    super.key,
    required this.title,
    required this.isUrdu,
    required this.onTap,
  });

  final String title;
  final bool isUrdu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const leftTextStyle = TextStyle(
      fontSize: 16,
      color: Colors.black,
      height: 1.25,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Tooltip(
        message: title,
        triggerMode: TooltipTriggerMode.longPress,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE6F0EF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0x24000000),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            minTileHeight: 70,
            title: SingleLineTitleText(
              title: title,
              style: isUrdu
                  ? GoogleFonts.notoNastaliqUrdu(
                      fontSize: 18,
                      color: Colors.black,
                      height: 1.6,
                    )
                  : leftTextStyle,
              textDirection:
                  TextDirectionUtils.directionFor(isUrdu ? 'ur' : 'en'),
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

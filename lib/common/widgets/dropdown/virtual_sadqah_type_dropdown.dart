import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VirtualSadqahTypeDropdown extends StatefulWidget {
  final String? selectedValue;
  final List<String> options;
  final ValueChanged<String> onTypeSelected;
  final ValueChanged<bool> onCustomTypeVisibility;

  const VirtualSadqahTypeDropdown({
    super.key,
    this.selectedValue,
    required this.options,
    required this.onTypeSelected,
    required this.onCustomTypeVisibility,
  });

  @override
  State<VirtualSadqahTypeDropdown> createState() =>
      _VirtualSadqahTypeDropdownState();
}

class _VirtualSadqahTypeDropdownState extends State<VirtualSadqahTypeDropdown> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final selectedText = widget.selectedValue ?? 'Major Azkar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border.all(color: const Color(0xFFC3BEBE).withOpacity(0.6)),
              borderRadius: isOpen
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    )
                  : BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedText,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF808080).withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedRotation(
                  turns: isOpen ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    'assets/icons/arrow2.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border.all(color: const Color(0xFFC3BEBE).withOpacity(0.6)),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Column(
              children: widget.options.map((opt) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      isOpen = false;
                    });
                    widget.onTypeSelected(opt);
                    widget
                        .onCustomTypeVisibility(opt.toLowerCase() == 'others');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

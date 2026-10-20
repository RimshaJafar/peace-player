import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhysicalSadqahDropdown extends StatefulWidget {
  final String? selectedValue;
  final Function(String) onAccountSelected;
  final List<Map<String, String>> accountOptions;

  const PhysicalSadqahDropdown({
    super.key,
    this.selectedValue,
    required this.onAccountSelected,
    required this.accountOptions,
  });

  @override
  State<PhysicalSadqahDropdown> createState() => _PhysicalSadqahDropdownState();
}

class _PhysicalSadqahDropdownState extends State<PhysicalSadqahDropdown> {
  late bool isDropdownOpen;

  @override
  void initState() {
    super.initState();
    isDropdownOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Type',
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF000000).withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              isDropdownOpen = !isDropdownOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFC3BEBE).withOpacity(0.6),
              ),
              borderRadius: isDropdownOpen
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    )
                  : BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                if (widget.selectedValue != null) ...[
                  Image.asset(
                    widget.accountOptions.firstWhere((option) =>
                        option['text'] == widget.selectedValue)['icon']!,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.selectedValue ?? 'Select account',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: widget.selectedValue != null
                          ? Colors.black
                          : const Color(0xFF808080).withOpacity(0.6),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isDropdownOpen ? 0.25 : 0,
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
        if (isDropdownOpen) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFC3BEBE).withOpacity(0.6),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Column(
              children: widget.accountOptions.map((option) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      isDropdownOpen = false;
                    });
                    widget.onAccountSelected(option['text']!);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: option == widget.accountOptions.last
                              ? Colors.transparent
                              : const Color(0xFFC3BEBE).withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          option['icon']!,
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option['text']!,
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
      ],
    );
  }
}

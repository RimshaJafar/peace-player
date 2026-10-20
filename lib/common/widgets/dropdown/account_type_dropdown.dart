import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountTypeDropdown extends StatefulWidget {
  final String? selectedValue;
  final Function(String) onAccountTypeSelected;
  final List<Map<String, String>> accountTypeOptions;

  const AccountTypeDropdown({
    super.key,
    this.selectedValue,
    required this.onAccountTypeSelected,
    required this.accountTypeOptions,
  });

  @override
  State<AccountTypeDropdown> createState() => _AccountTypeDropdownState();
}

class _AccountTypeDropdownState extends State<AccountTypeDropdown> {
  late bool isDropdownOpen;

  @override
  void initState() {
    super.initState();
    isDropdownOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    // Find the icon for the selected value
    final selectedOption = widget.accountTypeOptions.firstWhere(
      (option) => option['text'] == widget.selectedValue,
      orElse: () => {},
    );
    final selectedIcon = selectedOption['icon'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                if (selectedIcon != null) ...[
                  Image.asset(
                    selectedIcon,
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.selectedValue ?? 'Select Account Type',
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
              children: widget.accountTypeOptions
                  .where((option) => option['text'] != widget.selectedValue)
                  .map((option) {
                final type = option['text']!;
                final icon = option['icon'];
                final isLast = option ==
                    widget.accountTypeOptions
                        .where((o) => o['text'] != widget.selectedValue)
                        .last;
                return InkWell(
                  onTap: () {
                    setState(() {
                      isDropdownOpen = false;
                    });
                    widget.onAccountTypeSelected(type);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isLast
                              ? Colors.transparent
                              : const Color(0xFFC3BEBE).withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Image.asset(
                            icon,
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            type,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF808080),
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

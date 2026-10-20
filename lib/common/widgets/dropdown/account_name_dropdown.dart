import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountNameDropdown extends StatefulWidget {
  final String? selectedValue;
  final Function(String) onAccountNameSelected;
  final List<String> accountNameOptions;

  const AccountNameDropdown({
    super.key,
    this.selectedValue,
    required this.onAccountNameSelected,
    required this.accountNameOptions,
  });

  @override
  State<AccountNameDropdown> createState() => _AccountNameDropdownState();
}

class _AccountNameDropdownState extends State<AccountNameDropdown> {
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
                Expanded(
                  child: Text(
                    widget.selectedValue ?? 'Select Name',
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
              children: widget.accountNameOptions
                  .where((name) => name != 'Select Name')
                  .map((name) {
                final isLast = name ==
                    widget.accountNameOptions
                        .where((n) => n != 'Select Name')
                        .last;
                return InkWell(
                  onTap: () {
                    setState(() {
                      isDropdownOpen = false;
                    });
                    widget.onAccountNameSelected(name);
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
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF808080),
                            ),
                          ),
                        ),
                        if (name != 'Select Name') ...[
                          GestureDetector(
                            onTap: () {
                              // Handle edit action
                            },
                            child: Image.asset(
                              'assets/icons/edit1.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              // Handle delete action
                            },
                            child: Image.asset(
                              'assets/icons/delete.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ],
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

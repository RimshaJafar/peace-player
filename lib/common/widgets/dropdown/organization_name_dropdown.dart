import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganizationNameDropdown extends StatefulWidget {
  final String? selectedValue;
  final Function(String) onOrganizationSelected;
  final List<String> organizationOptions;

  const OrganizationNameDropdown({
    super.key,
    this.selectedValue,
    required this.onOrganizationSelected,
    required this.organizationOptions,
  });

  @override
  State<OrganizationNameDropdown> createState() =>
      _OrganizationNameDropdownState();
}

class _OrganizationNameDropdownState extends State<OrganizationNameDropdown> {
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
                    widget.selectedValue ?? 'Select Organization',
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
              children: widget.organizationOptions.map((organization) {
                final isSelected = organization == widget.selectedValue;
                return InkWell(
                  onTap: () {
                    setState(() {
                      isDropdownOpen = false;
                    });
                    widget.onOrganizationSelected(organization);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFD2E3D9) : Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: organization == widget.organizationOptions.last
                              ? Colors.transparent
                              : const Color(0xFFC3BEBE).withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (organization == 'Add New') ...[
                          Image.asset(
                            'assets/icons/add1.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            organization,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: organization == 'Add New'
                                  ? FontWeight.w600
                                  : FontWeight.w400,
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

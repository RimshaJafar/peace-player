import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmountDropdown extends StatefulWidget {
  final String? selectedValue;
  final Function(String) onAmountSelected;
  final Function(bool) onCustomAmountVisibility;
  final List<String> amountOptions;

  const AmountDropdown({
    super.key,
    this.selectedValue,
    required this.onAmountSelected,
    required this.onCustomAmountVisibility,
    required this.amountOptions,
  });

  @override
  State<AmountDropdown> createState() => _AmountDropdownState();
}

class _AmountDropdownState extends State<AmountDropdown> {
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
                    widget.selectedValue ?? '0',
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
              borderRadius: widget.selectedValue == 'custom'
                  ? BorderRadius.zero
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
            ),
            child: Column(
              children: widget.amountOptions.map((amount) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      isDropdownOpen = false;
                    });
                    widget.onAmountSelected(amount);
                    widget.onCustomAmountVisibility(amount == 'custom');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: amount == widget.amountOptions.last
                              ? Colors.transparent
                              : const Color(0xFFC3BEBE).withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            amount,
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

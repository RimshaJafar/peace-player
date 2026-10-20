import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZakatEntryField extends StatefulWidget {
  final String label;
  final int initialQuantity;
  final TextEditingController? priceController;
  final ValueChanged<int>? onQuantityChanged;
  final ValueChanged<String>? onPriceChanged;

  const ZakatEntryField({
    super.key,
    required this.label,
    this.initialQuantity = 0,
    this.priceController,
    this.onQuantityChanged,
    this.onPriceChanged,
  });

  @override
  State<ZakatEntryField> createState() => _ZakatEntryFieldState();
}

class _ZakatEntryFieldState extends State<ZakatEntryField> {
  late int quantity;
  late final TextEditingController _priceController;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
    _ownsController = widget.priceController == null;
    _priceController = widget.priceController ?? TextEditingController();
    _priceController.addListener(() {
      widget.onPriceChanged?.call(_priceController.text);
    });
  }

  @override
  void dispose() {
    if (_ownsController) {
      _priceController.dispose();
    }
    super.dispose();
  }

  void _changeQuantity(int delta) {
    setState(() {
      quantity = (quantity + delta).clamp(0, 999999);
    });
    widget.onQuantityChanged?.call(quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF000000).withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: const Color(0xFFC3BEBE).withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _changeQuantity(-1),
                      child: Image.asset(
                        'assets/icons/decrease.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      quantity.toString(),
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _changeQuantity(1),
                      child: Image.asset(
                        'assets/icons/increase.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: const Color(0xFFC3BEBE).withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  height: 24,
                  child: TextField(
                    controller: _priceController,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'price',
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF808080).withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium dropdown selector (FIXED VERSION)
class PdfDropdownSelector<T> extends StatelessWidget {
  const PdfDropdownSelector({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.allowCustom = false,
    this.customHint,
    this.onCustomSubmitted,
  });

  final String label;
  final T value;
  final List<PdfDropdownItem<T>> items;
  final ValueChanged<T> onChanged;
  final IconData? icon;
  final bool allowCustom;
  final String? customHint;
  final ValueChanged<String>? onCustomSubmitted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ─── LABEL ─────────────────────────────
            Row(
              children: <Widget>[
                if (icon != null) ...[
                  Icon(icon, size: 18, color: const Color(0xFF3A6B5C)),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D4A42),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ─── DROPDOWN ─────────────────────────
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
                inputDecorationTheme: const InputDecorationTheme(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
              child: SizedBox(
                  width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: items.any((item) => item.value == value)
                          ? value
                          : null,
                         itemHeight: null,
                      isExpanded: true,
                      menuMaxHeight: 280, // ✅ FIX: prevents pixel overflow
                      borderRadius: BorderRadius.circular(14),
                      dropdownColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF4A7A6A),
                      ),

                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2D4A42),
                      ),

                      hint: Text(
                        'Select $label',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF8CA8A0),
                        ),
                      ),

                      // ─── ITEMS ───────────────────────
                      items: items.map((PdfDropdownItem<T> item) {
                        
                        return DropdownMenuItem<T>(
  value: item.value,
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: SizedBox(
      width: double.infinity,
      
      child: Row(
        children: <Widget>[
          if (item.leading != null) ...[
            item.leading!,
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  item.label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D4A42),
                  ),
                ),
                const SizedBox(height: 4),
                if (item.subtitle != null)
                  Text(
                    item.subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF7A9B91),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
                      }).toList(),

                      onChanged: (T? newValue) {
                        if (newValue != null) onChanged(newValue);
                      },
                    ),
                  ),
                ),
              ),
            ),

            // ─── CUSTOM INPUT ─────────────────────
            if (allowCustom) ...[
              const SizedBox(height: 12),
              _CustomInputField(
                hint: customHint ?? 'Enter custom value',
                onSubmitted: onCustomSubmitted,
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Dropdown item model
class PdfDropdownItem<T> {
  const PdfDropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.leading,
  });

  final T value;
  final String label;
  final String? subtitle;
  final Widget? leading;
}

/// ─────────────────────────────────────────────
/// CUSTOM INPUT FIELD (FIXED UI)
/// ─────────────────────────────────────────────
class _CustomInputField extends StatefulWidget {
  const _CustomInputField({
    required this.hint,
    this.onSubmitted,
  });

  final String hint;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<_CustomInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF2D4A42),
              ),
              decoration: InputDecoration(
  hintText: widget.hint,

  hintStyle: GoogleFonts.poppins(
    fontSize: 14,
    color: const Color(0xFFA0B8B0),
  ),

  filled: true,
  fillColor: Colors.white,

  // ❌ NO DEFAULT BORDER
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),

  // ❌ WHEN NOT FOCUSED
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),

  // ✅ WHEN FOCUSED (GREEN BORDER)
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(
      color: Color(0xFF1A5B48), // dark green
      width: 2,
    ),
  ),

  contentPadding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 14,
  ),
),
              onSubmitted: (String value) {
                if (value.isNotEmpty && widget.onSubmitted != null) {
                  widget.onSubmitted!(value);
                  _controller.clear();
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            final String value = _controller.text.trim();
            if (value.isNotEmpty && widget.onSubmitted != null) {
              widget.onSubmitted!(value);
              _controller.clear();
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1A5B48),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final double borderRadius;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onLeadingIconTap;
  final VoidCallback? onTrailingIconTap;
  final bool readOnly;
  final bool showTrailingIcon;

  const CustomSearchBar({
    Key? key,
    this.hintText = 'search map',
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.width = 360,
    this.height = 60,
    this.borderRadius = 20,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onLeadingIconTap,
    this.onTrailingIconTap,
    this.readOnly = false,
    this.showTrailingIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: GestureDetector(
              onTap: onLeadingIconTap,
              behavior: HitTestBehavior.opaque,
              child: Image.asset(
                'assets/icons/search-interface-symbol (2).png',
                width: 24,
                height: 24,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              readOnly: readOnly,
              enableInteractiveSelection: false,
              textAlignVertical: TextAlignVertical.center,
              controller: controller,
              onChanged: onChanged,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hintText,
                isDense: true,
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.6),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
          if (showTrailingIcon)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 50,
                height: height,
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: onTrailingIconTap,
                  behavior: HitTestBehavior.opaque,
                  child: Image.asset(
                    'assets/icons/mic.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';

class PCheckBoxTheme {
  PCheckBoxTheme._();

  static CheckboxThemeData lightCheckBoxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.transparent;
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return PColors.primary; // Use your brand primary color
      }
      return PColors.lightGrey; // Optional: border color when unchecked
    }),
    side: const BorderSide(color: PColors.primary, width: 1.5),
  );
}

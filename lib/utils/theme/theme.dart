import 'package:ecommerce_app/utils/theme/widget_themes/appbar_theme.dart';
import 'package:ecommerce_app/utils/theme/widget_themes/bottom_sheet_theme.dart';
import 'package:ecommerce_app/utils/theme/widget_themes/checkbox_theme.dart';
import 'package:ecommerce_app/utils/theme/widget_themes/chip_theme.dart';
import 'package:ecommerce_app/utils/theme/widget_themes/elevated_button_theme.dart';
import 'package:ecommerce_app/utils/theme/widget_themes/outlined_button_theme.dart';
import 'package:ecommerce_app/utils/theme/widget_themes/text_field_theme.dart';
import 'package:ecommerce_app/utils/theme/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';

class PAppTheme {
  PAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: PTextTheme.lightTextTheme,
    appBarTheme: PAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: PBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: PCheckBoxTheme.lightCheckBoxTheme,
    chipTheme: PChipTheme.lightChipTheme,
    elevatedButtonTheme: PElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: POutlinedButtonTheme.lightOutlineddButtonTheme,
    inputDecorationTheme: PTextFieldTheme.lightInputDecorationTheme,
  );
}

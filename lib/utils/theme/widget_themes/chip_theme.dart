import 'package:flutter/material.dart';

class PChipTheme {
  PChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
      disabledColor: Color.fromRGBO(255, 255, 255, 0.4),
      labelStyle: const TextStyle(color: Colors.black),
      selectedColor: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      checkmarkColor: Colors.white);
}

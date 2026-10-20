import 'package:flutter/material.dart';

class TextDirectionUtils {
  static const Set<String> _rtlLangs = {'ar', 'ur', 'fa', 'he'};

  static TextDirection directionFor(String? languageCode) {
    if (languageCode == null) return TextDirection.ltr;
    return _rtlLangs.contains(languageCode.toLowerCase())
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  static TextAlign alignFor(String? languageCode) {
    return directionFor(languageCode) == TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left;
  }
}

import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:flutter/material.dart';

class DirectionText extends StatelessWidget {
  final String text;
  final String? languageCode;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? textScaleFactor;
  final bool? softWrap;
  final StrutStyle? strutStyle;

  const DirectionText(
    this.text, {
    super.key,
    this.languageCode,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.textScaleFactor,
    this.softWrap,
    this.strutStyle,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = languageCode ?? AppLanguageHelper.textLanguageCode();
    final direction = TextDirectionUtils.directionFor(langCode);
    final align = textAlign ?? TextDirectionUtils.alignFor(langCode);
    return Directionality(
      textDirection: direction,
      child: Text(
        text,
        style: style,
        textAlign: align,
        overflow: overflow,
        maxLines: maxLines,
        textScaleFactor: textScaleFactor,
        softWrap: softWrap,
        strutStyle: strutStyle,
      ),
    );
  }
}

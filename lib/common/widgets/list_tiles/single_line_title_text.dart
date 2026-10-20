import 'package:flutter/material.dart';

class SingleLineTitleText extends StatelessWidget {
  const SingleLineTitleText({
    super.key,
    required this.title,
    required this.style,
    this.textAlign,
    this.textDirection,
  });

  final String title;
  final TextStyle style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: style,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }
}

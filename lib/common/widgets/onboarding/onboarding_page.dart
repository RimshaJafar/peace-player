import 'package:ecommerce_app/common/widgets/auth/gradient_title.dart';
import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  final String image, title, subTitle;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final isCompact = screenHeight < 720;
        final isShort = screenHeight < 650;
        final topGap = isCompact
            ? (screenHeight * 0.06)
                .clamp(32.0, isShort ? 42.0 : 50.0)
                .toDouble()
            : (screenHeight * 0.11).clamp(76.0, 104.0).toDouble();
        final imageHeight = isCompact
            ? (screenHeight * 0.285)
                .clamp(170.0, isShort ? 198.0 : 238.0)
                .toDouble()
            : (screenHeight * 0.405).clamp(288.0, 376.0).toDouble();
        final titleSize = isShort ? 25.5 : (isCompact ? 30.0 : 32.0);
        final subtitleSize = isShort ? 13.5 : (isCompact ? 14.0 : 15.0);
        final horizontalPadding = screenWidth < 380 ? 26.0 : 34.0;
        final imageTopInset = isShort ? 28.0 : (isCompact ? 30.0 : 36.0);
        final bottomControlsSpace =
            isShort ? 112.0 : (isCompact ? 124.0 : 146.0);

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            bottomControlsSpace,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: topGap),
              Flexible(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: imageHeight),
                    child: Padding(
                      padding: EdgeInsets.only(top: imageTopInset),
                      child: Image.asset(
                        image,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isShort ? 14 : (isCompact ? 18 : 30)),
              GradientTitle(
                text: title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  height: 1.16,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: isShort ? 8 : (isCompact ? 12 : 20)),
              Text(
                subTitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF8A9492),
                  fontFamily: 'Poppins',
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

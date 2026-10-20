import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';

class CustomDistanceSelector extends StatefulWidget {
  final Color backgroundColor;
  final Color textColor;
  final Gradient? buttonGradient;
  final double width;
  final double height;
  final double borderRadius;
  final int initialDistance;
  final Function(int) onDistanceChanged;
  final int minDistance;
  final int maxDistance;

  const CustomDistanceSelector({
    Key? key,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF808080),
    this.buttonGradient,
    this.width = 360,
    this.height = 60,
    this.borderRadius = 20,
    this.initialDistance = 3,
    required this.onDistanceChanged,
    this.minDistance = 1,
    this.maxDistance = 50,
  }) : super(key: key);

  @override
  State<CustomDistanceSelector> createState() => _CustomDistanceSelectorState();
}

class _CustomDistanceSelectorState extends State<CustomDistanceSelector> {
  late int _distance;

  @override
  void initState() {
    super.initState();
    _distance = widget.initialDistance;
  }

  @override
  void didUpdateWidget(covariant CustomDistanceSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDistance != widget.initialDistance &&
        _distance != widget.initialDistance) {
      _distance = widget.initialDistance;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMin = _distance <= widget.minDistance;
    final isMax = _distance >= widget.maxDistance;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: isMin ? 0.4 : 1,
            child: GestureDetector(
              onTap: isMin
                  ? null
                  : () {
                      setState(() {
                        _distance--;
                        widget.onDistanceChanged(_distance);
                      });
                    },
              child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.buttonGradient ?? PColors.linearGradient,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/minus.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              '$_distance km',
              style: TextStyle(
                color: widget.textColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Opacity(
            opacity: isMax ? 0.4 : 1,
            child: GestureDetector(
              onTap: isMax
                  ? null
                  : () {
                      setState(() {
                        _distance++;
                        widget.onDistanceChanged(_distance);
                      });
                    },
              child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.buttonGradient ?? PColors.linearGradient,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/plus.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Small gradient icon button used inside dialogs (matches inline implementation exactly).
class DialogGradientIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double iconSize;
  final double fontSize;
  final double borderRadius;

  const DialogGradientIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.width = 80,
    this.iconSize = 18,
    this.fontSize = 12,
    this.borderRadius = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF60BEA8),
            Color(0xFF329070),
            Color(0xFF1C5D4E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: iconSize, color: Colors.white),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: fontSize),
        ),
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          padding:
              WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius)),
          ),
          side: WidgetStateProperty.all(BorderSide.none),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.focused) ||
                  states.contains(WidgetState.pressed)) {
                return Colors.transparent;
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}

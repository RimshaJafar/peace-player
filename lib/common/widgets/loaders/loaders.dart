import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

enum _SnackBarType { success, warning, error }

/// Centralized app snackbars for success, warning, and error feedback.
class PLoaders {
  static const _defaultDuration = Duration(seconds: 3);

  /// Show a success snackbar.
  static void successSnackBar({
    required String title,
    required String message,
    int duration = 3,
    BuildContext? context,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      type: _SnackBarType.success,
      title: title,
      message: message,
      duration: Duration(seconds: duration),
      context: context,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show a warning snackbar.
  static void warningSnackBar({
    required String title,
    required String message,
    int duration = 3,
    BuildContext? context,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      type: _SnackBarType.warning,
      title: title,
      message: message,
      duration: Duration(seconds: duration),
      context: context,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show an error snackbar.
  static void errorSnackBar({
    required String title,
    required String message,
    int duration = 3,
    BuildContext? context,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      type: _SnackBarType.error,
      title: title,
      message: message,
      duration: Duration(seconds: duration),
      context: context,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _show({
    required _SnackBarType type,
    required String title,
    required String message,
    Duration duration = _defaultDuration,
    BuildContext? context,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final config = _configFor(type);
    final cleanTitle = title.trim();
    final cleanMessage = message.trim();
    final ctx = context ?? Get.context;

    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: _SnackBarContent(
            title: cleanTitle,
            message: cleanMessage,
            icon: config.icon,
            accentColor: config.color,
          ),
          backgroundColor: PColors.black,
          elevation: 10,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: config.color.withOpacity(0.24)),
          ),
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: config.color,
                  onPressed: onAction,
                )
              : null,
        ),
      );
    } else {
      Get.snackbar(
        cleanTitle,
        cleanMessage,
        isDismissible: true,
        shouldIconPulse: false,
        colorText: Colors.white,
        backgroundColor: PColors.black,
        borderColor: config.color.withOpacity(0.24),
        borderWidth: 1,
        borderRadius: 8,
        snackPosition: SnackPosition.BOTTOM,
        duration: duration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        icon: Icon(config.icon, color: config.color),
      );
    }
  }

  static _SnackBarConfig _configFor(_SnackBarType type) {
    switch (type) {
      case _SnackBarType.success:
        return const _SnackBarConfig(
          color: PColors.success,
          icon: Iconsax.tick_circle,
        );
      case _SnackBarType.warning:
        return const _SnackBarConfig(
          color: PColors.warning,
          icon: Iconsax.warning_2,
        );
      case _SnackBarType.error:
        return const _SnackBarConfig(
          color: PColors.error,
          icon: Iconsax.close_circle,
        );
    }
  }

}

class _SnackBarConfig {
  const _SnackBarConfig({
    required this.color,
    required this.icon,
  });

  final Color color;
  final IconData icon;
}

class _SnackBarContent extends StatelessWidget {
  const _SnackBarContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.16),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              if (message.isNotEmpty) ...[
                if (title.isNotEmpty) const SizedBox(height: 3),
                Text(
                  message,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE8F0ED),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:ecommerce_app/utils/device/device_utility.dart';
import 'package:flutter/material.dart';

class PAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle,
    this.gradient,
    this.backgroundColor,
    this.backgroundTransparent = false,
    this.showBackArrow = false,
    this.leadingWidth,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool backgroundTransparent;
  final bool showBackArrow;

  final double? leadingWidth;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: leadingWidth,
        leading: showBackArrow
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : leading,
        title: title,
        centerTitle: centerTitle,
        actions: actions,
        backgroundColor: gradient != null
            ? Colors.transparent
            : (backgroundColor ?? Colors.grey),
        elevation: gradient != null ? 0 : null,
        foregroundColor: gradient != null ? Colors.white : null,
        iconTheme:
            gradient != null ? const IconThemeData(color: Colors.white) : null,
        flexibleSpace: gradient != null
            ? Container(decoration: BoxDecoration(gradient: gradient))
            : null,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(PDeviceUtils.getAppBarHeight());
}

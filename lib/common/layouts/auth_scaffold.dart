import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/spacing/spacing_styles.dart';

class AuthScaffold extends StatelessWidget {
  final Widget? header;
  final List<Widget> children;
  final Widget? footer; // new
  final EdgeInsets? padding;
  final bool resizeToAvoidBottomInset;

  const AuthScaffold({
    super.key,
    this.header,
    this.children = const [],
    this.footer, // new
    this.padding,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: Padding(
          padding: padding ?? PSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              // header (if any)
              if (header != null) header!,

              // flexible scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: viewInsets > 0
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight -
                          MediaQuery.of(context).padding.top -
                          (header != null ? 0 : 0),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Put all body children here
                          ...children,
                          // Keep a small spacer above footer so content doesn't touch it
                          SizedBox(height: viewInsets > 0 ? 20 : 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // footer (anchored below scrollable content)
              if (footer != null)
                SafeArea(
                  top: false,
                  child: footer!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

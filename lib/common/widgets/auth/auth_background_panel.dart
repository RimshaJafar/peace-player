import 'dart:math' as math;

import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';

class AuthBackgroundPanel extends StatelessWidget {
  const AuthBackgroundPanel({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.centerContent = false,
    this.maxWidth = 480,
    this.panelRadius = 26,
    this.scrollAreaTopInset,
    this.outerPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
    this.contentPadding = const EdgeInsets.fromLTRB(26, 72, 26, 32),
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final bool centerContent;
  final double maxWidth;
  final double panelRadius;

  /// The protected top boundary reached progressively while content scrolls.
  /// At rest, content keeps its normal position without an empty header gap.
  final double? scrollAreaTopInset;
  final EdgeInsetsGeometry outerPadding;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final resolvedOuterPadding =
        outerPadding.resolve(Directionality.of(context));
    final resolvedContentPadding =
        contentPadding.resolve(Directionality.of(context));
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    const actionInset = 22.0;

    return Scaffold(
      // Keep the mosque artwork at its full size. The content viewport handles
      // the keyboard inset independently so the background never jumps or
      // resizes when the keyboard opens.
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFEFF7F4),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final protectedTopInset = math.max(
              resolvedContentPadding.top,
              scrollAreaTopInset ?? resolvedContentPadding.top,
            );
            final maximumKeyboardInset = math.max(
              0.0,
              constraints.maxHeight -
                  resolvedOuterPadding.vertical -
                  resolvedContentPadding.vertical,
            );
            final effectiveKeyboardInset = math.min(
              keyboardInset,
              maximumKeyboardInset,
            );
            final contentMinHeight = math.max(
              0.0,
              constraints.maxHeight -
                  resolvedOuterPadding.vertical -
                  resolvedContentPadding.vertical -
                  effectiveKeyboardInset,
            );

            Widget panelContent = child;
            if (centerContent) {
              panelContent = ConstrainedBox(
                constraints: BoxConstraints(minHeight: contentMinHeight),
                child: Center(child: child),
              );
            } else {
              panelContent = ConstrainedBox(
                constraints: BoxConstraints(minHeight: contentMinHeight),
                child: child,
              );
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: resolvedOuterPadding,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(panelRadius),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF1C5D4E).withValues(alpha: 0.12),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(panelRadius),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              PImages.mosqueBackground,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.03),
                                    Colors.white.withValues(alpha: 0.36),
                                    Colors.white.withValues(alpha: 0.08),
                                  ],
                                  stops: const [0, 0.58, 1],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  left: resolvedOuterPadding.left +
                      resolvedContentPadding.left,
                  top: resolvedOuterPadding.top + resolvedContentPadding.top,
                  right: resolvedOuterPadding.right +
                      resolvedContentPadding.right,
                  bottom: resolvedOuterPadding.bottom +
                      resolvedContentPadding.bottom +
                      effectiveKeyboardInset,
                  child: _ProtectedScrollable(
                    maximumTopClip:
                        protectedTopInset - resolvedContentPadding.top,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: panelContent,
                      ),
                    ),
                  ),
                ),
                if (leading != null)
                  PositionedDirectional(
                    start: resolvedOuterPadding.left + actionInset,
                    top: resolvedOuterPadding.top + actionInset,
                    child: leading!,
                  ),
                if (trailing != null)
                  PositionedDirectional(
                    end: resolvedOuterPadding.right + actionInset,
                    top: resolvedOuterPadding.top + actionInset,
                    child: trailing!,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProtectedScrollable extends StatefulWidget {
  const _ProtectedScrollable({
    required this.child,
    required this.maximumTopClip,
  });

  final Widget child;
  final double maximumTopClip;

  @override
  State<_ProtectedScrollable> createState() => _ProtectedScrollableState();
}

class _ProtectedScrollableState extends State<_ProtectedScrollable> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final scrollOffset = _scrollController.hasClients
            ? math.max(0.0, _scrollController.offset)
            : 0.0;
        final activationDistance = math.max(1.0, widget.maximumTopClip);
        final progress = (scrollOffset / activationDistance).clamp(0.0, 1.0);
        final topClip = widget.maximumTopClip *
            Curves.easeOutCubic.transform(progress.toDouble());

        return ClipRect(
          clipper: _TopInsetClipper(topInset: topClip),
          child: child,
        );
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: widget.child,
      ),
    );
  }
}

class _TopInsetClipper extends CustomClipper<Rect> {
  const _TopInsetClipper({required this.topInset});

  final double topInset;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      0,
      topInset.clamp(0.0, size.height).toDouble(),
      size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(_TopInsetClipper oldClipper) {
    return oldClipper.topInset != topInset;
  }
}

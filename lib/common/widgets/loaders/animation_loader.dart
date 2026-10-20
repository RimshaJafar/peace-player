import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PAnimationLoaderWidget extends StatelessWidget {
  const PAnimationLoaderWidget({
    super.key,
    required this.text,
    required this.animation,
    this.showAction = false,
    this.actionText,
    this.onActionPressed,
  });

  final String text;
  final String animation;
  final bool showAction;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display Lottie animation
          Lottie.asset(
            animation,
            width: MediaQuery.of(context).size.width * 0.8,
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Optional Action Button
          showAction
              ? SizedBox(
                  width: 250,
                  child: OutlinedButton(
                    onPressed: onActionPressed,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: Text(
                      actionText ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.apply(
                            color: Colors.white,
                          ),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

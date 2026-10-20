import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';

/// Reusable boycott product card container used on the boycott products screen.
class BoycottProductContainer extends StatelessWidget {
  const BoycottProductContainer({
    super.key,
    required this.productName,
    required this.imagePath,
    required this.country,
    this.onViewDetailsTap,
  });

  final String productName;
  final String imagePath;
  final String country;
  final VoidCallback? onViewDetailsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1.0);
          final isTightWidth = constraints.maxWidth < 340;
          final cardHeight =
              isTightWidth || textScale > 1.15 ? 160.0 : 147.0;
          final imageWidth =
              (constraints.maxWidth * 0.34).clamp(96.0, 130.0).toDouble();
          final imageHeight = (cardHeight - 24).clamp(112.0, 146.0).toDouble();

          return Container(
            width: double.infinity,
            height: cardHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFD2E3DF),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                Row(
                  children: [
                    /// Product Image Container
                    Container(
                      width: imageWidth,
                      height: imageHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imagePath,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                          errorBuilder: (context, error, stack) => const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    /// Product Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          /// Product Name
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A4D2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),

                          /// Country Info Row
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  country,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF444444),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 32,
                                height: 22,
                                child: Image.asset(
                                  'assets/images/content/${country.toLowerCase()}.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stack) =>
                                      const SizedBox(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                /// View Details Button with Gradient - Bottom Right
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: PColors.linearGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onViewDetailsTap,
                        borderRadius: BorderRadius.circular(25),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/boycott/controllers/boycott_controller.dart';
import 'package:ecommerce_app/features/boycott/models/boycott_model.dart';
import 'package:ecommerce_app/features/boycott/screens/boycott_products_alternative_screen.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BoycottProductDetailScreen extends StatefulWidget {
  const BoycottProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  final BoycottProductDetail product;

  @override
  State<BoycottProductDetailScreen> createState() =>
      _BoycottProductDetailScreenState();
}

class _BoycottProductDetailScreenState
    extends State<BoycottProductDetailScreen> {
  late final BoycottController boycottController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<BoycottController>()) {
      boycottController = Get.find<BoycottController>();
    } else {
      boycottController = Get.put(BoycottController());
    }
    boycottController.fetchProductAlternatives(widget.product.id);
  }

  Color _getBoycottLevelColor(String? level) {
    if (level == null) return const Color(0xFF1A4D2E);
    final lowerLevel = level.toLowerCase();
    if (lowerLevel.contains('low')) {
      return const Color.fromARGB(255, 218, 230, 55);
    } else if (lowerLevel.contains('medium')) {
      return const Color(0xFFF39C12);
    } else if (lowerLevel.contains('high')) {
      return const Color(0xFFE74C3C);
    }
    return const Color(0xFF1A4D2E);
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      PLoaders.errorSnackBar(
        title: 'Link Error',
        message: 'Could not launch URL',
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final double screenHeight = screenSize.height;
    final productImageWidth =
        (screenSize.width * 0.72).clamp(190.0, 260.0).toDouble();
    final productImageHeight =
        (productImageWidth * 0.85).clamp(170.0, 220.0).toDouble();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PAppBar(
        title: Text(
          'Product Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Center(
                  child: SizedBox(
                    width: productImageWidth,
                    height: productImageHeight,
                    child: Image.network(
                      widget.product.image,
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
                const SizedBox(height: 20),
                // Details Container
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: screenHeight * 0.65),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD2E3DF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Name
                      Center(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF1A4D2E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Country, Level, Category and Sub Category in White Container
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1A4D2E),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _ProductDetailRow(
                              label: 'Country',
                              value: widget.product.country,
                              icon: Icons.flag,
                            ),
                            const SizedBox(height: 18),
                            _ProductDetailRow(
                              label: 'Level',
                              value: widget.product.boycottLevel ?? 'N/A',
                              valueColor: _getBoycottLevelColor(
                                  widget.product.boycottLevel),
                            ),
                            const SizedBox(height: 18),
                            _ProductDetailRow(
                              label: 'Category',
                              value: widget.product.category,
                            ),
                            if (widget.product.subCategory.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              _ProductDetailRow(
                                label: 'Sub Category',
                                value: widget.product.subCategory,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Description
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: PColors.linearGradient,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            width: 3,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.product.description,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Alternatives
                      Obx(() {
                        if (boycottController.productAlternatives.isNotEmpty) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Alternatives',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A4D2E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GridView.count(
                                  crossAxisCount:
                                      PSizes.isTablet(context) ? 3 : 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  children: boycottController.productAlternatives
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final alt = entry.value;
                                    return GestureDetector(
                                      onTap: () {
                                        Get.to(() =>
                                            BoycottProductsAlternativeScreen(
                                              allAlternatives: boycottController
                                                  .productAlternatives
                                                  .toList(),
                                              initialIndex: index,
                                            ));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.08),
                                              blurRadius: 10,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 9),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                    color:
                                                        const Color(0xFFEFEFEF),
                                                    child: Image.network(
                                                      alt.image,
                                                      fit: BoxFit.contain,
                                                      loadingBuilder: (context,
                                                          child, progress) {
                                                        if (progress == null) {
                                                          return child;
                                                        }
                                                        return const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (context,
                                                              error, stack) =>
                                                          const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey,
                                                        size: 32,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              width: double.infinity,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                gradient:
                                                    PColors.linearGradient,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15),
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8),
                                              child: Center(
                                                child: Text(
                                                  alt.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      }),
                      // Subbrands
                      if (widget.product.subbrands.isNotEmpty) ...[
                        const Text(
                          'Subbrands',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A4D2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.product.subbrands.map((sub) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF444444),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      sub,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF444444),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 20),
                      ],
                      // References
                      if (widget.product.references.isNotEmpty) ...[
                        const Text(
                          'References',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A4D2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.product.references.map((ref) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () => _launchUrl(ref),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.link,
                                        color: Color(0xFF1A4D2E),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          ref,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF444444),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductDetailRow extends StatelessWidget {
  const _ProductDetailRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor = const Color(0xFF1A4D2E),
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: const Color(0xFF1A4D2E),
                  size: 20,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

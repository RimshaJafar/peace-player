import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/boycott/controllers/boycott_controller.dart';
import 'package:ecommerce_app/features/boycott/models/boycott_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BoycottProductsAlternativeScreen extends StatefulWidget {
  const BoycottProductsAlternativeScreen({
    required this.allAlternatives,
    required this.initialIndex,
    super.key,
  });

  final List<AlternativeProduct> allAlternatives;
  final int initialIndex;

  @override
  State<BoycottProductsAlternativeScreen> createState() =>
      _BoycottProductsAlternativeScreenState();
}

class _BoycottProductsAlternativeScreenState
    extends State<BoycottProductsAlternativeScreen> {
  late final BoycottController boycottController;
  late int _currentIndex;

  AlternativeProduct get currentProduct =>
      widget.allAlternatives[_currentIndex];
  int get totalAlternatives => widget.allAlternatives.length;

  String _flagFor(AlternativeProductDetail product) {
    final country = product.country.toLowerCase();
    if (country.contains('pakistan')) {
      return 'assets/images/content/pakistan.png';
    } else if (country.contains('united kingdom') || country.contains('uk')) {
      return 'assets/images/content/uk.png';
    } else {
      return 'assets/images/content/default.png';
    }
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
  void initState() {
    super.initState();
    if (Get.isRegistered<BoycottController>()) {
      boycottController = Get.find<BoycottController>();
    } else {
      boycottController = Get.put(BoycottController());
    }
    _currentIndex = widget.initialIndex;
    boycottController.fetchAlternativeDetail(currentProduct.slug);
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      boycottController.fetchAlternativeDetail(currentProduct.slug);
    }
  }

  void _goToNext() {
    if (_currentIndex < totalAlternatives - 1) {
      setState(() {
        _currentIndex++;
      });
      boycottController.fetchAlternativeDetail(currentProduct.slug);
    }
  }

  @override
  void didUpdateWidget(covariant BoycottProductsAlternativeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allAlternatives != widget.allAlternatives ||
        oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
      boycottController.fetchAlternativeDetail(currentProduct.slug);
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
          'Alternatives',
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
                Obx(() {
                  final detail = boycottController.alternativeDetail.value;
                  if (detail != null) {
                    return Center(
                      child: SizedBox(
                        width: productImageWidth,
                        height: productImageHeight,
                        child: Image.network(
                          detail.image,
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
                    );
                  } else {
                    return Center(
                      child: SizedBox(
                        width: productImageWidth,
                        height: productImageHeight,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  }
                }),
                const SizedBox(height: 20),
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
                  child: Obx(() {
                    final detail = boycottController.alternativeDetail.value;
                    if (detail != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Text(
                              detail.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A4D2E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                _AlternativeDetailRow(
                                  label: 'Country',
                                  value: detail.country,
                                  flagAsset: _flagFor(detail),
                                ),
                                const SizedBox(height: 18),
                                _AlternativeDetailRow(
                                  label: 'Category',
                                  value: detail.category,
                                ),
                                if (detail.subCategory.isNotEmpty) ...[
                                  const SizedBox(height: 18),
                                  _AlternativeDetailRow(
                                    label: 'Sub Category',
                                    value: detail.subCategory,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                  detail.description,
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
                          if (detail.subbrands.isNotEmpty) ...[
                            const Text(
                              'Subbrands',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A4D2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...detail.subbrands.map((sub) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                          if (detail.references.isNotEmpty) ...[
                            const Text(
                              'References',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A4D2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...detail.references.map((ref) => Padding(
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
                          if (totalAlternatives > 1) ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap:
                                      _currentIndex > 0 ? _goToPrevious : null,
                                  child: Container(
                                    width: 45,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: _currentIndex > 0
                                          ? PColors.linearGradient
                                          : null,
                                      color: _currentIndex > 0
                                          ? null
                                          : const Color(0xFFBDBDBD),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: _currentIndex > 0
                                          ? Colors.white
                                          : const Color(0xFF9E9E9E),
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: 60,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    gradient: PColors.linearGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${_currentIndex + 1}/$totalAlternatives',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: _currentIndex < totalAlternatives - 1
                                      ? _goToNext
                                      : null,
                                  child: Container(
                                    width: 45,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient:
                                          _currentIndex < totalAlternatives - 1
                                              ? PColors.linearGradient
                                              : null,
                                      color:
                                          _currentIndex < totalAlternatives - 1
                                              ? null
                                              : const Color(0xFFBDBDBD),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color:
                                          _currentIndex < totalAlternatives - 1
                                              ? Colors.white
                                              : const Color(0xFF9E9E9E),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlternativeDetailRow extends StatelessWidget {
  const _AlternativeDetailRow({
    required this.label,
    required this.value,
    this.flagAsset,
  });

  final String label;
  final String value;
  final String? flagAsset;

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
        Expanded(
          flex: 4,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (flagAsset != null) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    flagAsset!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => const Icon(
                      Icons.flag,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A4D2E),
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

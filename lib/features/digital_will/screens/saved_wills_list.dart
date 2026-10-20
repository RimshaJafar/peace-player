import 'dart:async';

import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/widgets/history_access_banner.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';
import 'package:ecommerce_app/features/digital_will/models/digital_will_response_model.dart';
import 'package:ecommerce_app/features/digital_will/models/saved_will_model.dart';
import 'package:ecommerce_app/features/digital_will/controllers/pdf_generation_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/controllers/external_service_controller.dart';
import 'package:ecommerce_app/common/models/country_model.dart';

import 'saved_will_detail.dart';

class SavedWillsListScreen extends StatefulWidget {
  const SavedWillsListScreen({super.key});

  @override
  State<SavedWillsListScreen> createState() => _SavedWillsListScreenState();
}

class _SavedWillsListScreenState extends State<SavedWillsListScreen> {
  final DigitalWillController controller = Get.find<DigitalWillController>();
  late final BillingController _billingController;
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _billingController = Get.isRegistered<BillingController>()
        ? Get.find<BillingController>()
        : Get.put(BillingController(), permanent: true);
    unawaited(_billingController.loadBillingProfile());
    _loadFuture = _loadWills();
  }

  Future<void> _loadWills() async {
    final ExternalServiceController externalController =
        Get.isRegistered<ExternalServiceController>()
            ? Get.find<ExternalServiceController>()
            : Get.put(ExternalServiceController());
    if (externalController.countries.isEmpty) {
      await externalController.fetchCountries();
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await controller.fetchWillHistory(firebaseUserId: user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Saved Wills',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFEAF5F1), Color(0xFFF8FBFA)],
          ),
        ),
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A5B48)),
              );
            }

            return Obx(
              () {
                if (controller.lastError.value != null &&
                    controller.lastError.value!.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Color(0xFFD32F2F),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading wills',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF174A3B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            controller.lastError.value ?? 'Unknown error',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: const Color(0xFF36574D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final User? user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  return Center(
                    child: Text(
                      'Please log in to view saved wills',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: const Color(0xFF174A3B),
                      ),
                    ),
                  );
                }

                // Fetch history again to ensure we have fresh data
                return FutureBuilder<SavedWillHistoryResponse?>(
                  future: controller.fetchWillHistory(firebaseUserId: user.uid),
                  builder: (context, historySnapshot) {
                    if (historySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF1A5B48)),
                      );
                    }

                    final SavedWillHistoryResponse? history =
                        historySnapshot.data;
                    if (history == null || history.items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open_outlined,
                              size: 64,
                              color: Colors.grey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No saved wills yet',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF174A3B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a new will to get started',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: const Color(0xFF36574D),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Obx(() {
                      final List<SavedWillItemResponse> visibleItems =
                          _billingController.isPro
                              ? history.items
                              : history.items.take(5).toList();

                      return SafeArea(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: visibleItems.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return const HistoryAccessBanner(
                                freeLabel: 'Latest 5 wills',
                                proLabel: 'Full will history',
                                freeDescription:
                                    'Upgrade for your complete will history.',
                                proDescription:
                                    'Your complete will history is available.',
                                upgradeMessage:
                                    'Free Plan keeps the latest 5 saved wills. Upgrade to Pro to view all wills and full will history.',
                                margin: EdgeInsets.only(bottom: 16),
                                accentColor: Color(0xFF1A5B48),
                              );
                            }

                            final SavedWillItemResponse item =
                                visibleItems[index - 1];
                            return SavedWillCard(
                              item: item,
                              countryName: item.countryJurisdiction,
                              onTap: () async {
                                final String firebaseUserId = item
                                        .firebaseUserId.isNotEmpty
                                    ? item.firebaseUserId
                                    : (FirebaseAuth.instance.currentUser?.uid ??
                                        '');
                                if (firebaseUserId.isEmpty) {
                                  return;
                                }

                                final DigitalWillCalculationResponse? detail =
                                    await controller.fetchWillDetail(
                                  savedRecordId: item.savedRecordId,
                                  firebaseUserId: firebaseUserId,
                                );
                                if (detail != null) {
                                  Get.to(
                                    SavedWillDetailScreen(
                                      response: detail,
                                      countryName: item.countryJurisdiction,
                                    ),
                                    transition: Transition.rightToLeft,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedViewDetails extends StatefulWidget {
  const _AnimatedViewDetails();

  @override
  State<_AnimatedViewDetails> createState() => _AnimatedViewDetailsState();
}

class _AnimatedViewDetailsState extends State<_AnimatedViewDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'View Details',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A5B48),
          ),
        ),
        const SizedBox(width: 4),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_controller.value * 5, 0),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF1A5B48),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SavedWillCard extends StatelessWidget {
  const SavedWillCard({
    required this.item,
    required this.countryName,
    required this.onTap,
    super.key,
  });

  final SavedWillItemResponse item;
  final String countryName;
  final VoidCallback onTap;

  String _formatCurrency(double value,
      {String? countryName, String? currencyCode}) {
    final String fixed = value.toStringAsFixed(2);
    final List<String> parts = fixed.split('.');
    final String whole = parts.first;
    final String decimal = parts.last;

    final StringBuffer formatted = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final int reverseIndex = whole.length - i;
      formatted.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        formatted.write(',');
      }
    }

    String symbol = '';
    String flag = '';
    String code = currencyCode ?? '';

    if ((countryName == null || countryName.isEmpty) &&
        Get.isRegistered<DigitalWillController>()) {
      countryName =
          Get.find<DigitalWillController>().basicInfo?.countryJurisdiction;
    }

    if (Get.isRegistered<ExternalServiceController>()) {
      final ext = Get.find<ExternalServiceController>();
      Country? country;
      if (countryName != null && countryName.isNotEmpty) {
        country = ext.getCountryByName(countryName);
      }
      if (country != null) {
        if (country.currencies.isNotEmpty) {
          symbol = country.currencies.values.first;
          code = country.currencies.keys.first;
        }
        if (country.code.isNotEmpty) {
          flag =
              ExternalServiceController.flagEmojiFromCountryCode(country.code);
        }
      } else {
        if (code.isEmpty && Get.isRegistered<PdfGenerationController>()) {
          code = Get.find<PdfGenerationController>().selectedCurrency.value;
        }
        if (code.isNotEmpty) {
          final extSymbol = ext.findCurrencySymbolByCode(code);
          if (extSymbol != null) symbol = extSymbol;
        }
      }
    } else {
      if (code.isEmpty && Get.isRegistered<PdfGenerationController>()) {
        code = Get.find<PdfGenerationController>().selectedCurrency.value;
      }
    }

    if (symbol.isEmpty) {
      const Map<String, String> fallback = {
        'PKR': 'Rs',
        'SAR': 'SAR',
        'USD': '\$',
        'AED': 'AED',
        'GBP': '£',
        'EUR': '€',
        'INR': '₹'
      };
      if (code.isNotEmpty && fallback.containsKey(code)) {
        symbol = fallback[code]!;
      }
    }
    if (symbol.isEmpty) symbol = 'SAR';

    String result = '$symbol ${formatted.toString()}.$decimal';
    if (flag.isNotEmpty) result = '$result $flag';
    return result;
  }

  String _formatDateTime(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final String formattedDate = '${date.day}/${date.month}/${date.year}';
      final String formattedTime =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return '$formattedDate at $formattedTime';
    } catch (e) {
      return dateString;
    }
  }

  String _displayExecutorValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Not provided';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDEAE5), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B3428).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with deceased name and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.deceasedGender.toLowerCase() == 'male'
                        ? Icons.person
                        : Icons.person,
                    color: const Color(0xFF114A3A),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.deceasedFullName,
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF174A3B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.deceasedGender,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: const Color(0xFF58776C),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _getStatusColor(item.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: const Color(0xFFDDEAE5),
            ),
            const SizedBox(height: 12),
            // Executor information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Executor Details',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Executor',
                  value: _displayExecutorValue(item.executorName),
                ),
                _InfoRow(
                  label: 'Contact',
                  value: _displayExecutorValue(item.executorContact),
                ),
                _InfoRow(
                  label: 'Country',
                  value: countryName.isNotEmpty ? countryName : 'Unknown',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date and time
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Created',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDateTime(item.createdAt),
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF174A3B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: const Color(0xFFDDEAE5),
            ),
            const SizedBox(height: 12),
            // Estate information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Final Estate',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: const Color(0xFF58776C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatCurrency(
                          item.finalEstateForDistribution,
                          countryName: countryName,
                        ),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF174A3B),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Distributed',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: const Color(0xFF58776C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatCurrency(
                          item.totalDistributed,
                          countryName: countryName,
                        ),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A5B48),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                _AnimatedViewDetails(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFFA500);
      case 'draft':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF58776C);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFF58776C),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF174A3B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

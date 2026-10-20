import 'dart:async';

import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/widgets/history_access_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/boycott/controllers/scan_history_controller.dart';
import 'package:ecommerce_app/features/boycott/models/scan_response_model.dart';
import 'package:ecommerce_app/features/boycott/screens/scanner_result_screen.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';

class ScannedProductsHistoryScreen extends StatefulWidget {
  const ScannedProductsHistoryScreen({super.key});

  @override
  State<ScannedProductsHistoryScreen> createState() =>
      _ScannedProductsHistoryScreenState();
}

class _ScannedProductsHistoryScreenState
    extends State<ScannedProductsHistoryScreen> {
  late ScanHistoryController _historyController;
  late final BillingController _billingController;
  String _firebaseUserId = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ScanHistoryController>()) {
      _historyController = Get.find<ScanHistoryController>();
    } else {
      _historyController = Get.put(ScanHistoryController());
    }
    _billingController = Get.isRegistered<BillingController>()
        ? Get.find<BillingController>()
        : Get.put(BillingController(), permanent: true);
    unawaited(_billingController.loadBillingProfile());

    try {
      final userController = Get.find<UserController>();
      _firebaseUserId = userController.user.value.id;
    } catch (_) {}

    if (_firebaseUserId.isNotEmpty) {
      _historyController.fetchHistory(_firebaseUserId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ScanHistoryItem> get _filteredItems {
    final List<ScanHistoryItem> visibleHistory = _billingController.isPro
        ? _historyController.historyItems.toList()
        : _historyController.historyItems.take(5).toList();
    if (_searchQuery.isEmpty) return visibleHistory;
    final q = _searchQuery.toLowerCase();
    return visibleHistory.where((item) {
      return (item.productName ?? '').toLowerCase().contains(q) ||
          (item.brand ?? '').toLowerCase().contains(q);
    }).toList();
  }

  /// Group items by date string
  Map<String, List<ScanHistoryItem>> _groupByDate(List<ScanHistoryItem> items) {
    final Map<String, List<ScanHistoryItem>> grouped = {};
    for (final item in items) {
      final dateKey = _formatDateKey(item.scannedAt);
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }
    return grouped;
  }

  String _formatDateKey(String? dateStr) {
    if (dateStr == null) return 'Unknown Date';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final itemDate = DateTime(dt.year, dt.month, dt.day);
      if (itemDate == today) return 'Today';
      if (itemDate == yesterday) return 'Yesterday';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Unknown Date';
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  Color _boycottLevelColor(String? level) {
    if (level == null) return Colors.grey;
    final l = level.toLowerCase();
    if (l.contains('high')) return const Color(0xFFE74C3C);
    if (l.contains('medium')) return const Color(0xFFF39C12);
    if (l.contains('low')) return const Color(0xFF27AE60);
    return Colors.grey;
  }

  void _openScanDetail(ScanHistoryItem item) async {
    await _historyController.fetchScanDetail(item.scanId);
    if (_historyController.selectedScan.value != null) {
      Get.to(() => ScannerResultScreen(
            scanResponse: _historyController.selectedScan.value!,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: PColors.linearGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Scan History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          // Refresh button
          Obx(() => IconButton(
                icon: _historyController.isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white, size: 22),
                onPressed: _firebaseUserId.isNotEmpty
                    ? () => _historyController.fetchHistory(_firebaseUserId)
                    : null,
              )),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search scanned products...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF329070)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.grey, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (_historyController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF329070),
                  ),
                );
              }

              if (_historyController.errorMessage.value.isNotEmpty) {
                return _buildErrorState(_historyController.errorMessage.value);
              }

              if (_firebaseUserId.isEmpty) {
                return _buildLoginRequired();
              }

              final filtered = _filteredItems;
              if (filtered.isEmpty) {
                return _buildEmptyState();
              }

              final grouped = _groupByDate(filtered);

              return RefreshIndicator(
                color: const Color(0xFF329070),
                onRefresh: () =>
                    _historyController.fetchHistory(_firebaseUserId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Total count badge
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF329070)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${filtered.length} scan${filtered.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: Color(0xFF329070),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const HistoryAccessBanner(
                      freeLabel: 'Latest 5 scans',
                      proLabel: 'Full scan history',
                      freeDescription:
                          'Upgrade for your complete scan history.',
                      proDescription:
                          'Your complete scan history is available.',
                      upgradeMessage:
                          'Free Plan keeps the latest 5 scan records. Upgrade to Pro to view all scans and full scanner history.',
                      margin: EdgeInsets.only(bottom: 12),
                      accentColor: Color(0xFF329070),
                    ),
                    // Grouped list
                    ...grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 4),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[600],
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          // Items
                          ...entry.value.map((item) => _buildHistoryCard(item)),
                          const SizedBox(height: 8),
                        ],
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ScanHistoryItem item) {
    final levelColor = _boycottLevelColor(item.boycottLevel);

    return Obx(() {
      final isLoadingThis = _historyController.isLoadingDetail.value;

      return GestureDetector(
        onTap: () => _openScanDetail(item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Left: boycott level indicator bar
                Container(
                  width: 4,
                  height: 56,
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                // Middle: product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName ?? 'Unknown Product',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (item.brand != null && item.brand!.isNotEmpty)
                        Text(
                          item.brand!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Boycott level chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: levelColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: levelColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              item.boycottLevel ?? 'Unknown',
                              style: TextStyle(
                                color: levelColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Confidence
                          if (item.confidence != null)
                            Text(
                              '${(item.confidence! * 100).toStringAsFixed(0)}% confidence',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Right: time + arrow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(item.scannedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    isLoadingThis
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF329070),
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Color(0xFF329070),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results for "$_searchQuery"'
                  : 'No scans yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Start scanning products to see your history here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFE74C3C)),
            const SizedBox(height: 16),
            const Text(
              'Failed to load history',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _historyController.fetchHistory(_firebaseUserId),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF329070),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Color(0xFF329070)),
            const SizedBox(height: 16),
            const Text(
              'Login Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please log in to view your scan history',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

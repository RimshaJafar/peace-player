import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/boycott/models/scan_response_model.dart';
import 'package:ecommerce_app/features/boycott/screens/boycott_scanner_screen.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';

class ScannerResultScreen extends StatefulWidget {
  final ScanResponse scanResponse;

  const ScannerResultScreen({Key? key, required this.scanResponse})
      : super(key: key);

  @override
  State<ScannerResultScreen> createState() => _ScannerResultScreenState();
}

class _ScannerResultScreenState extends State<ScannerResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _ocrExpanded = false;
  bool _detailsExpanded = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Color _boycottLevelColor(String? level) {
    if (level == null) return Colors.grey;
    final l = level.toLowerCase();
    if (l.contains('high')) return const Color(0xFFE74C3C);
    if (l.contains('medium')) return const Color(0xFFF39C12);
    if (l.contains('low')) return const Color(0xFF27AE60);
    return Colors.grey;
  }

  Color _boycottLevelBg(String? level) {
    if (level == null) return Colors.grey.withOpacity(0.1);
    final l = level.toLowerCase();
    if (l.contains('high')) return const Color(0xFFE74C3C).withOpacity(0.12);
    if (l.contains('medium'))
      return const Color(0xFFF39C12).withOpacity(0.12);
    if (l.contains('low')) return const Color(0xFF27AE60).withOpacity(0.12);
    return Colors.grey.withOpacity(0.1);
  }

  IconData _boycottLevelIcon(String? level) {
    if (level == null) return Icons.help_outline;
    final l = level.toLowerCase();
    if (l.contains('high')) return Icons.warning_amber_rounded;
    if (l.contains('medium')) return Icons.info_outline;
    if (l.contains('low')) return Icons.check_circle_outline;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.scanResponse;

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
          'Scan Result',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          // Scan again button
          IconButton(
            icon: const Icon(Icons.qr_code_scanner,
                color: Colors.white, size: 22),
            onPressed: () {
              Get.offAll(() => const BoycottScannerScreen());
            },
            tooltip: 'Scan Again',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── SECTION 1: Product Card ──────────────────────────────
              _buildProductCard(r),
              const SizedBox(height: 16),

              // ── SECTION 2: Ethical Status ────────────────────────────
              _buildEthicalStatusCard(r),
              const SizedBox(height: 16),

              // ── SECTION 3: AI Summary ────────────────────────────────
              if (r.summary != null && r.summary!.isNotEmpty) ...[
                _buildAiSummaryCard(r),
                const SizedBox(height: 16),
              ],

              // ── SECTION 4: Alternatives ──────────────────────────────
              if (r.alternatives.isNotEmpty) ...[
                _buildAlternativesCard(r),
                const SizedBox(height: 16),
              ],

              // ── SECTION 5: OCR Details (collapsible) ─────────────────
              if (r.ocrText != null && r.ocrText!.isNotEmpty) ...[
                _buildCollapsibleCard(
                  title: 'OCR Text Extracted',
                  icon: Icons.text_fields,
                  expanded: _ocrExpanded,
                  onToggle: () =>
                      setState(() => _ocrExpanded = !_ocrExpanded),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.ocrText!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF444444),
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── SECTION 6: Detection Details (collapsible) ────────────
              _buildCollapsibleCard(
                title: 'Scan Details',
                icon: Icons.info_outline,
                expanded: _detailsExpanded,
                onToggle: () =>
                    setState(() => _detailsExpanded = !_detailsExpanded),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDetailRow('Scan ID', r.scanId ?? 'N/A'),
                      _buildDetailRow('Cached Result',
                          r.cached ? 'Yes (fast result)' : 'No (fresh scan)'),
                      _buildDetailRow(
                          'Confidence',
                          r.confidence != null
                              ? '${(r.confidence! * 100).toStringAsFixed(0)}%'
                              : 'N/A'),
                      _buildDetailRow('Scanned At',
                          _formatDate(r.createdAt)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Scan again button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Get.offAll(() => const BoycottScannerScreen()),
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: const Text(
                    'Scan Another Product',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF329070),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Product Card ──────────────────────────────────────────────────────────
  Widget _buildProductCard(ScanResponse r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  color: Color(0xFF329070), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Product Info',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF329070),
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              // Cached badge
              if (r.cached)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF1976D2).withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt,
                          color: Color(0xFF1976D2), size: 12),
                      SizedBox(width: 3),
                      Text(
                        'Cached',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Product name
          Text(
            r.productName ?? 'Unknown Product',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          if (r.brand != null && r.brand!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'by ${r.brand}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 14),
          // Info chips row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (r.company != null && r.company!.isNotEmpty)
                _buildInfoChip(Icons.business_outlined, r.company!),
              if (r.country != null && r.country!.isNotEmpty)
                _buildInfoChip(Icons.flag_outlined, r.country!),
              if (r.category != null && r.category!.isNotEmpty)
                _buildInfoChip(Icons.category_outlined, r.category!),
            ],
          ),
          // Confidence bar
          if (r.confidence != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Confidence',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(r.confidence! * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF329070),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: r.confidence!,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF329070)),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Ethical Status Card ───────────────────────────────────────────────────
  Widget _buildEthicalStatusCard(ScanResponse r) {
    final levelColor = _boycottLevelColor(r.boycottLevel);
    final levelBg = _boycottLevelBg(r.boycottLevel);
    final levelIcon = _boycottLevelIcon(r.boycottLevel);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: Color(0xFF329070), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Ethical Status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF329070),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Big status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: levelBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: levelColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(levelIcon, color: levelColor, size: 44),
                const SizedBox(height: 10),
                Text(
                  r.boycottLevel ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: levelColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  r.ethicalStatus ?? 'Status unavailable',
                  style: TextStyle(
                    fontSize: 14,
                    color: levelColor.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── AI Summary Card ───────────────────────────────────────────────────────
  Widget _buildAiSummaryCard(ScanResponse r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: Color(0xFF329070), size: 18),
              const SizedBox(width: 8),
              const Text(
                'AI Ethical Analysis',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF329070),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF329070).withOpacity(0.15)),
            ),
            child: Text(
              r.summary!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
                height: 1.65,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  // ── Alternatives Card ─────────────────────────────────────────────────────
  Widget _buildAlternativesCard(ScanResponse r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_horiz_outlined,
                  color: Color(0xFF329070), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Ethical Alternatives',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF329070),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...r.alternatives.asMap().entries.map((entry) {
            final index = entry.key;
            final alt = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF27AE60).withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Color(0xFF27AE60),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        alt,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A1A2E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.check_circle,
                        color: Color(0xFF27AE60), size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ── Collapsible Card ──────────────────────────────────────────────────────
  Widget _buildCollapsibleCard({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF329070), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF329070),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Divider(
                height: 1, color: Colors.grey[200], indent: 16, endIndent: 16),
            child,
          ],
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF329070).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF329070).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF329070)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF329070),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}

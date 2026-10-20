import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/digital_will/pdf_history_card.dart';
import 'package:ecommerce_app/features/digital_will/controllers/pdf_generation_controller.dart';
import 'package:ecommerce_app/features/digital_will/models/pdf_history_record_model.dart';
import 'package:ecommerce_app/features/digital_will/screens/pdf_preview_screen.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen displaying all previously generated PDF reports with management options.
class GeneratedReportsHistoryScreen extends StatelessWidget {
  const GeneratedReportsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PdfGenerationController controller =
        Get.find<PdfGenerationController>();

    return Scaffold(
      appBar: PAppBar(
        title: const Text(
          'Generated Reports',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              if (value == 'clear_all') {
                _showClearAllDialog(context, controller);
              }
            },
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'clear_all',
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.delete_sweep_rounded,
                        size: 18, color: Color(0xFFB84A4A)),
                    const SizedBox(width: 8),
                    Text(
                      'Clear All History',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFFB84A4A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFEAF5F1), Color(0xFFF8FBFA)],
          ),
        ),
        child: Obx(() {
          final List<PdfHistoryRecord> records = controller.history;

          if (records.isEmpty) {
            return _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: records.length + 1, // +1 for header
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return _HistoryHeader(count: records.length);
              }

              final PdfHistoryRecord record = records[index - 1];
              return PdfHistoryCard(
                record: record,
                onOpen: record.isCached
                    ? () => controller.openPdf(record.cachedFilePath!)
                    : null,
                onDownload: () => _navigateToPreview(context, record),
                onShare: record.isCached
                    ? () => controller.sharePdf(record.cachedFilePath!)
                    : null,
                onDelete: () =>
                    _showDeleteDialog(context, controller, record),
                onRegenerate: () =>
                    _navigateToPreview(context, record),
              );
            },
          );
        }),
      ),
    );
  }

  void _navigateToPreview(BuildContext context, PdfHistoryRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PdfPreviewScreen(
          pdfUrl: record.downloadUrl,
          pdfId: record.pdfId,
          cachedFilePath: record.isCached ? record.cachedFilePath : null,
          title: record.deceasedName ?? 'Islamic Will PDF',
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    PdfGenerationController controller,
    PdfHistoryRecord record,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Report',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C3D35),
            ),
          ),
          content: Text(
            'Are you sure you want to delete this report? This will also remove the cached file.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF5A7A70),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF5A7A70),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                controller.deleteHistoryRecord(record);
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB84A4A),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    PdfGenerationController controller,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Clear All History',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C3D35),
            ),
          ),
          content: Text(
            'This will delete all generated report history and cached files. This action cannot be undone.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF5A7A70),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF5A7A70),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                controller.clearAllHistory();
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB84A4A),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 48,
                color: Color(0xFF7ABBA8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Reports Yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C3D35),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generated PDF reports will appear here.\nGenerate your first Islamic Will PDF from\nthe distribution result screen.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF7A9B91),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── History Header ──────────────────────────────────────────────────────────

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF114A3A), Color(0xFF2A7E66)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF0B3428).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Report History',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$count report${count == 1 ? '' : 's'} generated',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFFB8DDD1),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

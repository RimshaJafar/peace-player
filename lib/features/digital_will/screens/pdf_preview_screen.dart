import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/digital_will/controllers/pdf_generation_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium PDF preview screen with download, share, and open functionality.
class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({
    super.key,
    required this.pdfUrl,
    required this.pdfId,
    this.cachedFilePath,
    this.title,
  });

  final String pdfUrl;
  final String pdfId;
  final String? cachedFilePath;
  final String? title;

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  final PdfGenerationController _controller =
      Get.find<PdfGenerationController>();

  String? _localFilePath;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _localFilePath = widget.cachedFilePath;
    if (_localFilePath == null) {
      _downloadPdf();
    }
  }

  Future<void> _downloadPdf() async {
    setState(() {
      _isDownloading = true;
      _hasError = false;
      _downloadProgress = 0.0;
    });

    try {
      final String? path = await _controller.downloadPdf(
        downloadUrl: widget.pdfUrl,
        pdfId: widget.pdfId,
      );

      if (path != null) {
        setState(() {
          _localFilePath = path;
          _isDownloading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage =
              _controller.errorMessage.value ?? 'Download failed.';
          _isDownloading = false;
        });
      }
    } catch (error) {
      setState(() {
        _hasError = true;
        _errorMessage = AppErrorMessage.fromException(
          error,
          fallback: 'Unable to download the PDF. Please try again.',
        );
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PAppBar(
        title: Text(
          widget.title ?? 'PDF Preview',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: _localFilePath != null ? _buildToolbar() : null,
    );
  }

  Widget _buildBody() {
    if (_isDownloading) {
      return _DownloadingView(progress: _downloadProgress);
    }

    if (_hasError) {
      return _ErrorView(
        message: _errorMessage ?? 'Failed to load PDF.',
        onRetry: _downloadPdf,
        onOpenExternal: () =>
            _controller.openUrlExternally(widget.pdfUrl),
      );
    }

    if (_localFilePath != null) {
      return _PdfReadyView(
        filePath: _localFilePath!,
        pdfUrl: widget.pdfUrl,
        onOpen: () => _controller.openPdf(_localFilePath!),
        onOpenExternal: () =>
            _controller.openUrlExternally(widget.pdfUrl),
      );
    }

    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A5B48)),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ToolbarButton(
              icon: Icons.open_in_new_rounded,
              label: 'Open',
              onTap: () {
                if (_localFilePath != null) {
                  _controller.openPdf(_localFilePath!);
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ToolbarButton(
              icon: Icons.share_rounded,
              label: 'Share',
              onTap: () {
                if (_localFilePath != null) {
                  _controller.sharePdf(_localFilePath!);
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ToolbarButton(
              icon: Icons.open_in_browser_rounded,
              label: 'Browser',
              onTap: () => _controller.openUrlExternally(widget.pdfUrl),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ToolbarButton(
              icon: Icons.refresh_rounded,
              label: 'Reload',
              onTap: _downloadPdf,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Downloading View ────────────────────────────────────────────────────────

class _DownloadingView extends StatelessWidget {
  const _DownloadingView({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1A5B48)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Downloading PDF',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C3D35),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fetching your document from cloud...',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF7A9B91),
              ),
            ),
            const SizedBox(height: 20),
            if (progress > 0) ...[
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE0EDE8),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1A5B48)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4A7A6A),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── PDF Ready View ──────────────────────────────────────────────────────────

class _PdfReadyView extends StatelessWidget {
  const _PdfReadyView({
    required this.filePath,
    required this.pdfUrl,
    required this.onOpen,
    required this.onOpenExternal,
  });

  final String filePath;
  final String pdfUrl;
  final VoidCallback onOpen;
  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F8F7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// ICON (removed green box)
              const Icon(
                Icons.check_rounded,
                size: 50,
                color: Color(0xFF145A3A),
              ),

              const SizedBox(height: 18),

              const Text(
                'PDF Generated Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C3D35),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your Islamic Will document is ready',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7A9B91),
                ),
              ),

              const SizedBox(height: 16),

              /// UPDATED PILLS (bigger + transparent)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pill('EN'),
                  const SizedBox(width: 10),
                  _pill('modern'),
                ],
              ),

              /// 🔥 SPACE BEFORE BUTTONS (~30px)
              const SizedBox(height: 30),

              /// Download + Preview buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onOpenExternal,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Preview'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// SPACE BEFORE DONE BUTTON
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF145A3A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// UPDATED PILL DESIGN (bigger + transparent glass look)
  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF145A3A).withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF145A3A).withOpacity(0.15),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF5A7A70),
        ),
      ),
    );
  }
}
// ─── Error View ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onOpenExternal,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: Color(0xFFB84A4A),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Download Failed',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A2020),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF8A5A5A),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Retry Download',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5B48),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onOpenExternal,
              icon: const Icon(Icons.open_in_browser_rounded, size: 16),
              label: Text(
                'Open in Browser',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A5B48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Toolbar Button ──────────────────────────────────────────────────────────

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F7F4),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 20, color: const Color(0xFF1A5B48)),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3A6B5C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:ecommerce_app/features/digital_will/models/pdf_history_record_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// A premium card widget for displaying PDF history records.
class PdfHistoryCard extends StatelessWidget {
  const PdfHistoryCard({
    super.key,
    required this.record,
    this.onOpen,
    this.onDownload,
    this.onShare,
    this.onDelete,
    this.onRegenerate,
  });

  final PdfHistoryRecord record;
  final VoidCallback? onOpen;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onRegenerate;

  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date.toLocal());
    } catch (_) {
      return dateStr;
    }
  }

  Color _templateColor(String template) {
    switch (template) {
      case 'islamic':
        return const Color(0xFF8B6914);
      case 'legal':
        return const Color(0xFF1A4A8B);
      case 'minimal':
        return const Color(0xFF5A5A5A);
      default:
        return const Color(0xFF1A5B48);
    }
  }

  IconData _templateIcon(String template) {
    switch (template) {
      case 'islamic':
        return Icons.mosque_outlined;
      case 'legal':
        return Icons.gavel_outlined;
      case 'minimal':
        return Icons.article_outlined;
      default:
        return Icons.auto_awesome_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _templateColor(record.template);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F0EC)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _templateIcon(record.template),
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        record.deceasedName ?? 'Islamic Will PDF',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C3D35),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(record.generatedAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF7A9B91),
                        ),
                      ),
                    ],
                  ),
                ),
                if (record.isCached)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.download_done_rounded,
                          size: 12,
                          color: Color(0xFF1A5B48),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Cached',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A5B48),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Tags row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                _TagChip(
                  label: record.displayTemplate,
                  color: color,
                ),
                _TagChip(
                  label: record.displayLanguage,
                  color: const Color(0xFF4A7A6A),
                ),
                if (record.currencyCode != null) ...[
                  _TagChip(
                    label: record.currencyCode!,
                    color: const Color(0xFF6B7A4A),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FBFA),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              children: <Widget>[
                if (record.isCached) ...[
                  _ActionButton(
                    icon: Icons.open_in_new_rounded,
                    label: 'Open',
                    onTap: onOpen,
                  ),
                  _ActionButton(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onTap: onShare,
                  ),
                ] else ...[
                  _ActionButton(
                    icon: Icons.download_rounded,
                    label: 'Download',
                    onTap: onDownload,
                  ),
                ],
                _ActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Regenerate',
                  onTap: onRegenerate,
                ),
                _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  onTap: onDelete,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color color =
        isDestructive ? const Color(0xFFB84A4A) : const Color(0xFF3A6B5C);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

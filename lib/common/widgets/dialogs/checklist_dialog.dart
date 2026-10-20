import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChecklistDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final Set<int> checked;
  final Color primaryColor;
  final VoidCallback? onUpdate;

  const ChecklistDialog({
    super.key,
    required this.title,
    required this.items,
    required this.checked,
    required this.primaryColor,
    this.onUpdate,
  });

  @override
  State<ChecklistDialog> createState() => _ChecklistDialogState();
}

class _ChecklistDialogState extends State<ChecklistDialog> {
  int get _completedCount => widget.checked
      .where((index) => index >= 0 && index < widget.items.length)
      .length;

  double get _progress =>
      widget.items.isEmpty ? 0 : _completedCount / widget.items.length;

  void _toggleItem(int index) {
    setState(() {
      if (widget.checked.contains(index)) {
        widget.checked.remove(index);
      } else {
        widget.checked.add(index);
      }
    });
    widget.onUpdate?.call();
  }

  void _resetChecklist() {
    if (widget.checked.isEmpty) return;
    setState(widget.checked.clear);
    widget.onUpdate?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final darkerPrimary = Color.lerp(
      widget.primaryColor,
      const Color(0xFF102E3E),
      0.52,
    )!;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SizedBox(
          height: (screenHeight * 0.84).clamp(0.0, 720.0),
          child: Material(
            color: const Color(0xFFF5F8F7),
            child: Column(
              children: [
                _buildHeader(darkerPrimary),
                Expanded(child: _buildChecklist()),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color darkerPrimary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [widget.primaryColor, darkerPrimary],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$_completedCount of ${widget.items.length} items prepared',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.20),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF75D6B0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    if (widget.items.isEmpty) {
      return Center(
        child: Text(
          'No checklist items available.',
          style: GoogleFonts.poppins(
            color: const Color(0xFF66736E),
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      itemCount: widget.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 9),
      itemBuilder: (context, index) {
        final isChecked = widget.checked.contains(index);
        return _ChecklistItem(
          text: widget.items[index],
          isChecked: isChecked,
          primaryColor: widget.primaryColor,
          onTap: () => _toggleItem(index),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2EAE7)),
        ),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: widget.checked.isEmpty ? null : _resetChecklist,
            icon: const Icon(Icons.restart_alt_rounded, size: 20),
            label: const Text('Reset'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7772),
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.done_rounded, size: 19),
            label: const Text('Done'),
            style: FilledButton.styleFrom(
              backgroundColor: widget.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.text,
    required this.isChecked,
    required this.primaryColor,
    required this.onTap,
  });

  final String text;
  final bool isChecked;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isChecked
            ? primaryColor.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChecked
              ? primaryColor.withValues(alpha: 0.40)
              : const Color(0xFFDDE6E2),
          width: isChecked ? 1.3 : 1,
        ),
        boxShadow: isChecked
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF173E32).withValues(alpha: 0.045),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isChecked ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isChecked
                            ? primaryColor
                            : const Color(0xFF9AACA5),
                        width: 1.6,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: isChecked
                          ? const Icon(
                              Icons.check_rounded,
                              key: ValueKey(true),
                              size: 18,
                              color: Colors.white,
                            )
                          : const SizedBox(key: ValueKey(false)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoNastaliqUrdu(
                        fontSize: 15,
                        height: 1.75,
                        fontWeight:
                            isChecked ? FontWeight.w600 : FontWeight.w500,
                        color: isChecked
                            ? const Color(0xFF234E40)
                            : const Color(0xFF293530),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:ecommerce_app/features/notifications/models/notification_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;
    final timeLabel = _formatTime(item.createdAt);
    final accent = isUnread ? PColors.primary : const Color(0xFF71817B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread
                ? const Color(0xFFF4FAF7)
                : Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUnread
                  ? const Color(0xFFB7DDD0)
                  : const Color(0xFFE0E8E5),
              width: isUnread ? 1.2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF526F83).withValues(alpha: 0.09),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _notificationIcon(),
                  color: accent,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title.isNotEmpty
                                ? item.title
                                : 'Notification',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xFF22343A),
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 8,
                            height: 8,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: PColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        height: 1.45,
                        color: Color(0xFF687773),
                      ),
                    ),
                    if (timeLabel.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: Color(0xFF91A09B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeLabel,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF91A09B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _notificationIcon() {
    final value = '${item.type} ${item.source}'.toLowerCase();
    if (value.contains('reminder') || value.contains('prayer')) {
      return Icons.alarm_rounded;
    }
    if (value.contains('support') || value.contains('payment')) {
      return Icons.favorite_rounded;
    }
    if (value.contains('announcement') || value.contains('broadcast')) {
      return Icons.campaign_rounded;
    }
    if (value.contains('update')) {
      return Icons.system_update_alt_rounded;
    }
    return Icons.notifications_rounded;
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final difference = today.difference(day).inDays;

    if (difference == 0) {
      return 'Today, ${DateFormat('h:mm a').format(local)}';
    }
    if (difference == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(local)}';
    }
    return DateFormat('MMM d, yyyy').format(local);
  }
}

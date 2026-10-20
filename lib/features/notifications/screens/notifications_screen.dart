import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/containers/kids_screen_background.dart';
import 'package:ecommerce_app/features/notifications/controllers/notifications_controller.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/notification_tile.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsController _controller =
      Get.isRegistered<NotificationsController>()
          ? Get.find<NotificationsController>()
          : Get.put(NotificationsController());

  @override
  void initState() {
    super.initState();
    _controller.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      backgroundColor: const Color(0xFFE9F3EF),
      body: KidsScreenBackground(
        child: Obx(() {
          if (_controller.isLoading.value &&
              _controller.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: PColors.primary),
            );
          }

          if (_controller.errorMessage.value != null &&
              _controller.errorMessage.value!.isNotEmpty) {
            return _ErrorState(
              message: _controller.errorMessage.value!,
              onRetry: _controller.fetchNotifications,
            );
          }

          final items = _controller.filteredNotifications;

          return RefreshIndicator(
            color: PColors.primary,
            onRefresh: () => _controller.fetchNotifications(force: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _NotificationSummary(controller: _controller),
                const SizedBox(height: 14),
                _FilterBar(controller: _controller),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const _EmptyState()
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NotificationTile(
                        item: item,
                        onTap: () => _controller
                            .markNotificationRead(item.notificationId),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NotificationSummary extends StatelessWidget {
  const _NotificationSummary({required this.controller});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final unread = controller.unreadCount;
      final total = controller.notifications.length;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: PColors.linearGradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1C5D4E).withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stay up to date',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    unread == 0
                        ? '$total notifications · All caught up'
                        : '$unread unread of $total notifications',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FilterBar extends StatelessWidget {
  final NotificationsController controller;

  const _FilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedFilter.value;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD8E5E1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF526F83).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: selected == NotificationFilter.all,
              onTap: () => controller.setFilter(NotificationFilter.all),
            ),
            _FilterChip(
              label: 'Unread',
              isSelected: selected == NotificationFilter.unread,
              onTap: () => controller.setFilter(NotificationFilter.unread),
            ),
            _FilterChip(
              label: 'Read',
              isSelected: selected == NotificationFilter.read,
              onTap: () => controller.setFilter(NotificationFilter.read),
            ),
          ],
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? PColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: PColors.primary.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF5F706A),
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE8E4)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF86A39A),
            size: 52,
          ),
          SizedBox(height: 14),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: Color(0xFF52656D),
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'New updates and reminders will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8A9A95),
              fontFamily: 'Poppins',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE4D3D3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF526F83).withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: Color(0xFFC15F5F),
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF34464D),
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7C8A86),
                fontFamily: 'Poppins',
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 19),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

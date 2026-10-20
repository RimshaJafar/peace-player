import 'package:ecommerce_app/features/notifications/controllers/notifications_controller.dart';
import 'package:ecommerce_app/features/notifications/screens/notifications_screen.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/notification_tile.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showNotificationPreviewSheet(BuildContext context) async {
  final controller = Get.isRegistered<NotificationsController>()
      ? Get.find<NotificationsController>()
      : Get.put(NotificationsController());

  await controller.fetchNotifications(force: true);
  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (_) => _NotificationPreviewSheet(controller: controller),
  );
}

class NotificationActionButton extends StatefulWidget {
  const NotificationActionButton({super.key});

  @override
  State<NotificationActionButton> createState() =>
      _NotificationActionButtonState();
}

class _NotificationActionButtonState extends State<NotificationActionButton> {
  late final NotificationsController _notificationsController =
      Get.isRegistered<NotificationsController>()
          ? Get.find<NotificationsController>()
          : Get.put(NotificationsController());

  @override
  void initState() {
    super.initState();
    _notificationsController.fetchNotifications();
  }

  Future<void> _openNotifications() async {
    await showNotificationPreviewSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final unreadCount = _notificationsController.unreadCount;
      final badgeText = unreadCount > 9 ? '9+' : unreadCount.toString();

      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: PSizes.iconLg,
            ),
            onPressed: _openNotifications,
          ),
          if (unreadCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFE84C4C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _NotificationPreviewSheet extends StatelessWidget {
  final NotificationsController controller;

  const _NotificationPreviewSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF1F7F5)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: SafeArea(
          top: false,
          child: Obx(() {
            final items = controller.previewNotifications;
            final unread = controller.unreadCount;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5D3CF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: PColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: PColors.primary,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              color: Color(0xFF263A42),
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            unread == 0
                                ? 'You are all caught up'
                                : '$unread unread notification${unread == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: Color(0xFF7A8B85),
                              fontFamily: 'Poppins',
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: PColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 10,
                          ),
                          child: Text(
                            'See all',
                            style: TextStyle(
                              color: PColors.primary,
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFDCE7E3)),
                const SizedBox(height: 12),
                if (controller.isLoading.value)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: CircularProgressIndicator(color: PColors.primary),
                    ),
                  )
                else if (controller.errorMessage.value?.isNotEmpty == true)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            color: Color(0xFF9A6969),
                            size: 38,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Unable to load notifications',
                            style: TextStyle(
                              color: Color(0xFF687773),
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () =>
                                controller.fetchNotifications(force: true),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (items.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF91A69F),
                            size: 44,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              color: Color(0xFF71817B),
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return NotificationTile(
                          item: item,
                          onTap: () => controller
                              .markNotificationRead(item.notificationId),
                        );
                      },
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

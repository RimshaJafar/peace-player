import 'package:ecommerce_app/common/widgets/button/notification_action_button.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreenDrawer extends StatelessWidget {
  const MainScreenDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Get.find<AuthenticationRepository>();
    final userController = Get.find<UserController>();

    return Drawer(
      child: Column(
        children: [
          // User Header
          Obx(() {
            final user = userController.user.value;
            return UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF60BEA8),
                    Color(0xFF329070),
                    Color(0xFF1C5D4E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                user.fullName.isNotEmpty ? user.fullName : 'Guest',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                user.email.isNotEmpty ? user.email : 'Not Logged In',
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user.profilePicture.isNotEmpty
                    ? NetworkImage(user.profilePicture)
                    : const AssetImage(PImages.userPlaceholder)
                        as ImageProvider,
              ),
            );
          }),

          // Navigation Tiles
          drawerTile(
            leading: const Icon(Icons.info_outline_rounded,
                color: Colors.black, size: 24),
            title: 'About us',
            onTap: () => _closeDrawerAndNavigate(context, '/about-us'),
          ),
          drawerTile(
            leading: const Icon(Icons.notifications_none_rounded,
                color: Colors.black, size: 24),
            title: 'Notifications',
            onTap: () => _closeDrawerAndShowNotifications(context),
          ),
          drawerTile(
            leading: const Icon(Icons.workspace_premium_outlined,
                color: Colors.black, size: 24),
            title: 'Billing Plans',
            onTap: () => _closeDrawerAndNavigate(context, '/subscription'),
          ),
          drawerTile(
            leading: const Icon(Icons.favorite_border_rounded,
                color: Colors.black, size: 24),
            title: 'App support',
            onTap: () => _closeDrawerAndNavigate(context, '/app-support'),
          ),
          drawerTile(
            leading: const Icon(Icons.settings_outlined,
                color: Colors.black, size: 24),
            title: 'Settings',
            onTap: () => _closeDrawerAndNavigate(context, '/app-settings'),
          ),

          Spacer(),

          // Logout/Login Button
          Obx(() {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: drawerTile(
                leading: Icon(
                  authRepo.isLoggedInRx.value ? Icons.logout : Icons.login,
                  color: Colors.black,
                ),
                title: authRepo.isLoggedInRx.value ? 'Logout' : 'Login',
                onTap: () async {
                  if (authRepo.isLoggedInRx.value) {
                    await authRepo.logout();
                    PLoaders.successSnackBar(
                      title: "Logged out",
                      message: "You have been signed out.",
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _closeDrawerAndNavigate(BuildContext context, String routeName) {
    Navigator.pop(context);
    Get.toNamed(routeName);
  }

  Future<void> _closeDrawerAndShowNotifications(BuildContext context) async {
    final navigator = Navigator.of(context);

    navigator.pop();
    await Future<void>.delayed(const Duration(milliseconds: 220));

    if (!navigator.mounted) return;
    await showNotificationPreviewSheet(navigator.context);
  }

  /// Custom tile widget
  Widget drawerTile({
    required Widget leading,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 55,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF60BEA8).withAlpha((255 * 0.25).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color:
                      const Color(0xFF329070).withAlpha((255 * 0.15).toInt()),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                leading,
                const SizedBox(width: 24),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

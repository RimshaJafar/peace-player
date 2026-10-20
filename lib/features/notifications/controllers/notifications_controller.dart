import 'dart:convert';

import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/features/notifications/models/notification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart' as http;

enum NotificationFilter { all, unread, read }

class NotificationsController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  final authRepo = Get.find<AuthenticationRepository>();
  final userController = Get.find<UserController>();
  String? firebaseUserId;

  final notifications = <NotificationItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final selectedFilter = NotificationFilter.all.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await ensureFirebaseUserId();
    await fetchNotifications();
  }

  bool get _canCallApi =>
      apisBaseUrl != null &&
      apisBaseUrl!.isNotEmpty &&
      firebaseUserId != null &&
      firebaseUserId!.isNotEmpty;

  int get unreadCount => notifications.where((item) => !item.isRead).length;

  List<NotificationItem> get previewNotifications {
    final items = notifications.toList();
    if (items.length <= 3) return items;
    return items.sublist(0, 3);
  }

  List<NotificationItem> get filteredNotifications {
    final items = notifications.toList();
    switch (selectedFilter.value) {
      case NotificationFilter.unread:
        return items.where((item) => !item.isRead).toList();
      case NotificationFilter.read:
        return items.where((item) => item.isRead).toList();
      case NotificationFilter.all:
      default:
        return items;
    }
  }

  Future<void> ensureFirebaseUserId() async {
    if (firebaseUserId != null && firebaseUserId!.isNotEmpty) return;

    if (authRepo.isLoggedInRx.value) {
      await userController.fetchUserRecord();
      final user = userController.user.value;
      firebaseUserId = user.id;
    }
  }

  Future<void> fetchNotifications({bool force = false}) async {
    await ensureFirebaseUserId();
    if (!_canCallApi) {
      errorMessage.value = 'Base URL or Firebase User ID not available';
      return;
    }
    if (!force && isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final uri = Uri.parse(
        '$apisBaseUrl/notifications?firebase_user_id=${Uri.encodeComponent(firebaseUserId!)}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final parsed = NotificationListResponse.fromJson(decoded);
          final items = parsed.items.toList()..sort(_compareByDateDesc);
          notifications.assignAll(items);
          return;
        }
      }

      errorMessage.value =
          'Failed to load notifications (${response.statusCode}).';
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> markNotificationRead(String notificationId) async {
    await ensureFirebaseUserId();
    if (!_canCallApi || notificationId.isEmpty) return false;

    try {
      final uri = Uri.parse(
        '$apisBaseUrl/notifications/$notificationId/read?firebase_user_id=${Uri.encodeComponent(firebaseUserId!)}',
      );
      var response = await http.post(uri);
      if (response.statusCode == 405 || response.statusCode == 404) {
        response = await http.get(uri);
      }

      if (response.statusCode == 200) {
        _setReadLocally(notificationId);
        return true;
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  void setFilter(NotificationFilter filter) {
    selectedFilter.value = filter;
  }

  void _setReadLocally(String notificationId) {
    final index = notifications
        .indexWhere((item) => item.notificationId == notificationId);
    if (index == -1) return;
    final item = notifications[index];
    if (item.isRead) return;

    notifications[index] = item.copyWith(isRead: true);
    notifications.refresh();
  }

  int _compareByDateDesc(NotificationItem a, NotificationItem b) {
    final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bDate.compareTo(aDate);
  }
}

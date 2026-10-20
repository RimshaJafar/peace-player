import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../common/widgets/loaders/loaders.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;
  final Rx<ConnectivityResult> connectionStatus = ConnectivityResult.none.obs;
  DateTime? _lastNoInternetSnackbarAt;
  static const _noInternetSnackbarCooldown = Duration(seconds: 8);

  @override
  void onInit() {
    super.onInit();
    connectivitySubscription = connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
    }, onError: (Object error, StackTrace stackTrace) {
      if (kDebugMode) {
        debugPrint('[NetworkManager] connectivity stream error: $error');
        debugPrint(stackTrace.toString());
      }
    });
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    connectionStatus.value = result;
    if (connectionStatus.value == ConnectivityResult.none) {
      _showNoInternetWarning();
    }
  }

  Future<bool> isConnected() async {
    try {
      final results = await connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } on PlatformException catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[NetworkManager] connectivity check failed: $error');
        debugPrint(stackTrace.toString());
      }
      return false;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[NetworkManager] connectivity check failed: $error');
        debugPrint(stackTrace.toString());
      }
      return false;
    }
  }

  void _showNoInternetWarning() {
    final now = DateTime.now();
    final last = _lastNoInternetSnackbarAt;
    if (last != null &&
        now.difference(last) < _noInternetSnackbarCooldown) {
      return;
    }

    _lastNoInternetSnackbarAt = now;
    PLoaders.warningSnackBar(
      title: 'No Internet Connection',
      message: 'Please check your connection and try again.',
    );
  }

  @override
  void onClose() {
    connectivitySubscription.cancel();
    super.onClose();
  }
}

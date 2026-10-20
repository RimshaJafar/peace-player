import 'dart:async';

import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rxn<User> currentUserRx = Rxn<User>();
  StreamSubscription<User?>? _authSubscription;
  bool _isHandlingUnauthorized = false;

  User? get currentUser => currentUserRx.value ?? _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  @override
  void onInit() {
    super.onInit();
    currentUserRx.value = _auth.currentUser;
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      currentUserRx.value = user;
    });
  }

  Future<void> handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;

    try {
      if (Get.isRegistered<AuthenticationRepository>()) {
        await AuthenticationRepository.instance.logout();
      } else {
        await _auth.signOut();
      }
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}

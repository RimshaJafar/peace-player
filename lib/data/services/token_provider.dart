import 'package:ecommerce_app/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class TokenProvider extends GetxService {
  static TokenProvider get instance => Get.find<TokenProvider>();

  User? get currentUser {
    if (Get.isRegistered<AuthService>()) {
      return AuthService.instance.currentUser;
    }
    return FirebaseAuth.instance.currentUser;
  }

  Future<String?> getToken({bool forceRefresh = false}) async {
    final User? user = currentUser;
    if (user == null) return null;

    return user.getIdToken(forceRefresh);
  }

  Future<String?> refreshToken() {
    return getToken(forceRefresh: true);
  }
}

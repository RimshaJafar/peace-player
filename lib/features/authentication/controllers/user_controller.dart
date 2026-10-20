import 'package:ecommerce_app/data/repositories/user_repository.dart';
import 'package:ecommerce_app/features/authentication/models/user_model.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  Rx<UserModel> user = UserModel.empty().obs;
  final userLoadError = ''.obs;
  final userRepository = Get.put(UserRepository());

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  Future<void> fetchUserRecord() async {
    try {
      userLoadError.value = '';
      final user = await userRepository.fetchUserDetails();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
      userLoadError.value = AppErrorMessage.fromException(
        e,
        fallback: 'Unable to load your profile right now.',
      );
    }
  }

  /// Save user record from any Registration provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      final firebaseUser = userCredentials?.user;
      if (firebaseUser != null) {
        // Convert Name to First and Last Name
        final nameParts =
            UserModel.nameParts(firebaseUser.displayName ?? '');
        final username =
            UserModel.generateUsername(firebaseUser.displayName ?? '');

        // Map Data
        final providers = firebaseUser.providerData
            .map((provider) => provider.providerId)
            .where((providerId) => providerId.isNotEmpty)
            .toSet()
            .toList();
        final user = UserModel(
          id: firebaseUser.uid,
          firstName: nameParts[0],
          lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
          username: username,
          email: firebaseUser.email ?? '',
          phoneNumber: firebaseUser.phoneNumber ?? '',
          profilePicture: firebaseUser.photoURL ?? '',
          authProviders: providers,
        );

        // Save user data
        await userRepository.saveUserRecord(user);
      }
    } catch (e) {
      PLoaders.warningSnackBar(
        title: "Data not saved",
        message:
            "Something went wrong while saving your information. You can re-save your data in your Profile.",
      );
    }
  }
}

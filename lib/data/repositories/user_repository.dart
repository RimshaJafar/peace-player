import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/features/authentication/models/user_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Function to save user data to Firestore.
  Future<void> saveUserRecord(UserModel user) async {
    try {
      final userDocument = _db.collection("Users").doc(user.id);
      final existingSnapshot = await userDocument.get();
      final userJson = user.toJson();

      if (existingSnapshot.exists) {
        final existingProviders =
            _authProvidersFromData(existingSnapshot.data() ?? {});
        final mergedProviders = _mergeAuthProviders(
          existingProviders,
          user.authProviders,
        );

        if (mergedProviders.isNotEmpty) {
          userJson['AuthProviders'] = mergedProviders;
          userJson['PrimaryAuthProvider'] = mergedProviders.first;
        }
      }

      await userDocument.set(userJson, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw e.message ?? "FirebaseException occurred.";
    } on FormatException catch (_) {
      throw const FormatException();
    } on PlatformException catch (e) {
      throw e.message ?? "PlatformException occurred.";
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  List<String> _authProvidersFromData(Map<String, dynamic> data) {
    final providers = data['AuthProviders'];
    if (providers is List) {
      return providers
          .map((provider) => provider.toString().trim().toLowerCase())
          .where((provider) => provider.isNotEmpty)
          .toList();
    }

    final primaryProvider =
        data['PrimaryAuthProvider']?.toString().trim().toLowerCase() ?? '';
    if (primaryProvider.isNotEmpty) return [primaryProvider];

    return const [];
  }

  List<String> _mergeAuthProviders(
    List<String> existingProviders,
    List<String> newProviders,
  ) {
    final providers = <String>{
      ...existingProviders.map(_normalizeAuthProvider),
      ...newProviders.map(_normalizeAuthProvider),
    }..remove('');

    if (providers.contains('password')) {
      return [
        'password',
        ...providers.where((provider) => provider != 'password')
      ];
    }

    return providers.toList();
  }

  String _normalizeAuthProvider(String provider) {
    final normalizedProvider = provider.trim().toLowerCase();
    if (normalizedProvider == 'email' ||
        normalizedProvider == 'email/password' ||
        normalizedProvider == 'emailpassword') {
      return 'password';
    }

    return normalizedProvider;
  }

  Future<UserModel?> fetchUserByEmail(String email) async {
    try {
      final trimmedEmail = email.trim();
      final lowerEmail = trimmedEmail.toLowerCase();

      final lowerEmailSnapshot = await _db
          .collection("Users")
          .where("EmailLowercase", isEqualTo: lowerEmail)
          .limit(1)
          .get();
      if (lowerEmailSnapshot.docs.isNotEmpty) {
        return UserModel.fromSnapshot(lowerEmailSnapshot.docs.first);
      }

      final emailValues = <String>{trimmedEmail, lowerEmail}.toList();
      final emailSnapshot = await _db
          .collection("Users")
          .where("Email", whereIn: emailValues)
          .limit(1)
          .get();
      if (emailSnapshot.docs.isNotEmpty) {
        return UserModel.fromSnapshot(emailSnapshot.docs.first);
      }

      return null;
    } on FirebaseException catch (e) {
      throw e.message ?? "FirebaseException occurred.";
    } on FormatException catch (_) {
      throw const FormatException();
    } on PlatformException catch (e) {
      throw e.message ?? "PlatformException occurred.";
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Function to save user data to Firestore.
  Future<UserModel> fetchUserDetails() async {
    try {
      final userId = AuthenticationRepository.instance.authUser?.uid.trim();
      if (userId == null || userId.isEmpty) {
        return UserModel.empty();
      }

      final documentSnapshot = await _db.collection("Users").doc(userId).get();

      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw e.message ?? "FirebaseException occurred.";
    } on FormatException catch (_) {
      throw const FormatException();
    } on PlatformException catch (e) {
      throw e.message ?? "PlatformException occurred.";
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}

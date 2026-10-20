import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/formatters/formatter.dart';

class UserModel {
  // Keep those values final which you do not want to update
  final String id;
  String firstName;
  String lastName;
  final String username;
  final String email;
  String phoneNumber;
  String profilePicture;
  final List<String> authProviders;

  // Constructor for UserModel.
  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    this.authProviders = const [],
  });

  // Helper function to get the full name.
  String get fullName => '$firstName $lastName';

  // Helper function to format phone number.
  String get formattedPhoneNo => PFormatter.formatPhoneNumber(phoneNumber);

  // Static function to split full name into first and last name.
  static List<String> nameParts(String fullName) => fullName.split(" ");
  // Function to create username from name parts.
  static String generateUsername(fullname) {
    List<String> nameParts = fullname.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : '';
    String camelCaseUsername =
        "$firstName$lastName"; // Combine first and last name
    String usernameWithPrefix = "cat$camelCaseUsername"; // Add "cat" prefix
    return usernameWithPrefix;
  }

  /// Static function to create an empty user model.
  static UserModel empty() {
    return UserModel(
      id: '',
      firstName: '',
      lastName: '',
      username: '',
      email: '',
      phoneNumber: '',
      profilePicture: '',
      authProviders: const [],
    );
  }

  /// Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Email': email,
      'EmailLowercase': email.trim().toLowerCase(),
      'AuthProviders': authProviders,
      'PrimaryAuthProvider':
          authProviders.isNotEmpty ? authProviders.first : '',
      'PhoneNumber': phoneNumber,
      'ProfilePicture': profilePicture,
    };
  }

  /// Factory method to create a UserModel from a Firebase document snapshot.
  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return UserModel(
        id: document.id,
        firstName: data['FirstName'] ?? '',
        lastName: data['LastName'] ?? '',
        username: data['Username'] ?? '',
        email: data['Email'] ?? '',
        phoneNumber: data['PhoneNumber'] ?? '',
        profilePicture: data['ProfilePicture'] ?? '',
        authProviders: _authProvidersFromData(data),
      );
    } else {
      return UserModel.empty();
    }
  }

  static List<String> _authProvidersFromData(Map<String, dynamic> data) {
    final providers = data['AuthProviders'];
    if (providers is List) {
      return providers
          .map((provider) => provider.toString())
          .where((provider) => provider.isNotEmpty)
          .toList();
    }

    final primaryProvider = data['PrimaryAuthProvider']?.toString() ?? '';
    if (primaryProvider.isNotEmpty) return [primaryProvider];

    return const [];
  }
}

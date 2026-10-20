import 'dart:convert';

import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:ecommerce_app/features/app_support/models/account_model.dart';
import 'package:ecommerce_app/features/app_support/models/support_transaction_model.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class AppSupportService {
  String get _baseUrl {
    final configuredUrl = dotenv.env['APIS_BASE_URL']?.trim() ?? '';
    final uri = Uri.tryParse(configuredUrl);
    if (configuredUrl.isEmpty ||
        uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty) {
      throw const AppConfigurationException(
        'App support payments are temporarily unavailable.',
      );
    }
    return configuredUrl.endsWith('/')
        ? configuredUrl.substring(0, configuredUrl.length - 1)
        : configuredUrl;
  }

  Uri _uri(String path, {Map<String, String>? queryParams}) {
    final uri = Uri.parse('$_baseUrl$path');
    return queryParams == null || queryParams.isEmpty
        ? uri
        : uri.replace(queryParameters: queryParams);
  }

  Future<AccountNumbersResponse> getAccountNumbers() async {
    final response = await http
        .get(_uri('/api/app-support/account-numbers'))
        .timeout(const Duration(seconds: 30));
    _throwForFailure(
      response,
      fallback: 'Unable to load account details. Please try again.',
    );
    return AccountNumbersResponse.fromJson(_decodeMap(response.body));
  }

  Future<Map<String, dynamic>> initiateStripePayment({
    required double amount,
    String currency = 'PKR',
    String? supporterMessage,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final body = <String, dynamic>{
      'amount': amount,
      'currency': currency,
    };
    if (supporterMessage != null && supporterMessage.isNotEmpty) {
      body['supporter_message'] = supporterMessage;
    }

    final response = await http
        .post(
          _uri(
            '/api/app-support/initiate-stripe',
            queryParams: {
              'user_id': userId,
              'user_name': userName,
              'user_email': userEmail,
            },
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    _throwForFailure(
      response,
      fallback: 'Unable to start the card payment. Please try again.',
    );
    return _decodeMap(response.body);
  }

  Future<SupportTransactionModel> confirmStripePayment(
    String paymentIntentId,
  ) async {
    final response = await http
        .post(
          _uri('/api/app-support/confirm-stripe/$paymentIntentId'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 30));
    _throwForFailure(
      response,
      fallback: 'Unable to confirm the card payment. Please try again.',
    );
    return SupportTransactionModel.fromJson(_decodeMap(response.body));
  }

  Future<Map<String, dynamic>> submitManualPayment({
    required double amount,
    String currency = 'PKR',
    required String paymentMethod,
    String? supporterMessage,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final body = <String, dynamic>{
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
    };
    if (supporterMessage != null && supporterMessage.isNotEmpty) {
      body['supporter_message'] = supporterMessage;
    }

    final response = await http
        .post(
          _uri(
            '/api/app-support/manual-payment',
            queryParams: {
              'user_id': userId,
              'user_name': userName,
              'user_email': userEmail,
            },
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    _throwForFailure(
      response,
      fallback: 'Unable to submit the payment. Please try again.',
    );
    return _decodeMap(response.body);
  }

  Future<Map<String, dynamic>> uploadScreenshot({
    required String transactionId,
    required XFile imageFile,
  }) async {
    final bytes = await imageFile.readAsBytes();
    if (bytes.isEmpty) {
      throw const AppUserFacingException(
        'The selected screenshot could not be read. Please choose another one.',
      );
    }

    final filename = _getFilename(imageFile);
    final extension = filename.split('.').last.toLowerCase();
    final mediaType = MediaType.parse(_getMimeType(extension));
    final request = http.MultipartRequest(
      'POST',
      _uri('/api/app-support/upload-screenshot/$transactionId'),
    )..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
          contentType: mediaType,
        ),
      );

    final streamed =
        await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);
    _throwForFailure(
      response,
      fallback: 'Unable to upload the screenshot. Please try again.',
    );
    return _decodeMap(response.body);
  }

  Future<List<SupportTransactionModel>> getMyTransactions({
    required String userId,
  }) async {
    final response = await http
        .get(
          _uri(
            '/api/app-support/my-transactions',
            queryParams: {'user_id': userId},
          ),
        )
        .timeout(const Duration(seconds: 30));
    _throwForFailure(
      response,
      fallback: 'Unable to load support history. Please try again.',
    );

    final decoded = safeDecodeJson(response.body);
    final dynamic rawList = decoded is List
        ? decoded
        : decoded is Map
            ? decoded['transactions'] ?? decoded['data']
            : null;
    if (rawList is! List) {
      throw const FormatException('Invalid support history response.');
    }

    final transactions = rawList
        .whereType<Map>()
        .map(
          (item) => SupportTransactionModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    return transactions.where((transaction) {
      final isStripeTransaction =
          transaction.paymentMethod.trim().toLowerCase() == 'stripe' ||
              (transaction.stripePaymentIntentId?.trim().isNotEmpty ?? false);
      if (!isStripeTransaction) return true;

      final status = transaction.status.trim().toLowerCase();
      final stripeStatus = transaction.stripeStatus?.trim().toLowerCase();
      return status == 'completed' ||
          status == 'succeeded' ||
          stripeStatus == 'succeeded';
    }).toList();
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = safeDecodeJson(body);
    if (decoded is! Map) {
      throw const FormatException('Invalid app support response.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  void _throwForFailure(
    dynamic response, {
    required String fallback,
  }) {
    final statusCode = response.statusCode as int;
    if (statusCode >= 200 && statusCode < 300) return;
    throw AppUserFacingException(
      ApiErrorParser.parseResponse(response, fallback: fallback),
    );
  }

  String _getFilename(XFile imageFile) {
    final rawName = imageFile.name.trim().isNotEmpty
        ? imageFile.name.trim()
        : imageFile.path.split(RegExp(r'[\\/]')).last.trim();
    final extension =
        rawName.contains('.') ? rawName.split('.').last : 'jpg';
    final safeExtension = _isSupportedImageExtension(extension)
        ? extension.toLowerCase()
        : 'jpg';

    if (rawName.isEmpty ||
        !rawName.contains('.') ||
        safeExtension != extension.toLowerCase()) {
      return 'screenshot.$safeExtension';
    }
    return rawName;
  }

  bool _isSupportedImageExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return true;
      default:
        return false;
    }
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

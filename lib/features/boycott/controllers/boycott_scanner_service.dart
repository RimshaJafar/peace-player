import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce_app/features/boycott/models/scan_response_model.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/services/billing_api_service.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:get/get.dart';

class BoycottScannerService {
  String get _baseUrl {
    final configuredUrl = dotenv.env['APIS_BASE_URL']?.trim();
    if (configuredUrl == null || configuredUrl.isEmpty) {
      throw const AppConfigurationException(
        'Boycott scanner is unavailable right now. Please try again later.',
      );
    }
    return configuredUrl.endsWith('/')
        ? configuredUrl.substring(0, configuredUrl.length - 1)
        : configuredUrl;
  }

  /// Derives a [MediaType] from the file extension.
  MediaType _mediaTypeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'heic':
        return MediaType('image', 'heic');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  /// POST /boycott/scanner/analyze
  /// Accepts an [XFile] from image_picker — handles both real paths and
  /// Android content:// URIs correctly via XFile.readAsBytes().
  Future<ScanResponse> analyzeProduct({
    required XFile xFile,
    required String firebaseUserId,
    String? imageUrl,
    void Function(double progress)? onProgress,
  }) async {
    final uri = Uri.parse('$_baseUrl/boycott/scanner/analyze');

    final request = http.MultipartRequest('POST', uri)
      ..headers['accept'] = 'application/json'
      ..headers['Idempotency-Key'] = BillingRequestId.newKey()
      ..fields['firebase_user_id'] = firebaseUserId;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      request.fields['image_url'] = imageUrl;
    }

    // XFile.readAsBytes() correctly handles content:// URIs on Android
    // without requiring dart:io File, avoiding the _Namespace error.
    final bytes = await xFile.readAsBytes();
    final fileName = xFile.name.isNotEmpty ? xFile.name : 'image.jpg';
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: fileName,
      contentType: _mediaTypeFromPath(xFile.path),
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 120),
      onTimeout: () {
        throw Exception('Request timed out. Please try again.');
      },
    );

    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final decoded = safeDecodeJson(responseBody);
      if (decoded is! Map) {
        throw const AppUserFacingException(
          'The scanner response could not be read. Please try again.',
        );
      }
      final json = Map<String, dynamic>.from(decoded);
      final dynamic billing = json['billing'];
      if (billing is Map && Get.isRegistered<BillingController>()) {
        BillingController.instance.updateUsageFromBillingMetadata(
          Map<String, dynamic>.from(billing),
        );
      }
      return ScanResponse.fromJson(json);
    } else {
      try {
        throw billingApiExceptionFromJson(
          responseBody.isEmpty ? null : safeDecodeJson(responseBody),
          statusCode: streamedResponse.statusCode,
        );
      } catch (error) {
        if (error is BillingApiException) rethrow;
      }
      throw AppUserFacingException(
        AppErrorMessage.fromStatusCode(
          streamedResponse.statusCode,
          parsedMessage:
              ApiErrorParser.messageFromDecoded(safeDecodeJson(responseBody)),
          fallback: 'Unable to scan this product. Please try again.',
        ),
      );
    }
  }

  /// GET /boycott/scanner/history/{firebase_user_id}
  Future<ScanHistoryResponse> getScanHistory({
    required String firebaseUserId,
    int limit = 50,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
        '$_baseUrl/boycott/scanner/history/$firebaseUserId?limit=$limit&skip=$skip');

    final response = await http.get(
      uri,
      headers: {'accept': 'application/json'},
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Request timed out. Please try again.');
      },
    );

    if (response.statusCode == 200) {
      final decoded = safeDecodeJson(response.body);
      if (decoded is! Map) {
        throw const AppUserFacingException(
          'Your scan history could not be read. Please try again.',
        );
      }
      final json = Map<String, dynamic>.from(decoded);
      return ScanHistoryResponse.fromJson(json);
    } else {
      throw AppUserFacingException(
        ApiErrorParser.parseResponse(
          response,
          fallback: 'Unable to load scan history. Please try again.',
        ),
      );
    }
  }

  /// GET /boycott/scanner/product/{scan_id}
  Future<ScanResponse> getScanById(String scanId) async {
    final uri = Uri.parse('$_baseUrl/boycott/scanner/product/$scanId');

    final response = await http.get(
      uri,
      headers: {'accept': 'application/json'},
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Request timed out. Please try again.');
      },
    );

    if (response.statusCode == 200) {
      final decoded = safeDecodeJson(response.body);
      if (decoded is! Map) {
        throw const AppUserFacingException(
          'The scan details could not be read. Please try again.',
        );
      }
      final json = Map<String, dynamic>.from(decoded);
      return ScanResponse.fromJson(json);
    } else {
      throw AppUserFacingException(
        ApiErrorParser.parseResponse(
          response,
          fallback: 'Unable to load scan details. Please try again.',
        ),
      );
    }
  }
}

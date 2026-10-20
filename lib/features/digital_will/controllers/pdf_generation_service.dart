import 'dart:convert';
import 'dart:io';

import 'package:ecommerce_app/features/digital_will/models/pdf_generation_request_model.dart';
import 'package:ecommerce_app/features/digital_will/models/pdf_generation_response_model.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/helpers/billing_gate_helper.dart';
import 'package:ecommerce_app/features/billing/services/billing_api_service.dart';
import 'package:ecommerce_app/utils/constants/pdf_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:path_provider/path_provider.dart';

/// Service layer for PDF generation API calls and file operations.
class PdfGenerationService {
  PdfGenerationService._();
  static final PdfGenerationService instance = PdfGenerationService._();

  final String? _baseUrl = dotenv.env['APIS_BASE_URL'];

  // ─── Generate PDF ────────────────────────────────────────────────────
  /// Calls POST /digital-will/generate-pdf
  Future<PdfGenerationResponse> generatePdf(
    PdfGenerationRequest request,
  ) async {
    if (!await BillingGateHelper.ensureFeatureAccess(
      BillingFeatureKeys.digitalWillPdfReport,
    )) {
      throw PdfServiceException('Digital Will PDF reports require Pro.');
    }
    if (_baseUrl == null || _baseUrl.isEmpty) {
      throw PdfServiceException('APIS_BASE_URL is not configured.');
    }

    final Uri uri = Uri.parse('$_baseUrl/digital-will/generate-pdf');
    final Map<String, dynamic> payload = request.toJson();

    // Debug: log the payload being sent
    debugPrint('╔══════════════════════════════════════════════════════════');
    debugPrint('║ PDF Generation Request');
    debugPrint('║ URL: $uri');
    debugPrint(
        '║ Payload: ${const JsonEncoder.withIndent('  ').convert(payload)}');
    debugPrint('╚══════════════════════════════════════════════════════════');

    final http.Response response = await http
        .post(
          uri,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Idempotency-Key': BillingRequestId.newKey(),
          },
          body: jsonEncode(payload),
        )
        .timeout(
          const Duration(seconds: 120),
          onTimeout: () => throw PdfServiceException(
            'PDF generation timed out. Please try again.',
          ),
        );

    // Debug: log the response
    debugPrint('╔══════════════════════════════════════════════════════════');
    debugPrint('║ PDF Generation Response');
    debugPrint('║ Status: ${response.statusCode}');
    debugPrint('║ Body: ${response.body}');
    debugPrint('╚══════════════════════════════════════════════════════════');

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw PdfServiceException('Unexpected response format from server.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic billing = decoded['billing'];
      if (billing is Map && Get.isRegistered<BillingController>()) {
        BillingController.instance.updateUsageFromBillingMetadata(
          Map<String, dynamic>.from(billing),
        );
      }
      return PdfGenerationResponse.fromJson(decoded);
    }

    BillingGateHelper.handleError(
      billingApiExceptionFromJson(decoded, statusCode: response.statusCode)
          .error,
    );
    final String errorMessage = _extractError(decoded) ??
        'PDF generation failed with status ${response.statusCode}.';
    throw PdfServiceException(errorMessage);
  }

  // ─── Fetch Existing PDF ──────────────────────────────────────────────
  /// Calls GET /digital-will/pdf/{record_id}
  Future<PdfGenerationResponse> fetchPdf(String recordId) async {
    if (!await BillingGateHelper.ensureFeatureAccess(
      BillingFeatureKeys.digitalWillPdfReport,
    )) {
      throw PdfServiceException('Digital Will PDF reports require Pro.');
    }
    if (_baseUrl == null || _baseUrl.isEmpty) {
      throw PdfServiceException('APIS_BASE_URL is not configured.');
    }

    final Uri uri = Uri.parse('$_baseUrl/digital-will/pdf/$recordId');

    final http.Response response = await http.get(
      uri,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw PdfServiceException(
        'Request timed out. Please try again.',
      ),
    );

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw PdfServiceException('Unexpected response format from server.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PdfGenerationResponse.fromJson(decoded);
    }

    final String errorMessage = _extractError(decoded) ??
        'Failed to fetch PDF with status ${response.statusCode}.';
    throw PdfServiceException(errorMessage);
  }

  // ─── Download PDF File ───────────────────────────────────────────────
  /// Downloads PDF from Cloudflare URL and saves locally.
  /// Returns the local file path.
  Future<String> downloadPdf({
    required String downloadUrl,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory pdfDir = Directory(
      '${appDir.path}/${PdfConstants.pdfCacheDirectoryName}',
    );

    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }

    final String filePath = '${pdfDir.path}/$fileName';
    final File file = File(filePath);

    final http.Client client = http.Client();
    try {
      final http.Request request = http.Request('GET', Uri.parse(downloadUrl));
      final http.StreamedResponse streamedResponse =
          await client.send(request).timeout(
                const Duration(seconds: 60),
                onTimeout: () => throw PdfServiceException(
                  'Download timed out. Please try again.',
                ),
              );

      if (streamedResponse.statusCode != 200) {
        throw PdfServiceException(
          'Download failed with status ${streamedResponse.statusCode}.',
        );
      }

      final int totalBytes = streamedResponse.contentLength ?? -1;
      int receivedBytes = 0;
      final List<int> bytes = <int>[];

      await for (final List<int> chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await file.writeAsBytes(bytes);
      return filePath;
    } finally {
      client.close();
    }
  }

  // ─── Delete Cached PDF ───────────────────────────────────────────────
  Future<bool> deleteCachedPdf(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Get Cache Directory Size ────────────────────────────────────────
  Future<int> getCacheSize() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory pdfDir = Directory(
        '${appDir.path}/${PdfConstants.pdfCacheDirectoryName}',
      );

      if (!await pdfDir.exists()) return 0;

      int totalSize = 0;
      await for (final FileSystemEntity entity in pdfDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (_) {
      return 0;
    }
  }

  // ─── Clear All Cache ─────────────────────────────────────────────────
  Future<void> clearAllCache() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory pdfDir = Directory(
        '${appDir.path}/${PdfConstants.pdfCacheDirectoryName}',
      );

      if (await pdfDir.exists()) {
        await pdfDir.delete(recursive: true);
      }
    } catch (_) {
      // Silently fail
    }
  }

  // ─── Error Extraction ────────────────────────────────────────────────
  String? _extractError(Map<String, dynamic> data) {
    final dynamic detail = data['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      return detail.map((item) {
        if (item is Map<String, dynamic>) {
          return item['msg']?.toString() ?? item.toString();
        }
        return item.toString();
      }).join('; ');
    }
    final dynamic error = data['error'];
    if (error != null) return error.toString();
    final dynamic message = data['message'];
    if (message != null) return message.toString();
    return null;
  }
}

/// Custom exception for PDF service errors.
class PdfServiceException implements Exception {
  const PdfServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

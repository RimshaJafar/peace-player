import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/services/billing_api_service.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:get/get.dart';

import '../models/quran_listening_command_request.dart';
import '../models/quran_listening_command_response.dart';

class QuranListeningService {
  QuranListeningService();

  Future<QuranListeningCommandResponse> sendCommand(
    QuranListeningCommandRequest request,
  ) async {
    final baseUrl =
        (dotenv.env['APIS_BASE_URL'] ?? dotenv.env['API_BASE_URL'])?.trim();
    final parsedBaseUrl = Uri.tryParse(baseUrl ?? '');
    if (baseUrl == null ||
        baseUrl.isEmpty ||
        parsedBaseUrl == null ||
        !parsedBaseUrl.hasScheme ||
        parsedBaseUrl.host.isEmpty) {
      throw const AppConfigurationException(
        'Quran listening is temporarily unavailable.',
      );
    }

    final normalizedBaseUrl =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final uri = Uri.parse('$normalizedBaseUrl/quran-listening/command');
    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Idempotency-Key': BillingRequestId.newKey(),
          },
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      final decoded = safeDecodeJson(response.body);
      try {
        throw billingApiExceptionFromJson(
          decoded,
          statusCode: response.statusCode,
        );
      } catch (error) {
        if (error is BillingApiException) rethrow;
      }
      throw AppUserFacingException(
        ApiErrorParser.parseResponse(
          response,
          fallback: 'Unable to process the command. Please try again.',
        ),
      );
    }

    final decoded = safeDecodeJson(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid Quran listening response.');
    }
    final jsonBody = Map<String, dynamic>.from(decoded);
    final dynamic billing = jsonBody['billing'];
    if (billing is Map && Get.isRegistered<BillingController>()) {
      BillingController.instance.updateUsageFromBillingMetadata(
        Map<String, dynamic>.from(billing),
      );
    }
    return QuranListeningCommandResponse.fromJson(jsonBody);
  }
}

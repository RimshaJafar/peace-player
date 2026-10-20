import 'dart:convert';

import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:ecommerce_app/features/billing/models/billing_models.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BillingApiException implements Exception {
  const BillingApiException(this.error);

  final BillingApiErrorModel error;

  @override
  String toString() =>
      error.message ?? error.errorCode ?? 'Billing request failed.';
}

BillingApiException billingApiExceptionFromJson(
  dynamic value, {
  int? statusCode,
}) {
  final JsonMap body;
  if (value is Map<String, dynamic>) {
    body = value;
  } else if (value is Map) {
    body = value.map(
      (dynamic key, dynamic item) => MapEntry(key.toString(), item),
    );
  } else {
    body = const <String, dynamic>{};
  }
  return BillingApiException(
    BillingApiErrorModel.fromJson(body, statusCode: statusCode),
  );
}

class BillingApiService {
  BillingApiService({String? baseUrl}) : _baseUrl = baseUrl;

  final String? _baseUrl;

  String get _resolvedBaseUrl {
    final String configured = (_baseUrl ??
            dotenv.env['APIS_BASE_URL'] ??
            dotenv.env['API_BASE_URL'] ??
            '')
        .trim();
    if (configured.isEmpty) {
      throw const BillingApiException(
        BillingApiErrorModel(
          success: false,
          errorCode: 'billing_base_url_missing',
          message: 'Billing is temporarily unavailable.',
        ),
      );
    }
    return configured.endsWith('/')
        ? configured.substring(0, configured.length - 1)
        : configured;
  }

  Uri _uri(String path) => Uri.parse('$_resolvedBaseUrl$path');

  Future<BillingProfileModel> getBillingProfile() async {
    final http.Response response = await http
        .get(_uri('/billing/me'))
        .timeout(const Duration(seconds: 20));
    final JsonMap body = _decodeBody(response);
    _throwIfFailed(response.statusCode, body);
    return BillingProfileModel.fromJson(body);
  }

  Future<CheckoutSessionResponseModel> createCheckoutSession(
    String billingPeriod,
  ) async {
    final http.Response response = await http
        .post(
          _uri('/billing/create-checkout-session'),
          headers: const <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(<String, String>{'billingPeriod': billingPeriod}),
        )
        .timeout(const Duration(seconds: 20));
    final JsonMap body = _decodeBody(response);
    _throwIfFailed(response.statusCode, body);
    final CheckoutSessionResponseModel result =
        CheckoutSessionResponseModel.fromJson(body);
    if (!result.success || result.checkoutUrl.isEmpty) {
      throw BillingApiException(BillingApiErrorModel.fromJson(
        body,
        statusCode: response.statusCode,
      ));
    }
    return result;
  }

  Future<BillingProfileModel> confirmCheckoutSession(String sessionId) async {
    final http.Response response = await http
        .post(
          _uri('/billing/confirm-checkout-session'),
          headers: const <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(<String, String>{'sessionId': sessionId}),
        )
        .timeout(const Duration(seconds: 20));
    final JsonMap body = _decodeBody(response);
    _throwIfFailed(response.statusCode, body);

    final JsonMap profileBody = body['profile'] is Map
        ? _asJsonMap(body['profile'])
        : body;
    return BillingProfileModel.fromJson(profileBody);
  }

  Future<PortalSessionResponseModel> createPortalSession() async {
    final http.Response response = await http
        .post(
          _uri('/billing/create-portal-session'),
          headers: const <String, String>{'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 20));
    final JsonMap body = _decodeBody(response);
    _throwIfFailed(response.statusCode, body);
    final PortalSessionResponseModel result =
        PortalSessionResponseModel.fromJson(body);
    if (!result.success || result.portalUrl.isEmpty) {
      throw BillingApiException(BillingApiErrorModel.fromJson(
        body,
        statusCode: response.statusCode,
      ));
    }
    return result;
  }

  JsonMap _decodeBody(http.Response response) {
    if (response.body.trim().isEmpty) return <String, dynamic>{};
    final dynamic decoded = safeDecodeJson(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{
      'success': false,
      'message': 'Billing returned an unexpected response.',
    };
  }

  JsonMap _asJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    return <String, dynamic>{};
  }

  void _throwIfFailed(int statusCode, JsonMap body) {
    if (statusCode >= 200 && statusCode < 300 && body['success'] != false) {
      return;
    }
    throw BillingApiException(
      BillingApiErrorModel.fromJson(body, statusCode: statusCode),
    );
  }
}

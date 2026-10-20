import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfigurationException implements Exception {
  const AppConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppUserFacingException implements Exception {
  const AppUserFacingException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppErrorMessage {
  const AppErrorMessage._();

  static String fromException(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is AppConfigurationException) return error.message;
    if (error is AppUserFacingException) return error.message;
    if (error is TimeoutException) {
      return 'The request timed out. Please check your connection and try again.';
    }
    if (error is FormatException) {
      return 'We could not read the server response. Please try again.';
    }
    if (error is PlatformException) {
      return _platformMessage(error) ?? fallback;
    }

    final raw = error.toString().trim();
    if (_looksLikeNoInternet(raw)) {
      return 'Network connection failed. Please check your internet and try again.';
    }
    if (_looksLikeTimeout(raw)) {
      return 'The request timed out. Please try again.';
    }

    final friendly = _friendlyRawMessage(raw);
    return friendly ?? fallback;
  }

  static String fromStatusCode(
    int statusCode, {
    String? parsedMessage,
    String fallback = 'Something went wrong. Please try again.',
  }) {
    final parsed = sanitize(parsedMessage);
    final code = statusCode;

    if (code == 401) return 'Your session has expired. Please sign in again.';
    if (code == 403) return 'You do not have access to this action.';
    if (code == 400 || code == 422) {
      return parsed ?? 'Please check your request and try again.';
    }
    if (code == 429) {
      return _billingOrQuotaMessage(parsed) ??
          'You have reached the current limit. Please try again later.';
    }
    if (code == 500 || code == 502 || code == 503) {
      return 'The service is temporarily unavailable. Please try again later.';
    }
    if (code == 599) {
      return 'Network request failed. Please check your internet and try again.';
    }

    return parsed ?? fallback;
  }

  static String? sanitize(String? message) {
    if (message == null) return null;
    var value = message.trim();
    if (value.isEmpty) return null;

    value = value
        .replaceFirst(RegExp(r'^(Exception|Error):\s*'), '')
        .replaceAll(RegExp(r'https?:\/\/\S+'), '')
        .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9._\-]+'), '')
        .replaceAll(RegExp(r'(api[_-]?key|token|secret)=\S+', caseSensitive: false), '')
        .trim();

    if (value.isEmpty || _isUnsafeForUser(value)) return null;
    if (value.length > 180) return null;
    return value;
  }

  static String? _platformMessage(PlatformException error) {
    switch (error.code.toLowerCase()) {
      case 'network_error':
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet and try again.';
      case 'permission_denied':
      case 'permission-denied':
        return 'Permission is required to continue.';
      case 'sign_in_canceled':
      case 'canceled':
        return 'The action was cancelled.';
    }
    return null;
  }

  static String? _friendlyRawMessage(String raw) {
    final sanitized = sanitize(raw);
    if (sanitized == null) return null;

    final lower = sanitized.toLowerCase();
    if (lower.contains('cancelled') || lower.contains('canceled')) {
      return 'The action was cancelled.';
    }
    if (lower.contains('permission')) return sanitized;
    if (lower.contains('not configured') || lower.contains('unavailable')) {
      return sanitized;
    }
    if (lower.contains('invalid') && sanitized.length <= 90) return sanitized;
    if (lower.contains('account') && sanitized.length <= 140) return sanitized;
    return null;
  }

  static String? _billingOrQuotaMessage(String? parsed) {
    final lower = parsed?.toLowerCase() ?? '';
    if (lower.contains('quota') || lower.contains('limit')) {
      return parsed;
    }
    if (lower.contains('billing') || lower.contains('payment')) {
      return parsed;
    }
    return null;
  }

  static bool _looksLikeNoInternet(String raw) {
    final lower = raw.toLowerCase();
    return lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('network request failed') ||
        lower.contains('xmlhttprequest error');
  }

  static bool _looksLikeTimeout(String raw) {
    final lower = raw.toLowerCase();
    return lower.contains('timeoutexception') || lower.contains('timed out');
  }

  static bool _isUnsafeForUser(String value) {
    final lower = value.toLowerCase();
    return lower.contains('stacktrace') ||
        lower.contains('firebaseexception') ||
        lower.contains('platformexception') ||
        lower.contains('stripeexception') ||
        lower.contains('clientexception') ||
        lower.contains('socketexception') ||
        lower.contains('traceback') ||
        lower.contains('database') ||
        lower.contains('mongodb') ||
        lower.contains('postgres') ||
        lower.contains('redis') ||
        lower.contains('sql ') ||
        lower.contains('null pointer') ||
        lower.contains('firebase') ||
        lower.contains('localhost') ||
        lower.contains('/api/') ||
        lower.contains('http://') ||
        lower.contains('https://') ||
        lower.contains('bearer ') ||
        lower.contains('token') ||
        lower.contains('secret');
  }
}

class ApiErrorParser {
  const ApiErrorParser._();

  static String parseResponse(
    dynamic response, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    final int statusCode = _statusCodeOf(response);
    final String body = _bodyOf(response);
    final dynamic decoded = safeDecodeJson(body);
    final parsed = messageFromDecoded(decoded);
    return AppErrorMessage.fromStatusCode(
      statusCode,
      parsedMessage: parsed,
      fallback: fallback,
    );
  }

  static String? messageFromDecoded(dynamic decoded) {
    if (decoded == null) return null;
    if (decoded is String) return AppErrorMessage.sanitize(decoded);
    if (decoded is List) {
      for (final item in decoded) {
        final value = messageFromDecoded(item);
        if (value != null) return value;
      }
      return null;
    }
    if (decoded is! Map) return null;

    final map = decoded.map(
      (dynamic key, dynamic value) => MapEntry(key.toString(), value),
    );

    for (final key in const [
      'message',
      'detail',
      'error',
      'error_message',
      'errorMessage',
      'billingError',
      'billing_error',
    ]) {
      final dynamic value = map[key];
      if (value == null) continue;
      final message = messageFromDecoded(value);
      if (message != null) return message;
    }

    final errorCode = map['errorCode'] ?? map['error_code'] ?? map['code'];
    final codeMessage = _messageForErrorCode(errorCode?.toString());
    if (codeMessage != null) return codeMessage;

    final errors = map['errors'];
    final errorsMessage = messageFromDecoded(errors);
    if (errorsMessage != null) return errorsMessage;

    return null;
  }

  static String? _messageForErrorCode(String? code) {
    switch (code?.trim().toLowerCase()) {
      case 'quota_exceeded':
        return 'You have reached the current limit for this feature.';
      case 'rate_limited':
        return 'Too many requests. Please wait a moment and try again.';
      case 'payment_past_due':
        return 'There is a payment issue with your subscription.';
      case 'subscription_expired':
        return 'Your subscription has expired.';
      case 'feature_not_available':
        return 'This feature is not available on your current plan.';
      case 'duplicate_usage_request':
        return 'Please wait for the current request to finish.';
      case 'billing_base_url_missing':
        return 'Billing is temporarily unavailable.';
    }
    return null;
  }

  static int _statusCodeOf(dynamic response) {
    try {
      final dynamic statusCode = response.statusCode;
      if (statusCode is int) return statusCode;
      return int.tryParse(statusCode.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static String _bodyOf(dynamic response) {
    try {
      return response.body?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}

dynamic safeDecodeJson(String? source) {
  final text = source?.trim() ?? '';
  if (text.isEmpty) return null;
  try {
    return jsonDecode(text);
  } catch (_) {
    return null;
  }
}

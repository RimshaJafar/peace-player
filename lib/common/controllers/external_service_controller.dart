import 'dart:convert';

import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/country_model.dart';
import '../models/app_language_model.dart';

class ExternalServiceController extends GetxController {
  late final String apisBaseUrl =
      _normalizedBaseUrl(dotenv.env['APIS_BASE_URL'] ?? 'http://localhost:8000');

  final RxList<Country> countries = <Country>[].obs;
  final RxList<AppLanguage> languages = <AppLanguage>[].obs;
  final RxBool isLoadingCountries = false.obs;
  final RxBool isLoadingLanguages = false.obs;

  Future<void> fetchCountries() async {
    isLoadingCountries.value = true;
    try {
      final Uri uri = Uri.parse('$apisBaseUrl/external-service/countries');
      final http.Response response =
          await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic>? countryList = _readListResponse(data);
        if (countryList != null) {
          countries.value = countryList
              .whereType<Map>()
              .map(
                (e) => Country.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .where((country) => country.name.trim().isNotEmpty)
              .toList();
        }
      }
    } catch (_) {
      // ignore network errors silently -- callers should handle empty list
    } finally {
      isLoadingCountries.value = false;
    }
  }

  Future<void> fetchLanguages() async {
    isLoadingLanguages.value = true;
    try {
      final Uri uri = Uri.parse('$apisBaseUrl/external-service/languages');
      final http.Response response =
          await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic>? languageList = _readListResponse(data);
        if (languageList != null) {
          languages.value = languageList
              .whereType<Map>()
              .map(
                (e) => AppLanguage.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList();
        }
      }
    } catch (_) {
      // ignore
    } finally {
      isLoadingLanguages.value = false;
    }
  }

  Country? getCountryByName(String? name) {
    if (name == null || name.isEmpty) return null;
    try {
      return countries.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      // try contains
      try {
        return countries.firstWhere(
            (c) => c.name.toLowerCase().contains(name.toLowerCase()));
      } catch (_) {
        return null;
      }
    }
  }

  Country? getCountryByCode(String? code) {
    if (code == null || code.isEmpty) return null;
    try {
      return countries
          .firstWhere((c) => c.code.toLowerCase() == code.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  String? getCurrencySymbolForCountryName(String? name) {
    final Country? c = getCountryByName(name);
    if (c != null && c.currencies.isNotEmpty) {
      return c.currencies.values.first;
    }
    return null;
  }

  String? getCurrencyCodeForCountryName(String? name) {
    final Country? c = getCountryByName(name);
    if (c != null && c.currencies.isNotEmpty) {
      return c.currencies.keys.first;
    }
    return null;
  }

  String? getLanguageCodeByName(String? name) {
    if (name == null || name.isEmpty) return null;
    try {
      final lang = languages
          .firstWhere((l) => l.name.toLowerCase() == name.toLowerCase());
      return lang.code;
    } catch (_) {
      return null;
    }
  }

  static String flagEmojiFromCountryCode(String code) {
    if (code.length != 2) return '';
    final int first = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int second = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  /// Search currencies across countries for a given currency code and return symbol
  String? findCurrencySymbolByCode(String currencyCode) {
    if (currencyCode.isEmpty) return null;
    for (final Country c in countries) {
      if (c.currencies.containsKey(currencyCode)) {
        return c.currencies[currencyCode];
      }
    }
    return null;
  }
}

String _normalizedBaseUrl(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) return 'http://localhost:8000';
  return trimmed.replaceFirst(RegExp(r'/+$'), '');
}

List<dynamic>? _readListResponse(dynamic payload) {
  if (payload is List) return payload;
  if (payload is Map && payload['data'] is List) {
    return payload['data'] as List<dynamic>;
  }

  return null;
}

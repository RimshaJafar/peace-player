import 'package:ecommerce_app/features/boycott/models/boycott_model.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';

class BoycottController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  // Boycott data
  final boycottCategories = <BoycottCategory>[].obs;
  final boycottCountries = <BoycottCountry>[].obs;
  final boycottProducts = <BoycottProduct>[].obs;
  final filteredProducts = <BoycottProduct>[].obs;
  final detailedProduct = Rxn<BoycottProductDetail>();
  final productAlternatives = <AlternativeProduct>[].obs;
  final alternativeDetail = Rxn<AlternativeProductDetail>();
  final errorMessage = ''.obs;

  // Boycott loading states
  final isLoadingCategories = false.obs;
  final isLoadingCountries = false.obs;
  final isLoadingProducts = false.obs;
  final isLoadingFiltered = false.obs;
  final isLoadingDetail = false.obs;
  final isLoadingAlternatives = false.obs;
  final isLoadingAlternativeDetail = false.obs;

  Future<void> fetchBoycottCategories() async {
    if (apisBaseUrl == null) return;
    isLoadingCategories.value = true;
    try {
      final res =
          await http.get(Uri.parse("$apisBaseUrl/home/boycottcategories"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is List) {
          boycottCategories.assignAll(
            data.map((e) => BoycottCategory.fromJson(e)).toList(),
          );
        }
      }
    } catch (error, stackTrace) {
      _recordError(
        'Boycott categories error',
        error,
        stackTrace,
        'Unable to load boycott categories. Please try again.',
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchBoycottCountries() async {
    if (apisBaseUrl == null) return;
    isLoadingCountries.value = true;
    try {
      final res =
          await http.get(Uri.parse("$apisBaseUrl/home/boycottcountries"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is List) {
          boycottCountries.assignAll(
            data.map((e) => BoycottCountry.fromJson(e)).toList(),
          );
        }
      }
    } catch (error, stackTrace) {
      _recordError(
        'Boycott countries error',
        error,
        stackTrace,
        'Unable to load countries. Please try again.',
      );
    } finally {
      isLoadingCountries.value = false;
    }
  }

  Future<void> fetchBoycottProducts() async {
    if (apisBaseUrl == null) return;
    isLoadingProducts.value = true;
    try {
      final res =
          await http.get(Uri.parse("$apisBaseUrl/home/boycott-products"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is List) {
          boycottProducts.assignAll(
            data.map((e) => BoycottProduct.fromJson(e)).toList(),
          );
        }
      }
    } catch (error, stackTrace) {
      _recordError(
        'Boycott products error',
        error,
        stackTrace,
        'Unable to load boycott products. Please try again.',
      );
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> fetchFilteredProducts({
    String? category,
    String? level,
    String? country,
    String? keyword,
  }) async {
    if (apisBaseUrl == null) return;
    isLoadingFiltered.value = true;
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (level != null && level.isNotEmpty) {
        queryParams['level'] = level.trim().toLowerCase();
      }
      if (country != null && country.isNotEmpty) {
        queryParams['country'] = country;
      }
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      final uri = Uri.parse("$apisBaseUrl/home/products/filter")
          .replace(queryParameters: queryParams);
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is List) {
          filteredProducts.assignAll(
            data.map((e) => BoycottProduct.fromJson(e)).toList(),
          );
        }
      }
    } catch (error, stackTrace) {
      _recordError(
        'Filtered products error',
        error,
        stackTrace,
        'Unable to filter products. Please try again.',
      );
    } finally {
      isLoadingFiltered.value = false;
    }
  }

  Future<void> fetchProductDetail(String slug) async {
    if (apisBaseUrl == null) return;
    isLoadingDetail.value = true;
    try {
      final res = await http.get(Uri.parse("$apisBaseUrl/home/products/$slug"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is Map<String, dynamic>) {
          detailedProduct.value = BoycottProductDetail.fromJson(data);
        }
      }
    } catch (error, stackTrace) {
      _recordError(
        'Product detail error',
        error,
        stackTrace,
        'Unable to load product details. Please try again.',
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> fetchProductAlternatives(String id) async {
    if (apisBaseUrl == null) return;
    isLoadingAlternatives.value = true;
    try {
      final res = await http
          .get(Uri.parse("$apisBaseUrl/home/products/$id/alternatives"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is List) {
          productAlternatives.assignAll(
            data.map((e) => AlternativeProduct.fromJson(e)).toList(),
          );
        }
      }
    } catch (error, stackTrace) {
      _recordError(
        'Product alternatives error',
        error,
        stackTrace,
        'Unable to load alternatives. Please try again.',
      );
    } finally {
      isLoadingAlternatives.value = false;
    }
  }

  Future<void> fetchAlternativeDetail(String slug) async {
    if (apisBaseUrl == null) return;
    isLoadingAlternativeDetail.value = true;
    try {
      final res =
          await http.get(Uri.parse("$apisBaseUrl/home/alternatives/$slug"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is Map<String, dynamic>) {
          alternativeDetail.value = AlternativeProductDetail.fromJson(data);
        }
      }
    } catch (error, stackTrace) {
      _recordError(
        'Alternative detail error',
        error,
        stackTrace,
        'Unable to load alternative details. Please try again.',
      );
    } finally {
      isLoadingAlternativeDetail.value = false;
    }
  }

  void _recordError(
    String label,
    Object error,
    StackTrace stackTrace,
    String fallback,
  ) {
    errorMessage.value = AppErrorMessage.fromException(
      error,
      fallback: fallback,
    );
    if (!kDebugMode) return;
    debugPrint('$label: $error');
    debugPrint(stackTrace.toString());
  }
}

class BoycottCategory {
  final String category;
  final int totalProducts;

  BoycottCategory({
    required this.category,
    required this.totalProducts,
  });

  factory BoycottCategory.fromJson(Map<String, dynamic> json) {
    return BoycottCategory(
      category: json['category']?.toString() ?? '',
      totalProducts: json['total_products'] ?? 0,
    );
  }
}

class BoycottCountry {
  final String country;
  final int totalProducts;

  BoycottCountry({
    required this.country,
    required this.totalProducts,
  });

  factory BoycottCountry.fromJson(Map<String, dynamic> json) {
    return BoycottCountry(
      country: json['country']?.toString() ?? '',
      totalProducts: json['total_products'] ?? 0,
    );
  }
}

class BoycottProduct {
  final String name;
  final String slug;
  final String country;
  final String image;
  final String category;
  final String? boycottLevel;

  BoycottProduct({
    required this.name,
    required this.slug,
    required this.country,
    required this.image,
    this.category = '',
    this.boycottLevel,
  });

  factory BoycottProduct.fromJson(Map<String, dynamic> json) {
    return BoycottProduct(
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      boycottLevel: _readFirstString(json, const [
        'boycott_level',
        'boycottLevel',
        'boycott level',
        'boycott-level',
        'boycott_level_name',
        'boycottLevelName',
        'boycott_level_text',
        'boycottLevelText',
        'risk_level',
        'riskLevel',
        'level',
      ]),
    );
  }
}

String? _readFirstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _stringValue(json[key]);
    if (value != null && value.trim().isNotEmpty) return value;
  }

  final normalizedKeys = keys.map(_normalizeJsonKey).toSet();
  for (final entry in json.entries) {
    if (normalizedKeys.contains(_normalizeJsonKey(entry.key))) {
      final value = _stringValue(entry.value);
      if (value != null && value.trim().isNotEmpty) return value;
    }
  }

  return null;
}

String _normalizeJsonKey(String key) {
  return key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

String? _stringValue(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  if (value is Map) {
    for (final key in const [
      'name',
      'title',
      'label',
      'value',
      'level',
      'boycott_level',
      'boycottLevel',
    ]) {
      final nestedValue = _stringValue(value[key]);
      if (nestedValue != null && nestedValue.trim().isNotEmpty) {
        return nestedValue;
      }
    }
  }
  return value.toString();
}

class AlternativeProduct {
  final String name;
  final String slug;
  final String country;
  final String image;

  AlternativeProduct({
    required this.name,
    required this.slug,
    required this.country,
    required this.image,
  });

  factory AlternativeProduct.fromJson(Map<String, dynamic> json) {
    return AlternativeProduct(
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
}

class BoycottProductDetail {
  final String id;
  final String name;
  final String slug;
  final String category;
  final String subCategory;
  final String? boycottLevel;
  final String country;
  final String description;
  final List<String> alternatives;
  final List<String> subbrands;
  final List<String> references;
  final String image;

  BoycottProductDetail({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.subCategory,
    this.boycottLevel,
    required this.country,
    required this.description,
    required this.alternatives,
    required this.subbrands,
    required this.references,
    required this.image,
  });

  factory BoycottProductDetail.fromJson(Map<String, dynamic> json) {
    return BoycottProductDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      subCategory: json['sub_category']?.toString() ?? '',
      boycottLevel: json['boycott_level']?.toString(),
      country: json['country']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      alternatives: List<String>.from(json['alternatives'] ?? []),
      subbrands: List<String>.from(json['subbrands'] ?? []),
      references: List<String>.from(json['references'] ?? []),
      image: json['image']?.toString() ?? '',
    );
  }
}

class AlternativeProductDetail {
  final String id;
  final String name;
  final String slug;
  final String category;
  final String subCategory;
  final String country;
  final String description;
  final List<String> subbrands;
  final List<String> references;
  final String image;

  AlternativeProductDetail({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.subCategory,
    required this.country,
    required this.description,
    required this.subbrands,
    required this.references,
    required this.image,
  });

  factory AlternativeProductDetail.fromJson(Map<String, dynamic> json) {
    return AlternativeProductDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      subCategory: json['sub_category']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      subbrands: List<String>.from(json['subbrands'] ?? []),
      references: List<String>.from(json['references'] ?? []),
      image: json['image']?.toString() ?? '',
    );
  }
}

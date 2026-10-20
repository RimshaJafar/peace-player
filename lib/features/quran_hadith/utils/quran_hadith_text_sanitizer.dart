String cleanQuranHadithText(Object? value) {
  if (value == null) return '';
  return value.toString().replaceAll('\uFFFD', '');
}

Map<String, dynamic> cleanQuranHadithTextMap(Object? value) {
  if (value is! Map) return <String, dynamic>{};

  return value.map(
    (key, mapValue) => MapEntry(
      key.toString(),
      _cleanQuranHadithValue(mapValue),
    ),
  );
}

dynamic _cleanQuranHadithValue(dynamic value) {
  if (value is String) return cleanQuranHadithText(value);
  if (value is Map) return cleanQuranHadithTextMap(value);
  if (value is List) return value.map(_cleanQuranHadithValue).toList();
  return value;
}

class AppLanguage {
  AppLanguage({required this.code, required this.name});

  final String code;
  final String name;

  factory AppLanguage.fromJson(Map<String, dynamic> json) {
    return AppLanguage(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

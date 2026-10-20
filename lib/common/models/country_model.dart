class Country {
  Country({
    required this.name,
    required this.code,
    required this.flagPng,
    required this.flagSvg,
    required this.currencies,
    required this.languages,
    required this.phoneCode,
    required this.timezones,
  });

  final String name;
  final String code;
  final String flagPng;
  final String flagSvg;
  final Map<String, String> currencies;
  final Map<String, String> languages;
  final String phoneCode;
  final List<String> timezones;

  factory Country.fromJson(Map<String, dynamic> json) {
    final Map<String, String> currencies = <String, String>{};
    if (json['currencies'] is Map) {
      (json['currencies'] as Map).forEach((k, v) {
        currencies[k.toString()] = v.toString();
      });
    }

    final Map<String, String> languages = <String, String>{};
    if (json['languages'] is Map) {
      (json['languages'] as Map).forEach((k, v) {
        languages[k.toString()] = v.toString();
      });
    }

    final List<String> timezones = <String>[];
    if (json['timezones'] is List) {
      for (final dynamic tz in (json['timezones'] as List)) {
        timezones.add(tz?.toString() ?? '');
      }
    }

    return Country(
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      flagPng: json['flag_png']?.toString() ?? '',
      flagSvg: json['flag_svg']?.toString() ?? '',
      currencies: currencies,
      languages: languages,
      phoneCode: json['phone_code']?.toString() ?? '',
      timezones: timezones,
    );
  }
}

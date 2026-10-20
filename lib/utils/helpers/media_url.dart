import 'package:flutter_dotenv/flutter_dotenv.dart';

class MediaUrlHelper {
  static String resolve(String? url) {
    final raw = (url ?? '').trim();
    if (raw.isEmpty) return '';

    if (_hasScheme(raw)) return raw;

    final base = dotenv.env['APIS_BASE_URL']?.trim();
    if (base == null || base.isEmpty) return raw;

    final normalizedBase =
        base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final normalizedPath = raw.startsWith('/') ? raw : '/$raw';

    return '$normalizedBase$normalizedPath';
  }

  static bool _hasScheme(String value) {
    return value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('data:') ||
        value.startsWith('file:');
  }
}

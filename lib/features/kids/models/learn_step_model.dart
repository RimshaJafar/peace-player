import 'package:ecommerce_app/utils/helpers/media_url.dart';
import 'package:flutter/foundation.dart';

class LearnStepTag {
  final String main;
  final String sub;

  LearnStepTag({
    required this.main,
    required this.sub,
  });

  factory LearnStepTag.fromJson(Map<String, dynamic> json) {
    return LearnStepTag(
      main: json['main'] ?? '',
      sub: json['sub'] ?? '',
    );
  }
}

class LearnStep {
  final String id;
  final LearnStepTag tag;
  final int step;
  final Map<String, dynamic> title;
  final Map<String, dynamic> text;
  final String imageUrl;
  final String createdAt;

  LearnStep({
    required this.id,
    required this.tag,
    required this.step,
    required this.title,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
  });

  factory LearnStep.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json['image_url']?.toString().trim() ?? '';
    final resolvedImageUrl = MediaUrlHelper.resolve(rawImageUrl);

    if (kDebugMode && resolvedImageUrl.isEmpty) {
      debugPrint(
        '[LearnStep] empty image_url after parse. '
        'step=${json['step']} keys=${json.keys.join(', ')} '
        'image_url=${_debugField(json['image_url'])} '
      );
    }

    return LearnStep(
      id: json['_id'] ?? '',
      tag: LearnStepTag.fromJson(json['tag'] ?? {}),
      step: json['step'] ?? 0,
      title: json['title'] ?? {},
      text: json['text'] ?? {},
      imageUrl: resolvedImageUrl,
      createdAt: json['created_at'] ?? '',
    );
  }

  static String _debugField(Object? value) {
    if (value == null) return 'null';

    final text = value.toString().trim();
    if (text.isEmpty) return 'empty';

    final uri = Uri.tryParse(text);
    final host = uri == null || uri.host.isEmpty ? 'no-host' : uri.host;
    return 'len=${text.length}, host=$host';
  }
}

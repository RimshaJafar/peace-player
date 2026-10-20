class WorshipItem {
  final String id;
  final String? contentHash;
  final String? source;
  final Map<String, String> tag; // main, sub
  final Map<String, String> title; // en, ur
  final String? textArabic;
  final Map<String, String> translations; // en, ur
  final String? description;
  final String? createdAt; // ISO string
  final bool? isSaved;

  WorshipItem({
    required this.id,
    this.contentHash,
    this.source,
    Map<String, String>? tag,
    Map<String, String>? title,
    this.textArabic,
    Map<String, String>? translations,
    this.description,
    this.createdAt,
    this.isSaved,
  })  : tag = tag ?? const {},
        title = title ?? const {},
        translations = translations ?? const {};

  factory WorshipItem.fromJson(Map<String, dynamic> json) {
    return WorshipItem(
      id: json['_id']?.toString() ?? '',
      contentHash: json['content_hash']?.toString(),
      source: json['source']?.toString(),
      tag: Map<String, String>.from(json['tag'] ?? {}),
      title: Map<String, String>.from(json['title'] ?? {}),
      textArabic: json['text_arabic']?.toString(),
      translations: Map<String, String>.from(json['translations'] ?? {}),
      description: json['description']?.toString(),
      createdAt: json['created_at']?.toString(),
      isSaved: json['is_saved'] == null ? null : json['is_saved'] == true,
    );
  }

  Map<String, dynamic> toSavePayload({required String userId}) {
    return {
      'user_id': userId,
      'worship_content_id': id,
      if (textArabic != null) 'text_arabic': textArabic,
      if (tag.isNotEmpty) 'tag': tag,
      if (title.isNotEmpty) 'title': title,
      if (translations.isNotEmpty) 'translations': translations,
      if (description != null) 'description': description,
      if (source != null) 'source': source,
    };
  }
}

class WorshipListResponse {
  final List<WorshipItem> items;

  WorshipListResponse({required this.items});

  factory WorshipListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List? ?? [])
        .map((e) => WorshipItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return WorshipListResponse(items: list);
  }
}

class SaveStatusResponse {
  final String status;
  final String? worshipContentId;

  SaveStatusResponse({required this.status, this.worshipContentId});

  factory SaveStatusResponse.fromJson(Map<String, dynamic> json) {
    final dynamic idRaw = json['worship_content_id'];
    String? id;
    if (idRaw == null) {
      id = null;
    } else if (idRaw is String) {
      id = idRaw;
    } else if (idRaw is Map && idRaw['\$oid'] != null) {
      id = idRaw['\$oid'].toString();
    } else {
      id = idRaw.toString();
    }
    return SaveStatusResponse(
      status: (json['status'] ?? '').toString(),
      worshipContentId: id,
    );
  }
}

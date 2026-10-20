import 'package:ecommerce_app/utils/helpers/media_url.dart';

class CreatorProfileLinks {
  final String instagramUrl;
  final String youtubeUrl;
  final String tiktokUrl;
  final String facebookUrl;

  const CreatorProfileLinks({
    this.instagramUrl = '',
    this.youtubeUrl = '',
    this.tiktokUrl = '',
    this.facebookUrl = '',
  });

  factory CreatorProfileLinks.fromJson(Map<String, dynamic>? json) {
    return CreatorProfileLinks(
      instagramUrl: json?['instagram_url']?.toString() ?? '',
      youtubeUrl: json?['youtube_url']?.toString() ?? '',
      tiktokUrl: json?['tiktok_url']?.toString() ?? '',
      facebookUrl: json?['facebook_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instagram_url': instagramUrl,
      'youtube_url': youtubeUrl,
      'tiktok_url': tiktokUrl,
      'facebook_url': facebookUrl,
    };
  }
}

class SeriesVideoModel {
  final String videoId;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String creatorName;
  final CreatorProfileLinks creatorProfileLinks;
  final DateTime? scheduledDate;

  const SeriesVideoModel({
    this.videoId = '',
    this.title = '',
    this.description = '',
    this.videoUrl = '',
    this.thumbnailUrl = '',
    this.creatorName = '',
    this.creatorProfileLinks = const CreatorProfileLinks(),
    this.scheduledDate,
  });

  factory SeriesVideoModel.fromJson(Map<String, dynamic> json) {
    final profileLinks = json['creator_profile_links'];
    final rawVideoUrl = json['video_url'] ?? json['videoUrl'];
    final rawThumbnailUrl = json['thumbnail_url'] ??
        json['thumbnailUrl'] ??
        json['thumbnail'] ??
        json['thumb_url'];

    return SeriesVideoModel(
      videoId: json['video_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      videoUrl: MediaUrlHelper.resolve(rawVideoUrl?.toString()),
      thumbnailUrl: MediaUrlHelper.resolve(rawThumbnailUrl?.toString()),
      creatorName: json['creator_name']?.toString() ?? '',
      creatorProfileLinks: CreatorProfileLinks.fromJson(
        profileLinks is Map<String, dynamic> ? profileLinks : null,
      ),
      scheduledDate: _parseDate(json['scheduled_date']),
    );
  }

  String get displayTitle => title.isNotEmpty ? title : 'Untitled Series';

  String get displayDescription => description.isNotEmpty
      ? description
      : 'This video explores inspiring Islamic stories and teachings.';

  String get displayCreatorName =>
      creatorName.isNotEmpty ? creatorName : 'Peace Player Creator';

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'creator_name': creatorName,
      'creator_profile_links': creatorProfileLinks.toJson(),
      'scheduled_date': scheduledDate?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

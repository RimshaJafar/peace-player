import 'package:ecommerce_app/features/creator_series/models/series_video_model.dart';
import 'package:ecommerce_app/utils/helpers/media_url.dart';

class CreatorVideoModel {
  final String videoId;
  final String firebaseUserId;
  final String creatorId;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String category;
  final List<String> tags;
  final String sourcePlatform;
  final DateTime? preferredDate;
  final DateTime? scheduledDate;
  final String status;
  final bool isApproved;
  final int? duration;
  final String language;
  final DateTime? createdAt;

  const CreatorVideoModel({
    this.videoId = '',
    this.firebaseUserId = '',
    this.creatorId = '',
    this.title = '',
    this.description = '',
    this.videoUrl = '',
    this.thumbnailUrl = '',
    this.category = '',
    this.tags = const [],
    this.sourcePlatform = '',
    this.preferredDate,
    this.scheduledDate,
    this.status = '',
    this.isApproved = false,
    this.duration,
    this.language = '',
    this.createdAt,
  });

  factory CreatorVideoModel.fromJson(Map<String, dynamic> json) {
    final rawVideoUrl = json['video_url'] ?? json['videoUrl'];
    final rawThumbnailUrl = json['thumbnail_url'] ??
        json['thumbnailUrl'] ??
        json['thumbnail'] ??
        json['thumb_url'];

    return CreatorVideoModel(
      videoId: json['video_id']?.toString() ?? '',
      firebaseUserId: json['firebase_user_id']?.toString() ?? '',
      creatorId: json['creator_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      videoUrl: MediaUrlHelper.resolve(rawVideoUrl?.toString()),
      thumbnailUrl: MediaUrlHelper.resolve(rawThumbnailUrl?.toString()),
      category: json['category']?.toString() ?? '',
      tags: json['tags'] is List
          ? List<String>.from(json['tags'].map((tag) => tag.toString()))
          : const [],
      sourcePlatform: json['source_platform']?.toString() ?? '',
      preferredDate: _parseDate(json['preferred_date']),
      scheduledDate: _parseDate(json['scheduled_date']),
      status: json['status']?.toString() ?? '',
      isApproved: json['is_approved'] == true,
      duration: _parseInt(json['duration']),
      language: json['language']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']),
    );
  }

  String get displayTitle => title.isNotEmpty ? title : 'Untitled Video';

  String get displayDescription => description.isNotEmpty
      ? description
      : 'No description has been added for this video.';

  String get displayCategory => category.isNotEmpty ? category : 'General';

  String get displayStatus => status.isNotEmpty ? _capitalize(status) : 'Draft';

  SeriesVideoModel toSeriesVideo({String creatorName = ''}) {
    return SeriesVideoModel(
      videoId: videoId,
      title: title,
      description: description,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      creatorName: creatorName,
      scheduledDate: scheduledDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'firebase_user_id': firebaseUserId,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'category': category,
      'tags': tags,
      'source_platform': sourcePlatform,
      'preferred_date': preferredDate?.toIso8601String(),
      'scheduled_date': scheduledDate?.toIso8601String(),
      'status': status,
      'is_approved': isApproved,
      'duration': duration,
      'language': language,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
  }
}

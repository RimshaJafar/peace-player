import 'package:ecommerce_app/utils/helpers/media_url.dart';

class VideoUploadModel {
  String? videoId;
  String? firebaseUserId;
  String? creatorId;
  String? title;
  String? description;
  String? videoUrl;
  String? thumbnailUrl;
  String? category;
  List<String>? tags;
  String? sourcePlatform;
  String? preferredDate;
  String? scheduledDate;
  String? status;
  bool? isApproved;
  int? duration;
  String? language;
  String? createdAt;

  VideoUploadModel({
    this.videoId,
    this.firebaseUserId,
    this.creatorId,
    this.title,
    this.description,
    this.videoUrl,
    this.thumbnailUrl,
    this.category,
    this.tags,
    this.sourcePlatform,
    this.preferredDate,
    this.scheduledDate,
    this.status,
    this.isApproved,
    this.duration,
    this.language,
    this.createdAt,
  });

  factory VideoUploadModel.fromJson(Map<String, dynamic> json) {
    final rawVideoUrl = json['video_url'] ?? json['videoUrl'];
    final rawThumbnailUrl = json['thumbnail_url'] ??
        json['thumbnailUrl'] ??
        json['thumbnail'] ??
        json['thumb_url'];

    return VideoUploadModel(
      videoId: json['video_id']?.toString(),
      firebaseUserId: json['firebase_user_id']?.toString(),
      creatorId: json['creator_id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      videoUrl: MediaUrlHelper.resolve(rawVideoUrl?.toString()),
      thumbnailUrl: MediaUrlHelper.resolve(rawThumbnailUrl?.toString()),
      category: json['category']?.toString(),
      tags: json['tags'] is List ? List<String>.from(json['tags']) : [],
      sourcePlatform: json['source_platform']?.toString(),
      preferredDate: json['preferred_date']?.toString(),
      scheduledDate: json['scheduled_date']?.toString(),
      status: json['status']?.toString(),
      isApproved: json['is_approved'] ?? false,
      duration: json['duration'] is int
          ? json['duration'] as int
          : (json['duration'] != null
              ? int.tryParse(json['duration'].toString())
              : null),
      language: json['language']?.toString(),
      createdAt: json['created_at']?.toString(),
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
      'preferred_date': preferredDate,
      'scheduled_date': scheduledDate,
      'status': status,
      'is_approved': isApproved,
      'duration': duration,
      'language': language,
      'created_at': createdAt,
    };
  }
}

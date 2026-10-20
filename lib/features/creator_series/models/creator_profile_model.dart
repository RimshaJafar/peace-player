// CreatorProfileModel uses the same structure as CreatorRegisterModel
// since the backend returns the same response schema for both endpoints

class CreatorProfileSocialLinks {
  final String instagramUrl;
  final String youtubeUrl;
  final String tiktokUrl;
  final String facebookUrl;

  CreatorProfileSocialLinks({
    required this.instagramUrl,
    required this.youtubeUrl,
    required this.tiktokUrl,
    required this.facebookUrl,
  });

  factory CreatorProfileSocialLinks.fromJson(Map<String, dynamic> json) {
    return CreatorProfileSocialLinks(
      instagramUrl: json['instagram_url']?.toString() ?? '',
      youtubeUrl: json['youtube_url']?.toString() ?? '',
      tiktokUrl: json['tiktok_url']?.toString() ?? '',
      facebookUrl: json['facebook_url']?.toString() ?? '',
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

class CreatorProfileModel {
  final String creatorId;
  final String firebaseUserId;
  final String fullName;
  final String email;
  final String country;
  final String bio;
  final CreatorProfileSocialLinks socialLinks;
  final String contentCategory;
  final String sampleVideoUrl;
  final String role;
  final bool isCreator;
  final bool isApproved;
  final bool isRejected;
  final String status;
  final String createdAt;
  final String updatedAt;

  CreatorProfileModel({
    required this.creatorId,
    required this.firebaseUserId,
    required this.fullName,
    required this.email,
    required this.country,
    required this.bio,
    required this.socialLinks,
    required this.contentCategory,
    required this.sampleVideoUrl,
    required this.role,
    required this.isCreator,
    required this.isApproved,
    required this.isRejected,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreatorProfileModel.fromJson(Map<String, dynamic> json) {
    return CreatorProfileModel(
      creatorId: json['creator_id']?.toString() ?? '',
      firebaseUserId: json['firebase_user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      socialLinks: CreatorProfileSocialLinks.fromJson(
          json['social_links'] ?? <String, dynamic>{}),
      contentCategory: json['content_category']?.toString() ?? '',
      sampleVideoUrl: json['sample_video_url']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      isCreator: json['is_creator'] ?? false,
      isApproved: json['is_approved'] ?? false,
      isRejected: json['is_rejected'] ?? false,
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creator_id': creatorId,
      'firebase_user_id': firebaseUserId,
      'full_name': fullName,
      'email': email,
      'country': country,
      'bio': bio,
      'social_links': socialLinks.toJson(),
      'content_category': contentCategory,
      'sample_video_url': sampleVideoUrl,
      'role': role,
      'is_creator': isCreator,
      'is_approved': isApproved,
      'is_rejected': isRejected,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

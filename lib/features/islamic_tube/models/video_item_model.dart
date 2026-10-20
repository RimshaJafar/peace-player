class VideoItem {
  final String videoId;
  final String videoUrl;
  final String title;
  final String description;
  final String thumbnailUrl;

  VideoItem({
    required this.videoId,
    required this.videoUrl,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      videoId: json['video_id'],
      videoUrl: json['video_url'],
      title: json['title'],
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
    );
  }
}

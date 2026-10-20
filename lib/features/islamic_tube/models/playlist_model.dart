class Playlist {
  final String playlistId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int totalVideos;

  Playlist({
    required this.playlistId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.totalVideos,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      playlistId: json['playlist_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      totalVideos: (json['total_videos'] is int)
          ? json['total_videos'] as int
          : int.tryParse(json['total_videos']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlist_id': playlistId,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'total_videos': totalVideos,
    };
  }
}

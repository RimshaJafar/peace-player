class QuranListeningCommandRequest {
  final String text;

  QuranListeningCommandRequest({required this.text});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}

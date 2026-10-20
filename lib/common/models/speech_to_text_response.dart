class SpeechToTextResponse {
  final String text;
  final String language;

  SpeechToTextResponse({
    required this.text,
    required this.language,
  });

  factory SpeechToTextResponse.fromJson(Map<String, dynamic> json) {
    return SpeechToTextResponse(
      text: json['text'] ?? '',
      language: json['language'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'language': language,
      };
}

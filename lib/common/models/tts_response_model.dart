import 'tts_segment_model.dart';

class TTSResponse {
  final String audioData;
  final List<TTSSegment> segments;

  TTSResponse({
    required this.audioData,
    required this.segments,
  });

  factory TTSResponse.fromJson(Map<String, dynamic> json) {
    final segmentsList = (json['segments'] as List?)
            ?.map((e) => TTSSegment.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return TTSResponse(
      audioData: json['audio_data'] ?? '',
      segments: segmentsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'audio_data': audioData,
        'segments': segments.map((e) => e.toJson()).toList(),
      };
}

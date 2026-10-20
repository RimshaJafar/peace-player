import 'package:flutter/material.dart';

/// Reusable playback controls widget with skip, play/pause, shuffle, and share buttons.
class PlaybackControls extends StatelessWidget {
  const PlaybackControls({
    super.key,
    required this.isPlaying,
    required this.onSkipPrevious,
    required this.onPlayPause,
    required this.onSkipNext,
    required this.onShuffle,
    required this.onShare,
  });

  final bool isPlaying;
  final VoidCallback onSkipPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipNext;
  final VoidCallback onShuffle;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Playback controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 50,
              icon: const Icon(Icons.skip_previous_rounded),
              color: Colors.black54,
              onPressed: onSkipPrevious,
            ),
            const SizedBox(width: 16),
            IconButton(
              iconSize: 72,
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.green[700],
              ),
              onPressed: onPlayPause,
            ),
            const SizedBox(width: 16),
            IconButton(
              iconSize: 52,
              icon: const Icon(Icons.skip_next_rounded),
              color: Colors.black54,
              onPressed: onSkipNext,
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Shuffle and share
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.shuffle),
              color: Colors.black54,
              onPressed: onShuffle,
            ),
            const SizedBox(width: 40),
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.share),
              color: Colors.black54,
              onPressed: onShare,
            ),
          ],
        ),
      ],
    );
  }
}

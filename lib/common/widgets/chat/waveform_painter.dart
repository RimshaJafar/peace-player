import 'package:flutter/material.dart';
import 'dart:math' show sin, pi, pow;

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color waveColor;
  final double opacity;
  final double animationPhase; // For running dotted line animation

  // Threshold for speech detection
  static const double _speakingThreshold = 0.50;
  static const int _barCount = 40;

  WaveformPainter({
    required this.amplitudes,
    this.waveColor = const Color(0xFF329070),
    this.opacity = 1.0,
    this.animationPhase = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final centerY = size.height / 2;

    // Calculate average amplitude from recent values
    final recentAmplitudes = amplitudes.length > 20
        ? amplitudes.sublist(amplitudes.length - 20)
        : amplitudes;

    final avgAmplitude = recentAmplitudes.isNotEmpty
        ? recentAmplitudes.reduce((a, b) => a + b) / recentAmplitudes.length
        : 0.0;

    // Create a fixed set of amplitudes for consistent visualization
    final interpolatedAmps = _interpolateAmplitudes(_barCount);
    // Apply light spatial smoothing across bars so adjacent bars connect smoothly
    final smoothedAmps = _smoothAmplitudes(interpolatedAmps);

    // Blend factor between idle pulse (0.0) and speaking bars (1.0).
    // This creates an immediate but smooth transition rather than an abrupt switch.
    final blend = _blendForAmplitude(avgAmplitude);

    // Draw both layers every frame, blending their opacities for a smooth transition.
    _drawPulseLine(canvas, size, centerY, blend);
    _drawSmoothBars(canvas, size, centerY, smoothedAmps, blend);
  }

  void _drawSmoothBars(Canvas canvas, Size size, double centerY,
      List<double> amplitudesForBars, double blend) {
    const barWidth = 1.8; // Thin bars for ChatGPT style
    const spacing = 1.2; // Tight spacing
    const maxHeight = 0.75; // Max 75% of container height
    const minHeight = 3.0; // Minimum visible height for silence
    final maxHeightPixels = size.height * maxHeight;

    final totalBarsWidth = _barCount * (barWidth + spacing);
    final startX = (size.width - totalBarsWidth) / 2;

    for (int i = 0; i < amplitudesForBars.length; i++) {
      final rawAmp = amplitudesForBars[i].clamp(0.0, 1.0);

      // Apply easing for natural motion
      final easedAmplitude = _easingCurve(rawAmp);

      // Height scaled by blend so bars gracefully appear/disappear
      final barHeight =
          minHeight + easedAmplitude * (maxHeightPixels - minHeight) * blend;

      final offsetX = startX + (i * (barWidth + spacing));

      final paint = Paint()
        ..color = waveColor.withValues(alpha: opacity * blend)
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTWH(
        offsetX,
        centerY - barHeight / 2,
        barWidth,
        barHeight,
      );

      final rRect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(barWidth / 2),
      );

      canvas.drawRRect(rRect, paint);
    }
  }

  void _drawPulseLine(Canvas canvas, Size size, double centerY, double blend) {
    const dotRadius = 2.0;
    const spacing = 8.0;
    final lineY = centerY;

    final dotsPerLine = (size.width / spacing).toInt();
    final totalDotsWidth = dotsPerLine * spacing;
    var startX = (size.width - totalDotsWidth) / 2;

    // Gentle breathing animation
    final breathingScale = 0.75 + (sin(animationPhase * pi * 2) * 0.12);

    // Pulse opacity is diminished as speaking blend increases
    final pulseOpacity = opacity * (1.0 - blend) * breathingScale;

    for (int i = 0; i < dotsPerLine; i++) {
      final x = startX + (i * spacing);
      if (x > 0 && x < size.width) {
        final dotPaint = Paint()
          ..color = waveColor.withValues(alpha: pulseOpacity)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, lineY), dotRadius, dotPaint);
      }
    }
  }

  /// Apply a small smoothing kernel across the bar amplitudes so neighboring
  /// bars flow into each other instead of jumping abruptly.
  List<double> _smoothAmplitudes(List<double> amps) {
    if (amps.length <= 2) return List.from(amps);
    final out = List<double>.filled(amps.length, 0.0);
    for (int i = 0; i < amps.length; i++) {
      final left = i - 1 >= 0 ? amps[i - 1] : amps[i];
      final center = amps[i];
      final right = i + 1 < amps.length ? amps[i + 1] : amps[i];
      out[i] = (left * 0.25) + (center * 0.5) + (right * 0.25);
    }
    return out;
  }

  /// Convert average amplitude into a smooth blend factor [0..1]
  double _blendForAmplitude(double avg) {
    final low = (_speakingThreshold - 0.10).clamp(0.0, 1.0);
    final high = (_speakingThreshold + 0.10).clamp(0.0, 1.0);
    final raw = ((avg - low) / (high - low)).clamp(0.0, 1.0);
    return _easingCurve(raw);
  }

  /// Interpolate amplitudes to a fixed count for smooth visualization
  List<double> _interpolateAmplitudes(int targetCount) {
    if (amplitudes.isEmpty) {
      return List.filled(targetCount, 0.0);
    }

    if (amplitudes.length >= targetCount) {
      // Sample down if we have more amplitudes
      final step = amplitudes.length / targetCount;
      return List.generate(targetCount, (i) {
        final index = (i * step).toInt().clamp(0, amplitudes.length - 1);
        return amplitudes[index];
      });
    }

    // Interpolate up if we have fewer amplitudes
    final result = <double>[];
    for (int i = 0; i < targetCount; i++) {
      final position = (i / targetCount) * amplitudes.length;
      final lowerIndex = position.toInt().clamp(0, amplitudes.length - 1);
      final upperIndex = (lowerIndex + 1).clamp(0, amplitudes.length - 1);

      if (lowerIndex == upperIndex) {
        result.add(amplitudes[lowerIndex]);
      } else {
        final lerpFactor = position - lowerIndex;
        final interpolated = amplitudes[lowerIndex] * (1 - lerpFactor) +
            amplitudes[upperIndex] * lerpFactor;
        result.add(interpolated);
      }
    }
    return result;
  }

  /// Smooth easing curve for more natural bar movement
  double _easingCurve(double t) {
    // Ease-out cubic for smooth deceleration
    final p = t;
    return 1.0 - pow(1.0 - p, 3.0).toDouble();
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes ||
        oldDelegate.waveColor != waveColor ||
        oldDelegate.opacity != opacity ||
        oldDelegate.animationPhase != animationPhase;
  }
}

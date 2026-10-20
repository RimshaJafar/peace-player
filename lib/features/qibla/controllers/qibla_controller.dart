import 'dart:async';
import 'dart:math' as math;

import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class QiblaController extends GetxController {
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  final qiblaDirection = Rxn<double>();
  final deviceDirection = 0.0.obs;
  final isLoading = true.obs;
  final error = Rxn<String>();
  final isCompassAvailable = false.obs;

  final _headingBuffer = <double>[];
  static const int _bufferSize = 5;
  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void onInit() {
    super.onInit();
    unawaited(_initQibla());
    _listenToCompass();
  }

  @override
  void onClose() {
    unawaited(_compassSub?.cancel());
    _compassSub = null;
    super.onClose();
  }

  void _listenToCompass() {
    unawaited(_compassSub?.cancel());
    _compassSub = null;
    final events = FlutterCompass.events;
    if (events == null) {
      isCompassAvailable.value = false;
      error.value = 'Compass is not available on this device.';
      return;
    }

    isCompassAvailable.value = true;
    _compassSub = events.listen(
      (event) {
        final heading = event.heading ?? 0;
        final headingForUi = event.headingForCameraMode ?? heading;
        _headingBuffer.add(headingForUi);
        if (_headingBuffer.length > _bufferSize) {
          _headingBuffer.removeAt(0);
        }
        deviceDirection.value = _smoothHeading(_headingBuffer);
      },
      onError: (Object streamError, StackTrace stackTrace) {
        if (kDebugMode) {
          debugPrint('[Qibla] Compass stream failed: $streamError');
          debugPrint(stackTrace.toString());
        }
        isCompassAvailable.value = false;
        error.value =
            'Compass readings are unavailable. Recalibrate your device and try again.';
        PLoaders.warningSnackBar(
          title: 'Compass Unavailable',
          message:
              'Move your phone in a figure-eight motion to recalibrate, then retry.',
        );
      },
      cancelOnError: true,
    );
  }

  double _smoothHeading(List<double> readings) {
    if (readings.isEmpty) return 0.0;
    var sinSum = 0.0;
    var cosSum = 0.0;
    for (final heading in readings) {
      final radians = heading * math.pi / 180;
      sinSum += math.sin(radians);
      cosSum += math.cos(radians);
    }
    final averageRadians = math.atan2(
      sinSum / readings.length,
      cosSum / readings.length,
    );
    return (averageRadians * 180 / math.pi + 360) % 360;
  }

  void recalculateQibla() {
    isLoading.value = true;
    error.value = null;
    if (!isCompassAvailable.value || _compassSub == null) {
      _listenToCompass();
    }
    unawaited(_initQibla());
  }

  Future<void> _initQibla() async {
    isLoading.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const AppUserFacingException(
          'Location services are disabled. Turn them on and try again.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const AppUserFacingException(
          'Location permission is disabled. Enable it in app settings.',
        );
      }
      if (permission == LocationPermission.denied) {
        throw const AppUserFacingException(
          'Location permission is required to calculate Qibla.',
        );
      }

      final position = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 15));
      qiblaDirection.value = _calculateQibla(
        position.latitude,
        position.longitude,
      );
    } catch (caughtError, stackTrace) {
      error.value = AppErrorMessage.fromException(
        caughtError,
        fallback: 'Unable to calculate Qibla. Please try again.',
      );
      if (kDebugMode) {
        debugPrint('[Qibla] Initialization failed: $caughtError');
        debugPrint(stackTrace.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  double _calculateQibla(double lat, double lng) {
    final latRad = _degToRad(lat);
    final lngRad = _degToRad(lng);
    final kaabaLatRad = _degToRad(kaabaLat);
    final kaabaLngRad = _degToRad(kaabaLng);
    final y = math.sin(kaabaLngRad - lngRad);
    final x = math.cos(latRad) * math.tan(kaabaLatRad) -
        math.sin(latRad) * math.cos(kaabaLngRad - lngRad);
    return (_radToDeg(math.atan2(y, x)) + 360) % 360;
  }

  double _degToRad(double degrees) => degrees * math.pi / 180;
  double _radToDeg(double radians) => radians * 180 / math.pi;

  String get guidanceMessage {
    if (qiblaDirection.value == null) return 'Calculating direction...';
    final delta =
        ((qiblaDirection.value! - deviceDirection.value + 540) % 360) - 180;
    final absoluteDelta = delta.abs();
    if (absoluteDelta < 5) return 'Aligned to Qibla';
    final direction = delta > 0 ? 'right' : 'left';
    return 'Turn $direction about ${absoluteDelta.toStringAsFixed(0)} degrees to face Qibla';
  }

  bool get isAligned {
    if (qiblaDirection.value == null) return false;
    final delta =
        ((qiblaDirection.value! - deviceDirection.value + 540) % 360) - 180;
    return delta.abs() < 5;
  }

  double get relativeQiblaAngle {
    if (qiblaDirection.value == null) return 0.0;
    return (qiblaDirection.value! - deviceDirection.value) * math.pi / 180;
  }

  double get deviceHeadingRadians {
    return deviceDirection.value * math.pi / 180;
  }
}

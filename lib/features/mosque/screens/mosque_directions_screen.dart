import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/features/mosque/controllers/mosque_controller.dart';
import 'package:ecommerce_app/features/mosque/models/mosque_model.dart';
import 'package:ecommerce_app/features/mosque/models/navigation_model.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

class MosqueDirectionsScreen extends StatefulWidget {
  const MosqueDirectionsScreen({super.key, required this.mosque});

  final Mosque mosque;

  @override
  State<MosqueDirectionsScreen> createState() => _MosqueDirectionsScreenState();
}

class _MosqueDirectionsScreenState extends State<MosqueDirectionsScreen> {
  late final MosqueController _controller;
  late final AudioTTSSTTController _audioController;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionSub;
  LatLng? _currentPosition;
  int _currentStepIndex = 0;
  bool _followUser = true;
  bool _voiceGuidanceEnabled = true;
  int _lastSpokenStepIndex = -1;
  DateTime _lastSpokenAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastRouteRefresh = DateTime.fromMillisecondsSinceEpoch(0);
  LatLng? _lastReroutePosition;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<MosqueController>();
    if (!Get.isRegistered<AudioTTSSTTController>()) {
      Get.put(AudioTTSSTTController());
    }
    _audioController = Get.find<AudioTTSSTTController>();
    _initDirections();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _initDirections() async {
    final hasLocation =
        _controller.hasLocation.value || await _controller.getCurrentLocation();
    if (!mounted) return;
    if (!hasLocation) {
      setState(() {
        _localError = 'Location unavailable. Please enable GPS.';
      });
      return;
    }

    setState(() {
      _currentPosition = LatLng(
        _controller.currentLat.value,
        _controller.currentLon.value,
      );
    });

    await _loadRoute();
    if (!mounted) return;
    _startTracking();
  }

  Future<void> _loadRoute() async {
    _localError = null;
    await _controller.fetchWalkingRoute(
      destLat: widget.mosque.location.lat,
      destLon: widget.mosque.location.lon,
    );
    _updateStepProgress();
    final route = _controller.currentRoute.value;
    if (route != null && route.steps.isNotEmpty) {
      _maybeSpeakStep(route.steps[_currentStepIndex]);
    }
  }

  void _startTracking() {
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 8,
      ),
    ).listen(
      (position) {
        final updated = LatLng(position.latitude, position.longitude);
        _handlePositionUpdate(updated);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          debugPrint('[MosqueDirections] Location stream failed: $error');
          debugPrint(stackTrace.toString());
        }
        if (!mounted) return;
        setState(() {
          _localError = AppErrorMessage.fromException(
            error,
            fallback: 'Location tracking stopped. Please try again.',
          );
        });
      },
      cancelOnError: true,
    );
  }

  void _handlePositionUpdate(LatLng position) {
    _currentPosition = position;
    _controller.currentLat.value = position.latitude;
    _controller.currentLon.value = position.longitude;

    if (_followUser) {
      final zoom = _mapController.camera.zoom;
      _mapController.move(position, zoom);
    }

    _updateStepProgress();
    _maybeReroute(position);
    if (mounted) {
      setState(() {});
    }
  }

  void _maybeReroute(LatLng position) {
    final now = DateTime.now();
    final timeSinceLast = now.difference(_lastRouteRefresh);
    final lastPos = _lastReroutePosition;

    final movedEnough =
        lastPos == null || _distanceMeters(lastPos, position) > 40;
    final timeEnough = timeSinceLast.inSeconds > 30;

    if (movedEnough && timeEnough) {
      _lastRouteRefresh = now;
      _lastReroutePosition = position;
      _loadRoute();
    }
  }

  void _updateStepProgress() {
    final route = _controller.currentRoute.value;
    final position = _currentPosition;
    if (route == null || route.steps.isEmpty || position == null) {
      return;
    }

    final nextIndex = _resolveCurrentStepIndex(route, position);
    if (nextIndex != _currentStepIndex) {
      _currentStepIndex = nextIndex;
      _maybeSpeakStep(route.steps[_currentStepIndex]);
    }
  }

  void _maybeSpeakStep(RouteStep step) {
    if (!_voiceGuidanceEnabled) return;
    final now = DateTime.now();
    if (_currentStepIndex == _lastSpokenStepIndex &&
        now.difference(_lastSpokenAt).inSeconds < 8) {
      return;
    }

    final text = step.voiceInstruction.isNotEmpty
        ? step.voiceInstruction
        : step.instruction.isNotEmpty
            ? step.instruction
            : step.instructionUr;
    if (text.isEmpty) return;

    final language = step.instructionUr.isNotEmpty &&
            step.voiceInstruction.isEmpty &&
            step.instruction.isEmpty
        ? 'ur'
        : 'en';

    _audioController.textToSpeechSingleLanguage(
      text,
      _currentStepIndex + 1000,
      language: language,
    );

    _lastSpokenStepIndex = _currentStepIndex;
    _lastSpokenAt = now;
  }

  int _resolveCurrentStepIndex(
    NavigationRouteResponse route,
    LatLng position,
  ) {
    const double completeThresholdM = 18;
    for (int i = 0; i < route.steps.length; i++) {
      final end = _stepEnd(route.steps[i]);
      if (end == null) continue;
      final distance = _distanceMeters(position, end);
      if (distance > completeThresholdM) {
        return i;
      }
    }
    return route.steps.length - 1;
  }

  LatLng? _stepEnd(RouteStep step) {
    if (step.stepGeometry.isEmpty) return null;
    return _latLngFromPair(step.stepGeometry.last);
  }

  double _distanceMeters(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }

  LatLng _latLngFromPair(List<double> pair) {
    if (pair.length < 2) {
      return const LatLng(0, 0);
    }
    final first = pair[0];
    final second = pair[1];
    // Most routing engines return [lon, lat].
    return LatLng(second, first);
  }

  List<LatLng> _buildStepPolyline(RouteStep step) {
    if (step.stepGeometry.isEmpty) return const [];
    return step.stepGeometry.map(_latLngFromPair).toList();
  }

  List<LatLng> _smoothPolyline(List<LatLng> points) {
    if (points.length < 2) return points;
    const int segments = 3;
    final smoothed = <LatLng>[];
    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      smoothed.add(start);
      for (int s = 1; s < segments; s++) {
        final t = s / segments;
        smoothed.add(LatLng(
          start.latitude + (end.latitude - start.latitude) * t,
          start.longitude + (end.longitude - start.longitude) * t,
        ));
      }
    }
    smoothed.add(points.last);
    return smoothed;
  }

  List<LatLng> _buildPolylinePoints(NavigationRouteResponse route) {
    if (route.polyline.isNotEmpty) {
      return route.polyline.map(_latLngFromPair).toList();
    }
    final points = <LatLng>[];
    for (final step in route.steps) {
      if (step.stepGeometry.isEmpty) continue;
      points.addAll(step.stepGeometry.map(_latLngFromPair));
    }
    return points;
  }

  _RemainingStats _remainingStats(NavigationRouteResponse route) {
    if (route.steps.isEmpty) {
      return const _RemainingStats(distanceM: 0, durationS: 0);
    }

    final position = _currentPosition;
    double remainingDistanceM = 0;
    double remainingDurationS = 0;

    for (int i = _currentStepIndex; i < route.steps.length; i++) {
      final step = route.steps[i];
      if (i == _currentStepIndex && position != null) {
        final end = _stepEnd(step);
        final stepDistance = step.distanceM > 0 ? step.distanceM : 0.0;
        final distToEnd =
            end == null ? stepDistance : _distanceMeters(position, end);
        final clampedDistance =
            stepDistance > 0 ? distToEnd.clamp(0, stepDistance) : distToEnd;
        remainingDistanceM += clampedDistance;
        if (stepDistance > 0 && step.durationS > 0) {
          remainingDurationS +=
              step.durationS * (clampedDistance / stepDistance);
        } else {
          remainingDurationS += step.durationS;
        }
      } else {
        remainingDistanceM += step.distanceM;
        remainingDurationS += step.durationS;
      }
    }

    return _RemainingStats(
      distanceM: remainingDistanceM,
      durationS: remainingDurationS,
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    return '${hours}h ${rem}m';
  }

  double _straightLineDistanceKm(LatLng current) {
    final meters = _distanceMeters(
      current,
      LatLng(widget.mosque.location.lat, widget.mosque.location.lon),
    );
    return meters / 1000;
  }

  IconData _maneuverIcon(RouteStep step) {
    switch (step.maneuverType) {
      case 'depart':
        return Icons.navigation;
      case 'arrive':
        return Icons.flag;
      case 'turn_left':
        return Icons.turn_left;
      case 'turn_right':
        return Icons.turn_right;
      case 'roundabout':
        return Icons.roundabout_right;
      default:
        return Icons.arrow_upward_rounded;
    }
  }

  Widget _stepBadge(
      RouteStep step, int index, bool isActive, bool isCompleted) {
    final baseColor = isCompleted
        ? const Color(0xFF1A4D2E)
        : isActive
            ? const Color(0xFF2E7D63)
            : const Color(0xFF4B7D6C);
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: baseColor,
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _maneuverIcon(step),
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E8E4)),
              ),
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A4D2E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Directions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: Obx(() {
        if (_controller.isLoadingRoute.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_localError != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_localError!, textAlign: TextAlign.center),
            ),
          );
        }

        final error = _controller.routeError.value;
        if (error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.route, size: 42, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(error, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadRoute,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final route = _controller.currentRoute.value;
        if (route == null || route.steps.isEmpty) {
          return const Center(child: Text('No route steps available'));
        }

        final polylinePoints = _smoothPolyline(_buildPolylinePoints(route));
        final hasPolyline = polylinePoints.isNotEmpty;
        final activeStepPoints = _smoothPolyline(
          _buildStepPolyline(route.steps[_currentStepIndex]),
        );
        final hasActiveStepLine = activeStepPoints.isNotEmpty;
        final current = _currentPosition ??
            LatLng(
              _controller.currentLat.value,
              _controller.currentLon.value,
            );
        final remaining = _remainingStats(route);
        final straightLineKm = _straightLineDistanceKm(current);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 260,
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: current,
                            initialZoom: 15.0,
                            onPositionChanged: (position, hasGesture) {
                              if (hasGesture && _followUser) {
                                setState(() {
                                  _followUser = false;
                                });
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.peaceplayer.app',
                            ),
                            if (hasPolyline)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: polylinePoints,
                                    color: const Color(0xFF1A4D2E),
                                    strokeWidth: 4,
                                  ),
                                ],
                              ),
                            if (hasActiveStepLine)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: activeStepPoints,
                                    color: const Color(0xFF4B7D6C),
                                    strokeWidth: 6,
                                  ),
                                ],
                              ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: current,
                                  width: 36,
                                  height: 36,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: PColors.primary.withOpacity(0.35),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.my_location,
                                        color: PColors.primary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Marker(
                                  point: LatLng(
                                    widget.mosque.location.lat,
                                    widget.mosque.location.lon,
                                  ),
                                  width: 36,
                                  height: 36,
                                  child: const Icon(
                                    Icons.mosque,
                                    color: Color(0xFF1A4D2E),
                                    size: 26,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: FloatingActionButton.small(
                            heroTag: 'follow_user',
                            backgroundColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                _followUser = true;
                              });
                              _mapController.move(current, 15.0);
                            },
                            child: const Icon(Icons.my_location,
                                color: Color(0xFF1A4D2E)),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: FloatingActionButton.small(
                            heroTag: 'voice_toggle',
                            backgroundColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                _voiceGuidanceEnabled = !_voiceGuidanceEnabled;
                              });
                            },
                            child: Icon(
                              _voiceGuidanceEnabled
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              color: const Color(0xFF1A4D2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E3B2C), Color(0xFF1A5B48)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mosque.displayName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statChip(
                        icon: Icons.route_rounded,
                        label:
                            '${route.summary.distanceKm.toStringAsFixed(2)} km',
                      ),
                      _statChip(
                        icon: Icons.straighten_rounded,
                        label:
                            '${straightLineKm.toStringAsFixed(2)} km straight',
                      ),
                      _statChip(
                        icon: Icons.timer_rounded,
                        label:
                            '${route.summary.durationMin.toStringAsFixed(0)} min',
                      ),
                      _statChip(
                        icon: Icons.directions_walk_rounded,
                        label: '${_formatDistance(remaining.distanceM)} left',
                      ),
                      _statChip(
                        icon: Icons.list_alt_rounded,
                        label:
                            'Step ${_currentStepIndex + 1}/${route.steps.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: route.steps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final step = route.steps[index];
                  final isActive = index == _currentStepIndex;
                  final isCompleted = index < _currentStepIndex;
                  final stepColor = isCompleted
                      ? const Color(0xFFE8F5F0)
                      : isActive
                          ? const Color(0xFFDFF1EA)
                          : Colors.white;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: stepColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFFBFE1D6)
                            : const Color(0xFFE5EBE9),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _stepBadge(step, index, isActive, isCompleted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Step ${index + 1}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4B7D6C),
                                    ),
                                  ),
                                  if (isActive) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A4D2E),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Now',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                step.instruction.isNotEmpty
                                    ? step.instruction
                                    : 'Continue straight',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: const Color(0xFF1A2E26),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step.formattedDistance,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6F857C),
                                  fontSize: 12,
                                ),
                              ),
                              if (isActive &&
                                  step.instructionUr.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  step.instructionUr,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF1A4D2E),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _RemainingStats {
  final double distanceM;
  final double durationS;

  const _RemainingStats({required this.distanceM, required this.durationS});
}

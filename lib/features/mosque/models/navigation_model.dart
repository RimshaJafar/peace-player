/// Navigation route model — maps to `/api/islamic-nav/navigation/route` response
class RouteSummary {
  final double distanceM;
  final double distanceKm;
  final double durationS;
  final double durationMin;
  final int stepCount;

  const RouteSummary({
    required this.distanceM,
    required this.distanceKm,
    required this.durationS,
    required this.durationMin,
    required this.stepCount,
  });

  factory RouteSummary.fromJson(Map<String, dynamic> json) {
    return RouteSummary(
      distanceM: (json['distance_m'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      durationS: (json['duration_s'] as num).toDouble(),
      durationMin: (json['duration_min'] as num).toDouble(),
      stepCount: json['step_count'] as int? ?? 0,
    );
  }
}

class RouteStep {
  final String instruction;
  final String instructionUr;
  final String voiceInstruction;
  final double distanceM;
  final double durationS;
  final String maneuverType;
  final String? modifier;
  final double bearingBefore;
  final double bearingAfter;
  final String? roadName;
  final List<List<double>> stepGeometry;

  const RouteStep({
    required this.instruction,
    required this.instructionUr,
    required this.voiceInstruction,
    required this.distanceM,
    required this.durationS,
    required this.maneuverType,
    this.modifier,
    required this.bearingBefore,
    required this.bearingAfter,
    this.roadName,
    this.stepGeometry = const [],
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] as String? ?? '',
      instructionUr: json['instruction_ur'] as String? ?? '',
      voiceInstruction: json['voice_instruction'] as String? ?? '',
      distanceM: (json['distance_m'] as num?)?.toDouble() ?? 0.0,
      durationS: (json['duration_s'] as num?)?.toDouble() ?? 0.0,
      maneuverType: json['maneuver_type'] as String? ?? 'unknown',
      modifier: json['modifier'],
      bearingBefore: (json['bearing_before'] as num?)?.toDouble() ?? 0.0,
      bearingAfter: (json['bearing_after'] as num?)?.toDouble() ?? 0.0,
      roadName: json['road_name'],
      stepGeometry: (json['step_geometry'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>)
                  .map((v) => (v as num).toDouble())
                  .toList())
              .toList() ??
          [],
    );
  }

  /// Formatted distance string
  String get formattedDistance {
    if (distanceM < 1000) {
      return '${distanceM.toStringAsFixed(0)} m';
    }
    return '${(distanceM / 1000).toStringAsFixed(1)} km';
  }

  /// Get maneuver icon name
  String get maneuverIcon {
    switch (maneuverType) {
      case 'depart':
        return 'navigation';
      case 'arrive':
        return 'flag';
      case 'turn_left':
        return 'turn_left';
      case 'turn_right':
        return 'turn_right';
      case 'roundabout':
        return 'roundabout_right';
      default:
        return 'straight';
    }
  }
}

class RouteWaypoint {
  final double lat;
  final double lon;
  final String name;
  final double distanceToOriginal;

  const RouteWaypoint({
    required this.lat,
    required this.lon,
    required this.name,
    required this.distanceToOriginal,
  });

  factory RouteWaypoint.fromJson(Map<String, dynamic> json) {
    return RouteWaypoint(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      name: json['name'] as String? ?? '',
      distanceToOriginal:
          (json['distance_to_original'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Full navigation route response
class NavigationRouteResponse {
  final bool success;
  final RouteSummary summary;
  final List<RouteStep> steps;
  final List<List<double>> polyline;
  final List<RouteWaypoint> waypoints;
  final bool cached;
  final String? message;

  const NavigationRouteResponse({
    required this.success,
    required this.summary,
    required this.steps,
    required this.polyline,
    this.waypoints = const [],
    this.cached = false,
    this.message,
  });

  factory NavigationRouteResponse.fromJson(Map<String, dynamic> json) {
    return NavigationRouteResponse(
      success: json['success'] as bool? ?? false,
      summary:
          RouteSummary.fromJson(json['summary'] as Map<String, dynamic>),
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => RouteStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      polyline: (json['polyline'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>)
                  .map((v) => (v as num).toDouble())
                  .toList())
              .toList() ??
          [],
      waypoints: (json['waypoints'] as List<dynamic>?)
              ?.map((e) => RouteWaypoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cached: json['cached'] as bool? ?? false,
      message: json['message'],
    );
  }
}

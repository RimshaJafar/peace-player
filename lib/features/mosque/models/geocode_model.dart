/// Geocode result model — maps to `/api/islamic-nav/geocode/search` response
class GeocodeAddressComponents {
  final String? building;
  final String? road;
  final String? municipality;
  final String? state;
  final String? postcode;
  final String? country;
  final String? countryCode;

  const GeocodeAddressComponents({
    this.building,
    this.road,
    this.municipality,
    this.state,
    this.postcode,
    this.country,
    this.countryCode,
  });

  factory GeocodeAddressComponents.fromJson(Map<String, dynamic> json) {
    return GeocodeAddressComponents(
      building: json['building'] ?? json['amenity'],
      road: json['road'],
      municipality: json['municipality'],
      state: json['state'],
      postcode: json['postcode'],
      country: json['country'],
      countryCode: json['country_code'],
    );
  }
}

class GeocodeBoundingBox {
  final double south;
  final double north;
  final double west;
  final double east;

  const GeocodeBoundingBox({
    required this.south,
    required this.north,
    required this.west,
    required this.east,
  });

  factory GeocodeBoundingBox.fromJson(Map<String, dynamic> json) {
    return GeocodeBoundingBox(
      south: (json['south'] as num).toDouble(),
      north: (json['north'] as num).toDouble(),
      west: (json['west'] as num).toDouble(),
      east: (json['east'] as num).toDouble(),
    );
  }
}

class GeocodeResult {
  final int placeId;
  final int osmId;
  final String osmType;
  final String displayName;
  final double lat;
  final double lon;
  final String type;
  final double importance;
  final GeocodeAddressComponents? addressComponents;
  final GeocodeBoundingBox? boundingBox;

  const GeocodeResult({
    required this.placeId,
    required this.osmId,
    required this.osmType,
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.type,
    required this.importance,
    this.addressComponents,
    this.boundingBox,
  });

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    return GeocodeResult(
      placeId: json['place_id'] as int? ?? 0,
      osmId: json['osm_id'] as int? ?? 0,
      osmType: json['osm_type'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      type: json['type'] as String? ?? '',
      importance: (json['importance'] as num?)?.toDouble() ?? 0.0,
      addressComponents: json['address_components'] != null
          ? GeocodeAddressComponents.fromJson(
              json['address_components'] as Map<String, dynamic>)
          : null,
      boundingBox: json['bounding_box'] != null
          ? GeocodeBoundingBox.fromJson(
              json['bounding_box'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Response wrapper for geocode search API
class GeocodeSearchResponse {
  final bool success;
  final int count;
  final List<GeocodeResult> results;
  final bool cached;
  final String? message;

  const GeocodeSearchResponse({
    required this.success,
    required this.count,
    required this.results,
    this.cached = false,
    this.message,
  });

  factory GeocodeSearchResponse.fromJson(Map<String, dynamic> json) {
    return GeocodeSearchResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => GeocodeResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cached: json['cached'] as bool? ?? false,
      message: json['message'],
    );
  }
}

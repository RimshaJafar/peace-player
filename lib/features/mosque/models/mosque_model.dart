/// Mosque data model — maps to `/api/islamic-nav/mosques/nearby` response
class MosqueLocation {
  final double lat;
  final double lon;

  const MosqueLocation({required this.lat, required this.lon});

  factory MosqueLocation.fromJson(Map<String, dynamic> json) {
    return MosqueLocation(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lon': lon};
}

class MosqueAmenities {
  final bool hasParking;
  final bool? hasWudu;
  final bool hasWheelchairAccess;
  final bool? hasFemaleSection;
  final String? denomination;
  final int? capacity;
  final String? openingHours;
  final String? website;
  final String? phone;

  const MosqueAmenities({
    this.hasParking = false,
    this.hasWudu,
    this.hasWheelchairAccess = false,
    this.hasFemaleSection,
    this.denomination,
    this.capacity,
    this.openingHours,
    this.website,
    this.phone,
  });

  factory MosqueAmenities.fromJson(Map<String, dynamic> json) {
    return MosqueAmenities(
      hasParking: json['has_parking'] ?? false,
      hasWudu: json['has_wudu'],
      hasWheelchairAccess: json['has_wheelchair_access'] ?? false,
      hasFemaleSection: json['has_female_section'],
      denomination: json['denomination'],
      capacity: json['capacity'],
      openingHours: json['opening_hours'],
      website: json['website'],
      phone: json['phone'],
    );
  }
}

class Mosque {
  final int osmId;
  final String osmType;
  final String name;
  final String? nameEn;
  final String? nameAr;
  final String? nameUr;
  final String mosqueType;
  final MosqueLocation location;
  final double distanceM;
  final double distanceKm;
  final double rankScore;
  final String? address;
  final MosqueAmenities amenities;
  final Map<String, dynamic> rawTags;

  const Mosque({
    required this.osmId,
    required this.osmType,
    required this.name,
    this.nameEn,
    this.nameAr,
    this.nameUr,
    required this.mosqueType,
    required this.location,
    required this.distanceM,
    required this.distanceKm,
    required this.rankScore,
    this.address,
    required this.amenities,
    this.rawTags = const {},
  });

  factory Mosque.fromJson(Map<String, dynamic> json) {
    return Mosque(
      osmId: json['osm_id'] as int,
      osmType: json['osm_type'] as String,
      name: json['name'] as String? ?? 'Unknown Mosque',
      nameEn: json['name_en'],
      nameAr: json['name_ar'],
      nameUr: json['name_ur'],
      mosqueType: json['mosque_type'] as String? ?? 'mosque',
      location: MosqueLocation.fromJson(json['location'] as Map<String, dynamic>),
      distanceM: (json['distance_m'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      rankScore: (json['rank_score'] as num?)?.toDouble() ?? 0.0,
      address: json['address'],
      amenities: json['amenities'] != null
          ? MosqueAmenities.fromJson(json['amenities'] as Map<String, dynamic>)
          : const MosqueAmenities(),
      rawTags: json['raw_tags'] != null
          ? Map<String, dynamic>.from(json['raw_tags'])
          : {},
    );
  }

  /// Display name: prefer localized name, fallback to default
  String get displayName => nameEn ?? name;
}

/// Response wrapper for nearby mosques API
class NearbyMosquesResponse {
  final bool success;
  final int count;
  final int radiusM;
  final MosqueLocation center;
  final List<Mosque> mosques;
  final bool cached;
  final String? message;

  const NearbyMosquesResponse({
    required this.success,
    required this.count,
    required this.radiusM,
    required this.center,
    required this.mosques,
    this.cached = false,
    this.message,
  });

  factory NearbyMosquesResponse.fromJson(Map<String, dynamic> json) {
    return NearbyMosquesResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      radiusM: json['radius_m'] as int? ?? 0,
      center: MosqueLocation.fromJson(json['center'] as Map<String, dynamic>),
      mosques: (json['mosques'] as List<dynamic>?)
              ?.map((e) => Mosque.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cached: json['cached'] as bool? ?? false,
      message: json['message'],
    );
  }
}

/// Response wrapper for mosque search API
class MosqueSearchResponse {
  final bool success;
  final int count;
  final List<Mosque> mosques;
  final bool cached;
  final String? message;

  const MosqueSearchResponse({
    required this.success,
    required this.count,
    required this.mosques,
    this.cached = false,
    this.message,
  });

  factory MosqueSearchResponse.fromJson(Map<String, dynamic> json) {
    return MosqueSearchResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      mosques: (json['mosques'] as List<dynamic>?)
              ?.map((e) => Mosque.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cached: json['cached'] as bool? ?? false,
      message: json['message'],
    );
  }
}

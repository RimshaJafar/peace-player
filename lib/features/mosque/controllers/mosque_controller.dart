import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:ecommerce_app/features/mosque/models/geocode_model.dart';
import 'package:ecommerce_app/features/mosque/models/mosque_model.dart';
import 'package:ecommerce_app/features/mosque/models/navigation_model.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class MosqueController extends GetxController {
  final String? _baseUrl = dotenv.env['APIS_BASE_URL'];

  final currentLat = 0.0.obs;
  final currentLon = 0.0.obs;
  final hasLocation = false.obs;

  final nearbyMosques = <Mosque>[].obs;
  final isLoadingNearby = false.obs;
  final nearbyError = Rxn<String>();

  final searchResults = <Mosque>[].obs;
  final geocodeResults = <GeocodeResult>[].obs;
  final isSearching = false.obs;
  final searchError = Rxn<String>();

  final currentRoute = Rxn<NavigationRouteResponse>();
  final isLoadingRoute = false.obs;
  final routeError = Rxn<String>();

  final radiusKm = 10.obs;
  final selectedMosque = Rxn<Mosque>();

  String get _apiBase {
    final value = _baseUrl?.trim() ?? '';
    final uri = Uri.tryParse(value);
    if (value.isEmpty || uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const AppConfigurationException(
        'Mosque services are temporarily unavailable.',
      );
    }
    final normalized =
        value.endsWith('/') ? value.substring(0, value.length - 1) : value;
    return '$normalized/api/islamic-nav';
  }

  Future<bool> getCurrentLocation() async {
    nearbyError.value = null;
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
        nearbyError.value =
            'Location permission is disabled. Enable it in app settings.';
        PLoaders.warningSnackBar(
          title: 'Location Permission',
          message:
              'Location permission is disabled. Enable it in app settings.',
          actionLabel: 'Settings',
          onAction: Geolocator.openAppSettings,
        );
        return false;
      }
      if (permission == LocationPermission.denied) {
        throw const AppUserFacingException(
          'Location permission is required to find nearby mosques.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));
      currentLat.value = position.latitude;
      currentLon.value = position.longitude;
      hasLocation.value = true;
      return true;
    } catch (error, stackTrace) {
      nearbyError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to get your location. Please try again.',
      );
      _logDebug('Location lookup failed.', error, stackTrace);
      return false;
    }
  }

  Future<void> fetchNearbyMosques({
    double? lat,
    double? lon,
    int? radiusM,
    int limit = 20,
    String sortBy = 'distance',
  }) async {
    isLoadingNearby.value = true;
    nearbyError.value = null;
    try {
      final useLat = lat ?? currentLat.value;
      final useLon = lon ?? currentLon.value;
      final useRadius = radiusM ?? (radiusKm.value * 1000);
      final response = await http
          .get(
            Uri.parse(
              '$_apiBase/mosques/nearby'
              '?lat=$useLat&lon=$useLon'
              '&radius_m=$useRadius&limit=$limit&sort_by=$sortBy',
            ),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to find nearby mosques. Please try again.',
          ),
        );
      }

      final data = _decodeMap(response.body);
      final parsed = NearbyMosquesResponse.fromJson(data);
      if (parsed.success) {
        nearbyMosques.assignAll(parsed.mosques);
      } else {
        nearbyMosques.clear();
        nearbyError.value =
            AppErrorMessage.sanitize(parsed.message) ?? 'No mosques found.';
      }
    } catch (error, stackTrace) {
      nearbyError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to find nearby mosques. Please try again.',
      );
      _logDebug('Nearby mosque loading failed.', error, stackTrace);
    } finally {
      isLoadingNearby.value = false;
    }
  }

  Future<void> searchMosques(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      searchError.value = null;
      return;
    }

    isSearching.value = true;
    searchError.value = null;
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_apiBase/mosques/search'
              '?query=${Uri.encodeComponent(query)}'
              '&lat=${currentLat.value}&lon=${currentLon.value}'
              '&limit=$limit',
            ),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to search mosques. Please try again.',
          ),
        );
      }

      final parsed = MosqueSearchResponse.fromJson(
        _decodeMap(response.body),
      );
      if (parsed.success) {
        searchResults.assignAll(parsed.mosques);
      } else {
        searchResults.clear();
      }
    } catch (error, stackTrace) {
      searchError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to search mosques. Please try again.',
      );
      _logDebug('Mosque search failed.', error, stackTrace);
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> geocodeSearch(String query, {int limit = 5}) async {
    if (query.trim().isEmpty) {
      geocodeResults.clear();
      searchError.value = null;
      return;
    }

    isSearching.value = true;
    searchError.value = null;
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_apiBase/geocode/search'
              '?query=${Uri.encodeComponent(query)}'
              '&limit=$limit&language=en',
            ),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to find that location. Please try again.',
          ),
        );
      }

      final parsed = GeocodeSearchResponse.fromJson(
        _decodeMap(response.body),
      );
      if (!parsed.success) return;
      geocodeResults.assignAll(parsed.results);
      if (parsed.results.isNotEmpty) {
        final firstResult = parsed.results.first;
        await fetchNearbyMosques(
          lat: firstResult.lat,
          lon: firstResult.lon,
          radiusM: radiusKm.value * 1000,
        );
      }
    } catch (error, stackTrace) {
      searchError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to find that location. Please try again.',
      );
      _logDebug('Geocoding failed.', error, stackTrace);
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> fetchWalkingRoute({
    required double destLat,
    required double destLon,
    String language = 'en',
  }) async {
    if (!hasLocation.value) {
      routeError.value =
          'Your current location is required to calculate a route.';
      return;
    }

    isLoadingRoute.value = true;
    routeError.value = null;
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_apiBase/navigation/route'
              '?origin_lat=${currentLat.value}&origin_lon=${currentLon.value}'
              '&dest_lat=$destLat&dest_lon=$destLon'
              '&profile=foot&language=$language&steps=true',
            ),
          )
          .timeout(const Duration(seconds: 25));
      if (response.statusCode != 200) {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            response,
            fallback: 'Unable to calculate the route. Please try again.',
          ),
        );
      }

      final parsed = NavigationRouteResponse.fromJson(
        _decodeMap(response.body),
      );
      if (parsed.success) {
        currentRoute.value = parsed;
      } else {
        routeError.value = AppErrorMessage.sanitize(parsed.message) ??
            'No walking route was found.';
      }
    } catch (error, stackTrace) {
      routeError.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to calculate the route. Please try again.',
      );
      _logDebug('Route loading failed.', error, stackTrace);
    } finally {
      isLoadingRoute.value = false;
    }
  }

  void clearRoute() {
    currentRoute.value = null;
    routeError.value = null;
  }

  void updateRadius(int newRadiusKm) {
    radiusKm.value = newRadiusKm;
    if (hasLocation.value) {
      fetchNearbyMosques();
    }
  }

  void selectMosque(Mosque mosque, {bool fetchRoute = false}) {
    selectedMosque.value = mosque;
    if (fetchRoute && hasLocation.value) {
      fetchWalkingRoute(
        destLat: mosque.location.lat,
        destLon: mosque.location.lon,
      );
    }
  }

  Future<void> initialize() async {
    final gotLocation = await getCurrentLocation();
    if (gotLocation) await fetchNearbyMosques();
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = safeDecodeJson(body);
    if (decoded is! Map) {
      throw const FormatException('Invalid mosque service response.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  void _logDebug(
    String message,
    Object error,
    StackTrace stackTrace,
  ) {
    if (!kDebugMode) return;
    debugPrint('[Mosque] $message $error');
    debugPrint(stackTrace.toString());
  }
}

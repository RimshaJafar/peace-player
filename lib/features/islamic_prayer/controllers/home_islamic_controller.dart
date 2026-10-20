import 'dart:convert';
import 'package:ecommerce_app/features/islamic_prayer/models/home_summary_model.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:ecommerce_app/utils/local_storage/storage_utility.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

class HomeIslamicController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];
  final PLocalStorage _storage = PLocalStorage();

  final isLoading = false.obs;
  final hasError = false.obs;
  final summary = Rxn<HomeSummaryResponse>();

  static const double _defaultLat = 21.4225;
  static const double _defaultLng = 39.8262;

  @override
  void onInit() {
    super.onInit();
    fetchHomeSummary();
  }

  Future<void> fetchHomeSummary() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      Position position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          position = Position(
            latitude: _defaultLat,
            longitude: _defaultLng,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        } else {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            position = Position(
              latitude: _defaultLat,
              longitude: _defaultLng,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
          } else {
            position = await Geolocator.getCurrentPosition();
          }
        }
      } catch (_) {
        position = Position(
          latitude: _defaultLat,
          longitude: _defaultLng,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }

      final uri = Uri.parse(
        '$apisBaseUrl/api/home-summary'
        '?latitude=${position.latitude}'
        '&longitude=${position.longitude}'
        '&method=MUSLIM_WORLD_LEAGUE'
        '&madhab=${_storedDefaultMadhab()}',
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        summary.value = HomeSummaryResponse.fromJson(data);
      } else {
        hasError.value = true;
      }
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  String _storedDefaultMadhab() {
    final storedMadhab =
        _storage.readData<String>(PrayerTimesSettingsKeys.asrMadhab);
    final normalizedMadhab = storedMadhab?.trim().toLowerCase();
    if (normalizedMadhab == 'hanafi') return 'hanafi';
    if (normalizedMadhab == 'shafi' ||
        normalizedMadhab == 'shafii' ||
        normalizedMadhab == 'standard') {
      return 'standard';
    }

    return PrayerTimesDefaults.asrMadhab;
  }
}

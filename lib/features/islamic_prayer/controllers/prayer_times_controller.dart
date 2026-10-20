import 'dart:async';
import 'package:ecommerce_app/features/islamic_prayer/models/prayer_times_model.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:ecommerce_app/utils/local_storage/storage_utility.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];
  final PLocalStorage _storage = PLocalStorage();

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final prayerTimes = Rxn<PrayerTimesResponse>();
  final countdown = ''.obs;
  final countdownSeconds = 0.obs;
  final selectedMadhab = PrayerTimesDefaults.asrMadhab.obs;

  static const double _defaultLat = 21.4225;
  static const double _defaultLng = 39.8262;

  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    applyDefaultMadhab();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  void setMadhab(String madhab) {
    final normalizedMadhab = _normalizeMadhab(madhab);
    if (selectedMadhab.value == normalizedMadhab &&
        prayerTimes.value != null &&
        !isLoading.value) {
      return;
    }
    selectedMadhab.value = normalizedMadhab;
    fetchPrayerTimes();
  }

  void applyDefaultMadhab() {
    final defaultMadhab = _storedDefaultMadhab();
    final shouldFetch =
        selectedMadhab.value != defaultMadhab || prayerTimes.value == null;

    selectedMadhab.value = defaultMadhab;
    if (shouldFetch && !isLoading.value) {
      fetchPrayerTimes();
    }
  }

  String _storedDefaultMadhab() {
    return _normalizeMadhab(
      _storage.readData<String>(PrayerTimesSettingsKeys.asrMadhab),
    );
  }

  String _normalizeMadhab(String? madhab) {
    final normalizedMadhab = madhab?.trim().toLowerCase();
    if (normalizedMadhab == 'hanafi') return 'hanafi';
    if (normalizedMadhab == 'shafi' ||
        normalizedMadhab == 'shafii' ||
        normalizedMadhab == 'standard') {
      return 'standard';
    }

    return PrayerTimesDefaults.asrMadhab;
  }

  Future<void> fetchPrayerTimes() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

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

      final baseUrl = _requireBaseUrl();
      final uri = Uri.parse(
        '$baseUrl/api/prayer-times'
        '?latitude=${position.latitude}'
        '&longitude=${position.longitude}'
        '&method=MUSLIM_WORLD_LEAGUE'
        '&madhab=${selectedMadhab.value}',
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = safeDecodeJson(res.body);
        if (decoded is! Map) {
          throw const FormatException('Invalid prayer times response.');
        }
        final data = Map<String, dynamic>.from(decoded);
        prayerTimes.value = PrayerTimesResponse.fromJson(data);
        _startCountdown();
      } else {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            res,
            fallback: 'Unable to load prayer times. Please try again.',
          ),
        );
      }
    } catch (error) {
      hasError.value = true;
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load prayer times. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _requireBaseUrl() {
    final value = apisBaseUrl?.trim() ?? '';
    final uri = Uri.tryParse(value);
    if (value.isEmpty || uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const AppConfigurationException(
        'Prayer times are temporarily unavailable.',
      );
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    final pt = prayerTimes.value;
    if (pt == null) return;

    final nextPrayerTime = displayNextPrayerTime(pt);
    if (nextPrayerTime.isEmpty) return;

    _updateCountdown(nextPrayerTime);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown(nextPrayerTime);
    });
  }

  String displayCurrentPrayer(PrayerTimesResponse pt) {
    return _isSunrise(pt.currentPrayer) ? '' : pt.currentPrayer;
  }

  String displayNextPrayer(PrayerTimesResponse pt) {
    return _isSunrise(pt.nextPrayer) ? 'Dhuhr' : pt.nextPrayer;
  }

  String displayNextPrayerTime(PrayerTimesResponse pt) {
    return _isSunrise(pt.nextPrayer) ? pt.dhuhr : pt.nextPrayerTime;
  }

  bool _isSunrise(String prayer) {
    return prayer.trim().toLowerCase() == 'sunrise';
  }

  void _updateCountdown(String nextTimeStr) {
    try {
      final now = DateTime.now();
      final parsed = _parseTime(nextTimeStr, now);
      if (parsed == null) return;

      DateTime nextDate = DateTime(
        now.year,
        now.month,
        now.day,
        parsed.hour,
        parsed.minute,
      );

      if (nextDate.isBefore(now)) {
        nextDate = nextDate.add(const Duration(days: 1));
      }

      final diff = nextDate.difference(now);
      if (diff.isNegative) {
        countdown.value = '00:00:00';
        countdownSeconds.value = 0;
        return;
      }

      countdownSeconds.value = diff.inSeconds;
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
      countdown.value = '$hours:$minutes:$seconds';
    } catch (_) {
      countdown.value = '';
    }
  }

  _TimeOfDay? _parseTime(String timeStr, DateTime now) {
    try {
      final cleaned = timeStr.trim().toUpperCase();
      final isPM = cleaned.contains('PM');
      final isAM = cleaned.contains('AM');
      final parts = cleaned.replaceAll(RegExp(r'[AP]M'), '').trim().split(':');
      if (parts.length < 2) return null;

      int hour = int.tryParse(parts[0].trim()) ?? 0;
      final minute = int.tryParse(parts[1].trim()) ?? 0;

      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return _TimeOfDay(hour, minute);
    } catch (_) {
      return null;
    }
  }
}

class _TimeOfDay {
  final int hour;
  final int minute;
  const _TimeOfDay(this.hour, this.minute);
}

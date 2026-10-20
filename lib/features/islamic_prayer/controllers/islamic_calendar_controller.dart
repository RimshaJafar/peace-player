import 'dart:math' as math;

import 'package:ecommerce_app/features/islamic_prayer/models/islamic_calendar_model.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IslamicCalendarController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final calendar = Rxn<IslamicCalendarResponse>();
  final currentYear = 0.obs;
  final currentMonth = 0.obs;
  final todayHijriDay = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setCurrentHijriMonthFromToday();
    fetchCalendar(snapToToday: true);
  }

  Future<void> fetchCalendar({bool snapToToday = false}) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final baseUrl = _requireBaseUrl();
      final uri = Uri.parse(
        '$baseUrl/api/islamic-calendar'
        '?year=${currentYear.value}'
        '&month=${currentMonth.value}',
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = safeDecodeJson(res.body);
        if (decoded is! Map) {
          throw const FormatException('Invalid calendar response.');
        }
        final data = Map<String, dynamic>.from(decoded);
        final cal = IslamicCalendarResponse.fromJson(data);
        if (snapToToday) {
          final correctedMonth = _monthCorrectionForToday(cal);
          if (correctedMonth != null &&
              (correctedMonth.year != cal.hijriYear ||
                  correctedMonth.month != cal.hijriMonth)) {
            currentYear.value = correctedMonth.year;
            currentMonth.value = correctedMonth.month;
            await fetchCalendar();
            return;
          }
        }

        calendar.value = cal;
        currentYear.value = cal.hijriYear;
        currentMonth.value = cal.hijriMonth;
        todayHijriDay.value = _todayHijriDayFromCalendar(cal);
      } else {
        throw AppUserFacingException(
          ApiErrorParser.parseResponse(
            res,
            fallback: 'Unable to load the calendar. Please try again.',
          ),
        );
      }
    } catch (error) {
      hasError.value = true;
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load the calendar. Please try again.',
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
        'The Islamic calendar is temporarily unavailable.',
      );
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  void goToPreviousMonth() {
    if (currentMonth.value == 1) {
      currentYear.value--;
      currentMonth.value = 12;
    } else {
      currentMonth.value--;
    }
    fetchCalendar();
  }

  void goToNextMonth() {
    if (currentMonth.value == 12) {
      currentYear.value++;
      currentMonth.value = 1;
    } else {
      currentMonth.value++;
    }
    fetchCalendar();
  }

  void _setCurrentHijriMonthFromToday() {
    final todayHijri = _gregorianToHijri(DateTime.now());
    currentYear.value = todayHijri.year;
    currentMonth.value = todayHijri.month;
    todayHijriDay.value = todayHijri.day;
  }

  _HijriMonth? _monthCorrectionForToday(IslamicCalendarResponse cal) {
    final today = _dateOnly(DateTime.now());
    final start = DateTime.tryParse(cal.gregorianStart);
    final end = DateTime.tryParse(cal.gregorianEnd);
    if (start == null || end == null) return null;

    if (today.isBefore(_dateOnly(start))) {
      return _previousMonth(cal.hijriYear, cal.hijriMonth);
    }
    if (today.isAfter(_dateOnly(end))) {
      return _nextMonth(cal.hijriYear, cal.hijriMonth);
    }
    return null;
  }

  int _todayHijriDayFromCalendar(IslamicCalendarResponse cal) {
    final today = _dateOnly(DateTime.now());
    for (final day in cal.days) {
      final gregorianDate = DateTime.tryParse(day.gregorianDate);
      if (gregorianDate == null) continue;
      if (_isSameDate(gregorianDate, today)) return day.day;
    }
    return todayHijriDay.value;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  _HijriMonth _previousMonth(int year, int month) {
    if (month <= 1) return _HijriMonth(year - 1, 12, 0);
    return _HijriMonth(year, month - 1, 0);
  }

  _HijriMonth _nextMonth(int year, int month) {
    if (month >= 12) return _HijriMonth(year + 1, 1, 0);
    return _HijriMonth(year, month + 1, 0);
  }

  _HijriMonth _gregorianToHijri(DateTime date) {
    final day = date.day;
    var month = date.month;
    var year = date.year;

    if (month < 3) {
      year -= 1;
      month += 12;
    }

    final century = (year / 100).floor();
    var correction = 2 - century + (century / 4).floor();
    if (year < 1583) correction = 0;

    final julianDay = (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        correction -
        1524;

    const islamicYearLength = 10631 / 30;
    const civilEpoch = 1948085;
    const shift = 8.01 / 60;

    var daysSinceEpoch = julianDay - civilEpoch;
    final cycle = (daysSinceEpoch / 10631).floor();
    daysSinceEpoch -= 10631 * cycle;

    final yearInCycle = ((daysSinceEpoch - shift) / islamicYearLength).floor();
    final hijriYear = 30 * cycle + yearInCycle;
    daysSinceEpoch -= (yearInCycle * islamicYearLength + shift).floor();

    var hijriMonth = ((daysSinceEpoch + 28.5001) / 29.5).floor();
    hijriMonth = math.min(hijriMonth, 12);
    final hijriDay = daysSinceEpoch - (29.5001 * hijriMonth - 29).floor();

    return _HijriMonth(hijriYear, hijriMonth, hijriDay);
  }
}

class _HijriMonth {
  const _HijriMonth(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;
}

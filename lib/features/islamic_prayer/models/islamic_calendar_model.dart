class CalendarDay {
  final int day;
  final String gregorianDate;
  final String weekday;
  final List<String> islamicEvents;

  CalendarDay({
    required this.day,
    required this.gregorianDate,
    required this.weekday,
    this.islamicEvents = const [],
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    final events = json['islamic_event'];
    return CalendarDay(
      day: json['day'] is int ? json['day'] : int.tryParse(json['day']?.toString() ?? '0') ?? 0,
      gregorianDate: json['gregorian_date']?.toString() ?? '',
      weekday: json['weekday']?.toString() ?? '',
      islamicEvents: events != null
          ? (events is List
              ? events.map((e) => e.toString()).toList()
              : [events.toString()])
          : [],
    );
  }
}

class IslamicCalendarResponse {
  final int hijriYear;
  final int hijriMonth;
  final String hijriMonthName;
  final String gregorianStart;
  final String gregorianEnd;
  final List<CalendarDay> days;

  IslamicCalendarResponse({
    required this.hijriYear,
    required this.hijriMonth,
    required this.hijriMonthName,
    required this.gregorianStart,
    required this.gregorianEnd,
    this.days = const [],
  });

  factory IslamicCalendarResponse.fromJson(Map<String, dynamic> json) {
    return IslamicCalendarResponse(
      hijriYear: json['hijri_year'] is int
          ? json['hijri_year']
          : int.tryParse(json['hijri_year']?.toString() ?? '0') ?? 0,
      hijriMonth: json['hijri_month'] is int
          ? json['hijri_month']
          : int.tryParse(json['hijri_month']?.toString() ?? '0') ?? 0,
      hijriMonthName: json['hijri_month_name']?.toString() ?? '',
      gregorianStart: json['gregorian_start']?.toString() ?? '',
      gregorianEnd: json['gregorian_end']?.toString() ?? '',
      days: (json['days'] as List?)
              ?.map((e) =>
                  CalendarDay.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}

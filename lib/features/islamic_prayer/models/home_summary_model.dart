class UpcomingPrayer {
  final String name;
  final String time;

  UpcomingPrayer({required this.name, required this.time});

  factory UpcomingPrayer.fromJson(Map<String, dynamic> json) {
    return UpcomingPrayer(
      name: json['name']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}

class HomeSummaryResponse {
  final UpcomingPrayer? upcomingPrayer;
  final String hijriDate;

  HomeSummaryResponse({this.upcomingPrayer, required this.hijriDate});

  factory HomeSummaryResponse.fromJson(Map<String, dynamic> json) {
    return HomeSummaryResponse(
      upcomingPrayer: json['upcoming_prayer'] != null
          ? UpcomingPrayer.fromJson(
              Map<String, dynamic>.from(json['upcoming_prayer']))
          : null,
      hijriDate: json['hijri_date']?.toString() ?? '',
    );
  }
}

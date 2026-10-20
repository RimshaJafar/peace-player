class PrayerTimesResponse {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String currentPrayer;
  final String nextPrayer;
  final String nextPrayerTime;

  PrayerTimesResponse({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.nextPrayerTime,
  });

  factory PrayerTimesResponse.fromJson(Map<String, dynamic> json) {
    return PrayerTimesResponse(
      fajr: json['fajr']?.toString() ?? '',
      sunrise: json['sunrise']?.toString() ?? '',
      dhuhr: json['dhuhr']?.toString() ?? '',
      asr: json['asr']?.toString() ?? '',
      maghrib: json['maghrib']?.toString() ?? '',
      isha: json['isha']?.toString() ?? '',
      currentPrayer: json['current_prayer']?.toString() ?? '',
      nextPrayer: json['next_prayer']?.toString() ?? '',
      nextPrayerTime: json['next_prayer_time']?.toString() ?? '',
    );
  }

  List<PrayerEntry> get prayerList => [
        PrayerEntry('Fajr', fajr),
        PrayerEntry('Dhuhr', dhuhr),
        PrayerEntry('Asr', asr),
        PrayerEntry('Maghrib', maghrib),
        PrayerEntry('Isha', isha),
      ];
}

class PrayerEntry {
  final String name;
  final String time;
  const PrayerEntry(this.name, this.time);
}

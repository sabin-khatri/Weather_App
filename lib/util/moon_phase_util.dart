class MoonPhaseInfo {
  final double illumination;
  final String phaseName;
  final String emoji;

  MoonPhaseInfo({
    required this.illumination,
    required this.phaseName,
    required this.emoji,
  });
}

class MoonPhaseUtil {
  static MoonPhaseInfo getPhase([DateTime? date]) {
    final d = date ?? DateTime.now();
    final age = _moonAge(d);
    final illumination = (1 - (age - 14.765).abs() / 14.765).clamp(0.0, 1.0);

    String name;
    String emoji;
    if (age < 1.85) {
      name = 'newMoon';
      emoji = '🌑';
    } else if (age < 7.38) {
      name = 'waxingCrescent';
      emoji = '🌒';
    } else if (age < 9.23) {
      name = 'firstQuarter';
      emoji = '🌓';
    } else if (age < 14.77) {
      name = 'waxingGibbous';
      emoji = '🌔';
    } else if (age < 16.61) {
      name = 'fullMoon';
      emoji = '🌕';
    } else if (age < 22.15) {
      name = 'waningGibbous';
      emoji = '🌖';
    } else if (age < 23.99) {
      name = 'lastQuarter';
      emoji = '🌗';
    } else {
      name = 'waningCrescent';
      emoji = '🌘';
    }

    return MoonPhaseInfo(
      illumination: illumination,
      phaseName: name,
      emoji: emoji,
    );
  }

  static double _moonAge(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    var y = year.toDouble();
    var m = month.toDouble();
    if (m < 3) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
    final daysSinceNew = jd - 2451549.5;
    return daysSinceNew % 29.53;
  }

  static DateTime goldenHourMorning(DateTime sunrise) =>
      sunrise.subtract(const Duration(minutes: 45));

  static DateTime goldenHourEvening(DateTime sunset) =>
      sunset.subtract(const Duration(minutes: 45));

  static DateTime blueHourMorning(DateTime sunrise) =>
      sunrise.subtract(const Duration(minutes: 25));

  static DateTime blueHourEvening(DateTime sunset) =>
      sunset.add(const Duration(minutes: 15));
}

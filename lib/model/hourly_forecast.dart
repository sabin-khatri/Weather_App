class HourlyForecast {
  final DateTime time;
  final double temp;
  final String description;
  final String icon;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.description,
    required this.icon,
  });
}

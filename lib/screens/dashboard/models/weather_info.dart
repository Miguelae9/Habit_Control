class WeatherInfo {
  const WeatherInfo({
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
  });

  final String city;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;

    return WeatherInfo(
      city: 'Málaga, ES',
      temperature: (current['temperature_2m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
    );
  }

  String get condition {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode >= 1 && weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode == 45 || weatherCode == 48) return 'Fog';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Rain';
    if (weatherCode >= 71 && weatherCode <= 77) return 'Snow';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Showers';
    if (weatherCode >= 95) return 'Storm';
    return 'Weather available';
  }

  String get habitContext {
    if (weatherCode >= 51 && weatherCode <= 82) {
      return 'Rain may affect outdoor habits today.';
    }

    if (temperature >= 30) {
      return 'High temperature may affect energy and consistency.';
    }

    if (windSpeed >= 35) {
      return 'Strong wind may make outdoor routines harder.';
    }

    return 'Good conditions to keep your routine.';
  }
}

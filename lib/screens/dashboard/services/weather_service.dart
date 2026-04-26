import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:habit_control/screens/dashboard/models/weather_info.dart';

class WeatherService {
  static const double _malagaLat = 36.72;
  static const double _malagaLon = -4.42;

  Future<WeatherInfo> fetchCurrentWeather() async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': _malagaLat.toString(),
      'longitude': _malagaLon.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code',
      'timezone': 'auto',
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Weather request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherInfo.fromJson(data);
  }
}

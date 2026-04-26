import 'package:flutter/foundation.dart';
import 'package:habit_control/screens/dashboard/models/weather_info.dart';
import 'package:habit_control/screens/dashboard/services/weather_service.dart';

class WeatherStore extends ChangeNotifier {
  WeatherStore({WeatherService? service})
    : _service = service ?? WeatherService();

  final WeatherService _service;

  WeatherInfo? _weather;
  bool _loading = false;
  String? _error;

  WeatherInfo? get weather => _weather;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadWeather() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _service.fetchCurrentWeather();
    } catch (e) {
      _error = 'Weather unavailable';
    }

    _loading = false;
    notifyListeners();
  }
}

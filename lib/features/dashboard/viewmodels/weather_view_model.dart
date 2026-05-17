import 'package:flutter/foundation.dart';
import 'package:habit_control/features/dashboard/models/weather_info.dart';
import 'package:habit_control/features/dashboard/data/weather_service.dart';

/// Fetches the current weather snapshot and exposes loading/error state.
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel({WeatherService? service})
    : _service = service ?? WeatherService();

  final WeatherService _service;

  WeatherInfo? _weather;
  bool _loading = false;
  String? _error;

  WeatherInfo? get weather => _weather;
  bool get loading => _loading;
  String? get error => _error;

  /// Reloads the weather. Sets [error] to a user-facing message on failure.
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

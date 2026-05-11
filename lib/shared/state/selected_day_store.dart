import 'package:flutter/foundation.dart';

import 'package:habit_control/shared/utils/day_key.dart';

class SelectedDayStore extends ChangeNotifier {
  DateTime _selectedDay = _dateOnly(DateTime.now());

  DateTime get selectedDay => _selectedDay;

  String get selectedDayKey => dayKeyFromDate(_selectedDay);

  bool get isToday {
    return selectedDayKey == dayKeyFromDate(DateTime.now());
  }

  bool get canGoNextDay {
    final today = _dateOnly(DateTime.now());
    return _selectedDay.isBefore(today);
  }

  void goPreviousDay() {
    _selectedDay = _selectedDay.subtract(const Duration(days: 1));
    notifyListeners();
  }

  void goNextDay() {
    if (!canGoNextDay) return;

    _selectedDay = _selectedDay.add(const Duration(days: 1));
    notifyListeners();
  }

  void resetToToday() {
    _selectedDay = _dateOnly(DateTime.now());
    notifyListeners();
  }

  void selectDay(DateTime day) {
    final normalized = _dateOnly(day);
    final today = _dateOnly(DateTime.now());

    if (normalized.isAfter(today)) return;

    _selectedDay = normalized;
    notifyListeners();
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

import 'package:habit_control/core/utils/day_key.dart';

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Returns the first day of the month for [date].
DateTime startOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

/// Returns the last day of the month for [date].
DateTime endOfMonth(DateTime date) {
  return DateTime(date.year, date.month + 1, 0);
}

/// Returns the Monday of the ISO week that contains [date].
DateTime startOfWeek(DateTime date) {
  final normalized = _dateOnly(date);
  final delta = normalized.weekday - DateTime.monday;
  return normalized.subtract(Duration(days: delta));
}

/// Returns the Sunday of the ISO week that contains [date].
DateTime endOfWeek(DateTime date) {
  return startOfWeek(date).add(const Duration(days: 6));
}

/// Returns the inclusive list of day keys between [start] and [end].
List<String> dayKeysBetween(DateTime start, DateTime end) {
  final normalizedStart = _dateOnly(start);
  final normalizedEnd = _dateOnly(end);

  final keys = <String>[];
  DateTime current = normalizedStart;

  while (!current.isAfter(normalizedEnd)) {
    keys.add(dayKeyFromDate(current));
    current = current.add(const Duration(days: 1));
  }

  return keys;
}

/// Returns every day key of the month that contains [date].
List<String> monthKeysOf(DateTime date) {
  return dayKeysBetween(startOfMonth(date), endOfMonth(date));
}

/// Returns every day key of the ISO week that contains [date].
List<String> weekKeysOf(DateTime date) {
  return dayKeysBetween(startOfWeek(date), endOfWeek(date));
}

import 'package:habit_control/screens/habits/models/habit.dart';
import 'package:habit_control/screens/habits/models/habit_category.dart';

class InsightMetric {
  const InsightMetric({
    required this.name,
    required this.semanticCategory,
    required this.value,
    required this.interpretation,
    this.unit,
  });

  final String name;
  final String semanticCategory;
  final double value;
  final String interpretation;
  final String? unit;
}

class DailyInsightService {
  const DailyInsightService();

  String buildInsight({
    required List<Habit> habits,
    required Set<String> completedHabitIds,
    required List<InsightMetric> metrics,
    String? weatherContext,
  }) {
    if (habits.isEmpty) {
      return 'Create your first habits to start receiving useful daily insights.';
    }

    final completed = habits
        .where((habit) => completedHabitIds.contains(habit.id))
        .length;

    final progress = completed / habits.length;
    final weakestCategory = _weakestCategory(habits, completedHabitIds);

    final sleep = _metricByCategory(metrics, HabitCategory.sleep);
    final energy = _metricByCategory(metrics, 'energy');
    final relatedMetric = _metricByCategory(metrics, weakestCategory);
    final extraMetric = _firstExtraMetric(metrics);

    final lowSleep = sleep != null && sleep.value > 0 && sleep.value < 6;
    final goodSleep = sleep != null && sleep.value >= 7;

    final lowEnergy = energy != null && energy.value > 0 && energy.value < 5;
    final goodEnergy = energy != null && energy.value >= 7;

    if (progress >= 0.8) {
      if (lowSleep) {
        return 'Strong consistency today, but your sleep was low. Keep the routine lighter tomorrow so your progress is sustainable.';
      }

      if (lowEnergy) {
        return 'Strong consistency today despite low energy. This is a good sign, but avoid overloading yourself.';
      }

      if (goodSleep && goodEnergy) {
        return 'Excellent day: strong habit consistency, good sleep and good energy. This is the kind of pattern worth repeating.';
      }

      return _appendWeather(
        'Strong consistency today. Your routine is working well, so focus on maintaining this rhythm.',
        weatherContext,
      );
    }

    if (progress >= 0.4) {
      if (lowSleep && lowEnergy) {
        return 'Moderate consistency today, with low sleep and low energy. Recovery should be the priority before forcing a perfect routine.';
      }

      if (lowSleep) {
        return 'Moderate consistency today. Low sleep may have affected your performance, so prioritize rest tonight.';
      }

      if (lowEnergy) {
        return 'Moderate consistency today. Your energy was low, so focus on one or two key habits instead of trying to complete everything.';
      }

      if (relatedMetric != null && relatedMetric.value > 0) {
        return 'Moderate consistency today. Your weakest area was ${HabitCategory.labelOf(weakestCategory).toLowerCase()}, and your ${relatedMetric.name.toLowerCase()} metric can help explain that pattern.';
      }

      if (extraMetric != null) {
        return 'Moderate consistency today. Review your ${extraMetric.name.toLowerCase()} metric together with your habits to understand what affected your rhythm.';
      }

      return _appendWeather(
        'Moderate consistency today. Try to complete one more habit tomorrow to improve your rhythm.',
        weatherContext,
      );
    }

    if (weakestCategory == HabitCategory.exercise &&
        _hasWeather(weatherContext)) {
      return 'Low consistency today, especially in exercise. Weather may have affected your routine, so try a shorter indoor alternative.';
    }

    if (weakestCategory == HabitCategory.focus && lowEnergy) {
      return 'Low consistency today, especially in focus habits. Low energy may be the cause, so start tomorrow with one short task.';
    }

    if (lowSleep || lowEnergy) {
      return 'Low consistency today, but your metrics suggest a possible reason. Focus on recovery and complete one small habit to rebuild momentum.';
    }

    if (extraMetric != null) {
      return 'Low consistency today. Your ${extraMetric.name.toLowerCase()} metric may provide useful context when reviewing what interrupted your routine.';
    }

    return _appendWeather(
      'Low consistency today. Start small: complete one easy habit before trying to recover the full routine.',
      weatherContext,
    );
  }

  String _weakestCategory(List<Habit> habits, Set<String> completedHabitIds) {
    final totals = <String, int>{};
    final completed = <String, int>{};

    for (final habit in habits) {
      final category = habit.category.trim().isEmpty
          ? HabitCategory.custom
          : habit.category.trim();

      totals[category] = (totals[category] ?? 0) + 1;

      if (completedHabitIds.contains(habit.id)) {
        completed[category] = (completed[category] ?? 0) + 1;
      }
    }

    String weakest = totals.keys.first;
    double weakestRate = 1;

    for (final category in totals.keys) {
      final total = totals[category] ?? 0;
      if (total == 0) continue;

      final done = completed[category] ?? 0;
      final rate = done / total;

      if (rate < weakestRate) {
        weakestRate = rate;
        weakest = category;
      }
    }

    return weakest;
  }

  InsightMetric? _metricByCategory(
    List<InsightMetric> metrics,
    String category,
  ) {
    for (final metric in metrics) {
      if (metric.semanticCategory.trim().toLowerCase() ==
          category.trim().toLowerCase()) {
        return metric;
      }
    }

    return null;
  }

  InsightMetric? _firstExtraMetric(List<InsightMetric> metrics) {
    for (final metric in metrics) {
      final category = metric.semanticCategory.trim().toLowerCase();

      if (category != HabitCategory.sleep &&
          category != 'energy' &&
          metric.value > 0) {
        return metric;
      }
    }

    return null;
  }

  bool _hasWeather(String? weatherContext) {
    return weatherContext != null && weatherContext.trim().isNotEmpty;
  }

  String _appendWeather(String base, String? weatherContext) {
    if (!_hasWeather(weatherContext)) return base;
    return '$base ${weatherContext!.trim()}';
  }
}

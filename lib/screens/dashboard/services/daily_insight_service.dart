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
    required int completedHabits,
    required int totalHabits,
    required List<InsightMetric> metrics,
    String? weatherContext,
  }) {
    if (totalHabits == 0) {
      return 'Create your first habits to start receiving useful daily insights.';
    }

    final progress = completedHabits / totalHabits;
    final sleep = _metricByCategory(metrics, 'sleep');
    final energy = _metricByCategory(metrics, 'energy');

    final sleepValue = sleep?.value ?? 0;
    final energyValue = energy?.value ?? 0;

    final hasLowSleep = sleep != null && sleepValue > 0 && sleepValue < 6;
    final hasGoodSleep = sleep != null && sleepValue >= 7;
    final hasLowEnergy = energy != null && energyValue > 0 && energyValue < 5;
    final hasGoodEnergy = energy != null && energyValue >= 7;

    final extraMetric = _mostRelevantExtraMetric(metrics);

    if (progress >= 0.8) {
      if (hasLowEnergy) {
        return 'Strong consistency today despite low energy. Keep the routine light and avoid overloading yourself.';
      }

      if (hasLowSleep) {
        return 'Strong consistency today, but your sleep was low. Prioritize recovery so this rhythm is sustainable.';
      }

      if (hasGoodSleep && hasGoodEnergy) {
        return 'Excellent day: strong habit consistency, good sleep and good energy. This is the kind of pattern worth repeating.';
      }

      return _withWeather(
        'Strong consistency today. Your routine is working well, so focus on maintaining this rhythm.',
        weatherContext,
      );
    }

    if (progress >= 0.4) {
      if (hasLowSleep && hasLowEnergy) {
        return 'Moderate consistency today, with low sleep and low energy. Your priority should be recovery, not forcing a perfect routine.';
      }

      if (hasLowSleep) {
        return 'Moderate consistency today. Low sleep may have affected your performance, so aim for better rest tonight.';
      }

      if (hasLowEnergy) {
        return 'Moderate consistency today. Your energy was low, so focus on one or two key habits instead of trying to complete everything.';
      }

      if (extraMetric != null) {
        return 'Moderate consistency today. Your ${extraMetric.name.toLowerCase()} may be useful context when reviewing your progress.';
      }

      return _withWeather(
        'Moderate consistency today. Try to complete one more habit tomorrow to improve your rhythm.',
        weatherContext,
      );
    }

    if (hasLowSleep || hasLowEnergy) {
      return 'Low consistency today, but your metrics suggest a possible reason. Focus on rest and complete one small habit to rebuild momentum.';
    }

    if (extraMetric != null) {
      return 'Low consistency today. Review your ${extraMetric.name.toLowerCase()} together with your habits to detect what may be affecting your routine.';
    }

    return _withWeather(
      'Low consistency today. Start small: complete one easy habit before trying to recover the full routine.',
      weatherContext,
    );
  }

  InsightMetric? _metricByCategory(
    List<InsightMetric> metrics,
    String category,
  ) {
    for (final metric in metrics) {
      if (metric.semanticCategory.trim().toLowerCase() == category) {
        return metric;
      }
    }

    return null;
  }

  InsightMetric? _mostRelevantExtraMetric(List<InsightMetric> metrics) {
    final extras = metrics.where((metric) {
      final category = metric.semanticCategory.trim().toLowerCase();
      return category != 'sleep' && category != 'energy' && metric.value > 0;
    }).toList();

    if (extras.isEmpty) return null;

    return extras.first;
  }

  String _withWeather(String base, String? weatherContext) {
    if (weatherContext == null || weatherContext.trim().isEmpty) {
      return base;
    }

    return '$base ${weatherContext.trim()}';
  }
}

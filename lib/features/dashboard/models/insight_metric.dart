/// Metric input consumed by [DailyInsightService] to compose the daily
/// insight sentence.
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

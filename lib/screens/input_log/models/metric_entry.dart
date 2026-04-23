class MetricEntry {
  final String metricId;
  final String dayKey;
  final double numericValue;
  final int updatedAt;

  const MetricEntry({
    required this.metricId,
    required this.dayKey,
    required this.numericValue,
    required this.updatedAt,
  });

  MetricEntry copyWith({
    String? metricId,
    String? dayKey,
    double? numericValue,
    int? updatedAt,
  }) {
    return MetricEntry(
      metricId: metricId ?? this.metricId,
      dayKey: dayKey ?? this.dayKey,
      numericValue: numericValue ?? this.numericValue,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'metric_id': metricId,
      'day_key': dayKey,
      'numeric_value': numericValue,
      'updated_at': updatedAt,
    };
  }

  factory MetricEntry.fromMap(Map<String, dynamic> map) {
    final dynamic raw = map['numeric_value'];

    double value;
    if (raw is int) {
      value = raw.toDouble();
    } else if (raw is double) {
      value = raw;
    } else {
      value = 0.0;
    }

    return MetricEntry(
      metricId: map['metric_id'] as String,
      dayKey: map['day_key'] as String,
      numericValue: value,
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? 0,
    );
  }
}

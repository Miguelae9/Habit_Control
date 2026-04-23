class MetricDefinition {
  final String id;
  final String name;
  final String semanticCategory;
  final String valueType;
  final String? unit;
  final String interpretation;
  final int position;
  final int updatedAt;
  final bool deleted;

  const MetricDefinition({
    required this.id,
    required this.name,
    required this.semanticCategory,
    required this.valueType,
    required this.interpretation,
    required this.position,
    required this.updatedAt,
    this.unit,
    this.deleted = false,
  });

  MetricDefinition copyWith({
    String? id,
    String? name,
    String? semanticCategory,
    String? valueType,
    String? unit,
    String? interpretation,
    int? position,
    int? updatedAt,
    bool? deleted,
  }) {
    return MetricDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      semanticCategory: semanticCategory ?? this.semanticCategory,
      valueType: valueType ?? this.valueType,
      unit: unit ?? this.unit,
      interpretation: interpretation ?? this.interpretation,
      position: position ?? this.position,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'semantic_category': semanticCategory,
      'value_type': valueType,
      'unit': unit,
      'interpretation': interpretation,
      'position': position,
      'updated_at': updatedAt,
      'deleted': deleted ? 1 : 0,
    };
  }

  factory MetricDefinition.fromMap(Map<String, dynamic> map) {
    return MetricDefinition(
      id: map['id'] as String,
      name: map['name'] as String,
      semanticCategory: map['semantic_category'] as String,
      valueType: map['value_type'] as String,
      unit: map['unit'] as String?,
      interpretation: map['interpretation'] as String,
      position: (map['position'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? 0,
      deleted: ((map['deleted'] as num?)?.toInt() ?? 0) == 1,
    );
  }
}

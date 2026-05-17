import 'package:habit_control/features/habits/models/habit_category.dart';

/// A habit defined by the user.
class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.position,
    required this.updatedAt,
    this.deleted = false,
  });

  final String id;
  final String title;
  final String category;
  final int position;
  final int updatedAt;
  final bool deleted;

  Habit copyWith({
    String? id,
    String? title,
    String? category,
    int? position,
    int? updatedAt,
    bool? deleted,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      position: position ?? this.position,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'category': category,
      'position': position,
      'updated_at': updatedAt,
      'deleted': deleted ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      title: map['title'] as String,
      category: (map['category'] as String?) ?? HabitCategory.custom,
      position: (map['position'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? 0,
      deleted: ((map['deleted'] as num?)?.toInt() ?? 0) == 1,
    );
  }
}

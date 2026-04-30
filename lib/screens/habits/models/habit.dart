import 'package:habit_control/screens/habits/models/habit_category.dart';

class Habit {
  final String id;
  final String title;
  final String category;
  final String streakText;
  final int position;
  final int updatedAt;
  final bool deleted;

  const Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.streakText,
    required this.position,
    required this.updatedAt,
    this.deleted = false,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? category,
    String? streakText,
    int? position,
    int? updatedAt,
    bool? deleted,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      streakText: streakText ?? this.streakText,
      position: position ?? this.position,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'streak_text': streakText,
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
      streakText: map['streak_text'] as String,
      position: (map['position'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? 0,
      deleted: ((map['deleted'] as num?)?.toInt() ?? 0) == 1,
    );
  }
}

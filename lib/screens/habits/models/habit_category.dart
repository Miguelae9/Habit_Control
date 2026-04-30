class HabitCategory {
  HabitCategory._();

  static const String health = 'health';
  static const String exercise = 'exercise';
  static const String sleep = 'sleep';
  static const String focus = 'focus';
  static const String mood = 'mood';
  static const String nutrition = 'nutrition';
  static const String social = 'social';
  static const String discipline = 'discipline';
  static const String custom = 'custom';

  static const List<String> values = [
    health,
    exercise,
    sleep,
    focus,
    mood,
    nutrition,
    social,
    discipline,
    custom,
  ];

  static String labelOf(String value) {
    switch (value) {
      case health:
        return 'Health';
      case exercise:
        return 'Exercise';
      case sleep:
        return 'Sleep';
      case focus:
        return 'Focus';
      case mood:
        return 'Mood';
      case nutrition:
        return 'Nutrition';
      case social:
        return 'Social';
      case discipline:
        return 'Discipline';
      case custom:
        return 'Custom';
      default:
        return 'Custom';
    }
  }
}

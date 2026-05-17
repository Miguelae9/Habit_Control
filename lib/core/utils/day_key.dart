/// Returns a stable `YYYY-MM-DD` key for the given [DateTime].
///
/// The key is used as an identifier in local storage and Firestore documents.
String dayKeyFromDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

import 'models.dart';

enum PeriodType { week, month, year }

DateTime startOfWeek(DateTime d) =>
    DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
(DateTime, DateTime) periodBounds(PeriodType type, DateTime reference) {
  if (type == PeriodType.week) {
    final start = startOfWeek(reference);
    return (start, start.add(const Duration(days: 6)));
  }
  if (type == PeriodType.year) {
    return (DateTime(reference.year), DateTime(reference.year, 12, 31));
  }
  return (
    DateTime(reference.year, reference.month),
    DateTime(reference.year, reference.month + 1, 0),
  );
}

class OperatorReport {
  const OperatorReport({
    required this.operator,
    required this.counts,
    required this.total,
    required this.activeDays,
  });
  final OperatorModel operator;
  final Map<String, int> counts;
  final int total;
  final int activeDays;
  double percent(String activityId) =>
      total == 0 ? 0 : (counts[activityId] ?? 0) / total;
}

List<OperatorReport> buildReport(
  AppData data,
  PeriodType type,
  DateTime reference,
) {
  final (start, end) = periodBounds(type, reference);
  final min = isoDate(start), max = isoDate(end);
  return data.operators.map((operator) {
    final counts = {for (final a in data.activities) a.id: 0};
    var activeDays = 0;
    for (final entry in data.assignments.entries) {
      final parts = entry.key.split('|');
      if (parts.length != 2 ||
          parts[0] != operator.id ||
          parts[1].compareTo(min) < 0 ||
          parts[1].compareTo(max) > 0) {
        continue;
      }
      if (entry.value.isNotEmpty) {
        activeDays++;
      }
      for (final id in entry.value) {
        if (counts.containsKey(id)) counts[id] = counts[id]! + 1;
      }
    }
    return OperatorReport(
      operator: operator,
      counts: counts,
      total: counts.values.fold(0, (a, b) => a + b),
      activeDays: activeDays,
    );
  }).toList();
}


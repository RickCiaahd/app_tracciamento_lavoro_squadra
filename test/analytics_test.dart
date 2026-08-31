import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_tracker/analytics.dart';
import 'package:squadra_tracker/models.dart';

void main() {
  test('conta più attività nello stesso giorno', () {
    final data = AppData(
      operators: [const OperatorModel(id: 'o1', name: 'Mario')],
      activities: const [
        ActivityModel(id: 'a', name: 'A', color: 0),
        ActivityModel(id: 'b', name: 'B', color: 0),
      ],
      assignments: {
        'o1|2026-02-03': ['a', 'b'],
        'o1|2026-02-04': ['a'],
      },
    );
    final row = buildReport(
      data,
      PeriodType.month,
      DateTime(2026, 2, 12),
    ).single;
    expect(row.total, 3);
    expect(row.activeDays, 2);
    expect(row.percent('a'), closeTo(2 / 3, .0001));
  });
  test('calcola il mese intero', () {
    final (a, b) = periodBounds(PeriodType.month, DateTime(2026, 2, 12));
    expect(isoDate(a), '2026-02-01');
    expect(isoDate(b), '2026-02-28');
  });
}


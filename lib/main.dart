import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'analytics.dart';
import 'models.dart';
import 'repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SquadraApp());
}

const navy = Color(0xFF17324D),
    teal = Color(0xFF0F766E),
    canvas = Color(0xFFF3F6F8);

class SquadraApp extends StatelessWidget {
  const SquadraApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Squadra',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        primary: teal,
        secondary: navy,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: canvas,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repo = DataRepository();
  AppData? data;
  int tab = 0;
  DateTime week = startOfWeek(DateTime.now());
  @override
  void initState() {
    super.initState();
    repo.load().then((value) => setState(() => data = value));
  }

  Future<void> changed() async {
    setState(() {});
    await repo.save(data!);
  }

  @override
  Widget build(BuildContext context) {
    final d = data;
    if (d == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final pages = [
      PlannerPage(
        data: d,
        week: week,
        onWeek: (v) => setState(() => week = v),
        onChanged: changed,
      ),
      ReportPage(data: d),
      SettingsPage(data: d, repo: repo, onChanged: changed),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PIANIFICAZIONE OPERATIVA',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            Text('Squadra', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Pianifica',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
      ),
    );
  }
}

class PlannerPage extends StatelessWidget {
  const PlannerPage({
    super.key,
    required this.data,
    required this.week,
    required this.onWeek,
    required this.onChanged,
  });
  final AppData data;
  final DateTime week;
  final ValueChanged<DateTime> onWeek;
  final Future<void> Function() onChanged;
  static const days = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
  static const months = [
    'gen',
    'feb',
    'mar',
    'apr',
    'mag',
    'giu',
    'lug',
    'ago',
    'set',
    'ott',
    'nov',
    'dic',
  ];

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(7, (i) => week.add(Duration(days: i)));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        onWeek(week.subtract(const Duration(days: 7))),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      '${week.day} ${months[week.month - 1]} – ${dates.last.day} ${months[dates.last.month - 1]} ${dates.last.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onWeek(week.add(const Duration(days: 7))),
                    icon: const Icon(Icons.chevron_right),
                  ),
                  TextButton(
                    onPressed: () => onWeek(startOfWeek(DateTime.now())),
                    child: const Text('Oggi'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(MediaQuery.sizeOf(context).width, 900),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFFDCEEEA),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 150,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Operatore',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        ...List.generate(
                          7,
                          (i) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text(
                                    days[i],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${dates[i].day} ${months[dates[i].month - 1]}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.operators.length,
                      itemBuilder: (context, index) {
                        final op = data.operators[index];
                        return SizedBox(
                          height: 78,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 150,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    op.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              ...dates.map(
                                (date) => Expanded(
                                  child: AssignmentCell(
                                    data: data,
                                    operator: op,
                                    date: date,
                                    onChanged: onChanged,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AssignmentCell extends StatelessWidget {
  const AssignmentCell({
    super.key,
    required this.data,
    required this.operator,
    required this.date,
    required this.onChanged,
  });
  final AppData data;
  final OperatorModel operator;
  final DateTime date;
  final Future<void> Function() onChanged;
  @override
  Widget build(BuildContext context) {
    final ids = data.assignments[dayKey(operator.id, date)] ?? [];
    return InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => ActivityDialog(
          data: data,
          operator: operator,
          date: date,
          initial: ids,
          onSaved: (chosen) async {
            final key = dayKey(operator.id, date);
            if (chosen.isEmpty) {
              data.assignments.remove(key);
            } else {
              data.assignments[key] = chosen;
            }
            await onChanged();
          },
        ),
      ),
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: ids.isEmpty ? Colors.white : const Color(0xFFF1FAF7),
          border: Border.all(color: const Color(0xFFDCE5EA), width: .5),
        ),
        child: ids.isEmpty
            ? const Icon(Icons.add, color: Colors.black26)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    spacing: 4,
                    children: ids.map((id) {
                      final a = data.activities
                          .where((a) => a.id == id)
                          .firstOrNull;
                      return CircleAvatar(
                        radius: 5,
                        backgroundColor: Color(a?.color ?? 0xFF94A3B8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${ids.length} attività',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
      ),
    );
  }
}

class ActivityDialog extends StatefulWidget {
  const ActivityDialog({
    super.key,
    required this.data,
    required this.operator,
    required this.date,
    required this.initial,
    required this.onSaved,
  });
  final AppData data;
  final OperatorModel operator;
  final DateTime date;
  final List<String> initial;
  final ValueChanged<List<String>> onSaved;
  @override
  State<ActivityDialog> createState() => _ActivityDialogState();
}

class _ActivityDialogState extends State<ActivityDialog> {
  late final Set<String> chosen = {...widget.initial};
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.operator.name),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.date.day}/${widget.date.month}/${widget.date.year}',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ...widget.data.activities.map(
            (a) => CheckboxListTile(
              value: chosen.contains(a.id),
              activeColor: teal,
              secondary: CircleAvatar(
                radius: 6,
                backgroundColor: Color(a.color),
              ),
              title: Text(a.name),
              onChanged: (v) =>
                  setState(() => v! ? chosen.add(a.id) : chosen.remove(a.id)),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annulla'),
      ),
      FilledButton(
        onPressed: () {
          widget.onSaved(chosen.toList());
          Navigator.pop(context);
        },
        child: const Text('Salva attività'),
      ),
    ],
  );
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.data});
  final AppData data;
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  PeriodType type = PeriodType.month;
  DateTime reference = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final rows = buildReport(widget.data, type, reference),
        total = rows.fold(0, (n, r) => n + r.total),
        active = rows.where((r) => r.total > 0).length;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                DropdownButton<PeriodType>(
                  value: type,
                  items: const [
                    DropdownMenuItem(
                      value: PeriodType.week,
                      child: Text('Settimana'),
                    ),
                    DropdownMenuItem(
                      value: PeriodType.month,
                      child: Text('Mese'),
                    ),
                    DropdownMenuItem(
                      value: PeriodType.year,
                      child: Text('Anno'),
                    ),
                  ],
                  onChanged: (v) => setState(() => type = v!),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: reference,
                    );
                    if (d != null) setState(() => reference = d);
                  },
                  icon: const Icon(Icons.event),
                  label: Text(
                    '${reference.day}/${reference.month}/${reference.year}',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(label: 'Assegnazioni', value: '$total'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricCard(
                label: 'Operatori attivi',
                value: '$active/${rows.length}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...rows.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ReportCard(data: widget.data, row: r),
          ),
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ),
  );
}

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.data, required this.row});
  final AppData data;
  final OperatorReport row;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.operator.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Text(
            '${row.total} assegnazioni · ${row.activeDays} giorni',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 145,
            child: Row(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: PiePainter(activities: data.activities, row: row),
                    child: Center(
                      child: Text(
                        '${row.total}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: ListView(
                    children: data.activities
                        .map(
                          (a) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor: Color(a.color),
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    a.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${(row.percent(a.id) * 100).round()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class PiePainter extends CustomPainter {
  PiePainter({required this.activities, required this.row});
  final List<ActivityModel> activities;
  final OperatorReport row;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    var start = -math.pi / 2;
    if (row.total == 0) {
      canvas.drawArc(
        rect,
        0,
        math.pi * 2,
        true,
        Paint()..color = const Color(0xFFE2E8F0),
      );
    } else {
      for (final a in activities) {
        final sweep = row.percent(a.id) * math.pi * 2;
        canvas.drawArc(
          rect,
          start,
          sweep,
          true,
          Paint()..color = Color(a.color),
        );
        start += sweep;
      }
    }
    canvas.drawCircle(
      rect.center,
      size.width * .27,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant PiePainter old) => true;
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.data,
    required this.repo,
    required this.onChanged,
  });
  final AppData data;
  final DataRepository repo;
  final Future<void> Function() onChanged;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<String?> ask(String title, [String value = '']) async {
    final c = TextEditingController(text: value);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, c.text.trim()),
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  Future<void> addOperator() async {
    final name = await ask('Nuovo operatore');
    if (name?.isNotEmpty ?? false) {
      widget.data.operators.add(
        OperatorModel(
          id: 'op-${DateTime.now().microsecondsSinceEpoch}',
          name: name!,
        ),
      );
      await widget.onChanged();
    }
  }

  Future<void> addActivity() async {
    final name = await ask('Nuova attività');
    if (name?.isNotEmpty ?? false) {
      const colors = [
        0xFF0F766E,
        0xFFE76F51,
        0xFF457B9D,
        0xFF8E5EA2,
        0xFFF4A261,
      ];
      widget.data.activities.add(
        ActivityModel(
          id: 'act-${DateTime.now().microsecondsSinceEpoch}',
          name: name!,
          color: colors[widget.data.activities.length % colors.length],
        ),
      );
      await widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      SettingsCard(
        title: 'Operatori',
        onAdd: addOperator,
        children: widget.data.operators
            .map(
              (o) => ListTile(
                title: Text(o.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    widget.data.operators.remove(o);
                    widget.data.assignments.removeWhere(
                      (k, v) => k.startsWith('${o.id}|'),
                    );
                    await widget.onChanged();
                  },
                ),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 12),
      SettingsCard(
        title: 'Attività',
        onAdd: addActivity,
        children: widget.data.activities
            .map(
              (a) => ListTile(
                leading: CircleAvatar(
                  radius: 7,
                  backgroundColor: Color(a.color),
                ),
                title: Text(a.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    widget.data.activities.remove(a);
                    for (final ids in widget.data.assignments.values) {
                      ids.remove(a.id);
                    }
                    await widget.onChanged();
                  },
                ),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Backup',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'I dati restano sul telefono. Copia il backup e conservalo in un luogo sicuro.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      await widget.repo.copyBackup(widget.data);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Backup copiato negli appunti'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copia backup'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final raw = await ask('Incolla il backup');
                      if (raw?.isNotEmpty ?? false) {
                        try {
                          final imported = widget.repo.import(raw!);
                          widget.data.operators = imported.operators;
                          widget.data.activities = imported.activities;
                          widget.data.assignments = imported.assignments;
                          await widget.onChanged();
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Backup non valido'),
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.paste),
                    label: const Text('Importa'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.title,
    required this.onAdd,
    required this.children,
  });
  final String title;
  final VoidCallback onAdd;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            trailing: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi'),
            ),
          ),
          ...children,
        ],
      ),
    ),
  );
}


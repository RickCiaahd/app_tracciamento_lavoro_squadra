class OperatorModel {
  const OperatorModel({required this.id, required this.name});
  final String id;
  final String name;
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory OperatorModel.fromJson(Map<String, dynamic> json) =>
      OperatorModel(id: json['id'] as String, name: json['name'] as String);
}

class ActivityModel {
  const ActivityModel({
    required this.id,
    required this.name,
    required this.color,
  });
  final String id;
  final String name;
  final int color;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color};
  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
    id: json['id'] as String,
    name: json['name'] as String,
    color: json['color'] as int,
  );
}

class AppData {
  AppData({
    required this.operators,
    required this.activities,
    required this.assignments,
  });
  List<OperatorModel> operators;
  List<ActivityModel> activities;
  Map<String, List<String>> assignments;
  Map<String, dynamic> toJson() => {
    'version': 1,
    'operators': operators.map((e) => e.toJson()).toList(),
    'activities': activities.map((e) => e.toJson()).toList(),
    'assignments': assignments,
  };
  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
    operators: (json['operators'] as List)
        .map((e) => OperatorModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    activities: (json['activities'] as List)
        .map((e) => ActivityModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    assignments: (json['assignments'] as Map).map(
      (k, v) => MapEntry(k as String, List<String>.from(v as List)),
    ),
  );
  factory AppData.seed() => AppData(
    operators: List.generate(
      10,
      (i) => OperatorModel(id: 'op-${i + 1}', name: 'Operatore ${i + 1}'),
    ),
    activities: const [
      ActivityModel(id: 'pulizia', name: 'Pulizia', color: 0xFF0F766E),
      ActivityModel(id: 'riparazioni', name: 'Riparazioni', color: 0xFFE76F51),
      ActivityModel(id: 'diagnostica', name: 'Diagnostica', color: 0xFF2A9D8F),
      ActivityModel(
        id: 'manutenzione',
        name: 'Manutenzione',
        color: 0xFF457B9D,
      ),
      ActivityModel(
        id: 'qualita',
        name: 'Controllo qualità',
        color: 0xFF8E5EA2,
      ),
    ],
    assignments: {},
  );
}

String dayKey(String operatorId, DateTime date) =>
    '$operatorId|${isoDate(date)}';
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';


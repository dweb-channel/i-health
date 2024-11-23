import 'package:hive/hive.dart';

part 'period_record.g.dart';

@HiveType(typeId: 0)
class PeriodRecord extends HiveObject {
  @HiveField(0)
  final DateTime startDate;

  @HiveField(1)
  final DateTime? endDate;

  @HiveField(2)
  final Map<String, bool> symptoms;

  @HiveField(3)
  final int flow; // 1-4: light, medium, heavy, very heavy

  @HiveField(4)
  final String notes;

  @HiveField(5)
  final Map<String, bool> mood;

  PeriodRecord({
    required this.startDate,
    this.endDate,
    Map<String, bool>? symptoms,
    this.flow = 1,
    this.notes = '',
    Map<String, bool>? mood,
  })  : symptoms = symptoms ?? {},
        mood = mood ?? {};

  static const List<String> defaultSymptoms = [
    '腹痛',
    '头痛',
    '乳房胀痛',
    '疲劳',
    '恶心',
    '腰痛',
    '食欲改变',
    '痤疮',
  ];

  static const List<String> defaultMoods = [
    '平静',
    '快乐',
    '焦虑',
    '易怒',
    '沮丧',
    '情绪波动',
  ];
}

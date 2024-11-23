import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class CycleRecord {
  @HiveField(0)
  final DateTime startDate;

  @HiveField(1)
  final int cycleLength;

  @HiveField(2)
  final int periodLength;

  @HiveField(3)
  final Map<String, bool> symptoms;

  @HiveField(4)
  final String notes;

  CycleRecord({
    required this.startDate,
    required this.cycleLength,
    required this.periodLength,
    required this.symptoms,
    this.notes = '',
  });
}

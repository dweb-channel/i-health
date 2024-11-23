import 'package:hive/hive.dart';
import '../models/period_record.dart';

// 经期服务类 - 处理所有与经期相关的数据操作
class PeriodService {
  // Hive数据库实例
  static const String _boxName = 'period_records';
  late Box<PeriodRecord> _box;

  // 初始化服务
  Future<void> init() async {
    Hive.registerAdapter(PeriodRecordAdapter());
    _box = await Hive.openBox<PeriodRecord>(_boxName);
  }

  // 添加新的经期记录
  Future<void> addRecord(PeriodRecord record) async {
    await _box.add(record);
  }

  // 获取所有经期记录
  List<PeriodRecord> getAllRecords() {
    return _box.values.toList();
  }

  // 获取指定月份的所有经期记录
  List<PeriodRecord> getRecordsForMonth(DateTime month) {
    return _box.values.where((record) {
      return record.startDate.year == month.year &&
          record.startDate.month == month.month;
    }).toList();
  }

  // 预测下一次经期
  DateTime? predictNextPeriod() {
    final records = getAllRecords();
    if (records.length < 2) return null;

    // Sort records by date
    records.sort((a, b) => b.startDate.compareTo(a.startDate));

    // Calculate average cycle length
    int totalDays = 0;
    int count = 0;
    for (int i = 0; i < records.length - 1; i++) {
      final difference = records[i].startDate.difference(records[i + 1].startDate).inDays;
      if (difference > 0 && difference < 45) { // Filter out potentially incorrect data
        totalDays += difference;
        count++;
      }
    }

    if (count == 0) return null;

    final averageCycleLength = totalDays ~/ count;
    return records.first.startDate.add(Duration(days: averageCycleLength));
  }

  // 获取常见症状
  Map<String, int> getCommonSymptoms() {
    final records = getAllRecords();
    final Map<String, int> symptoms = {};

    for (var record in records) {
      record.symptoms.forEach((symptom, hasSymptom) {
        if (hasSymptom) {
          symptoms[symptom] = (symptoms[symptom] ?? 0) + 1;
        }
      });
    }

    return symptoms;
  }

  // 获取平均周期长度
  double getAverageCycleLength() {
    final records = getAllRecords();
    if (records.length < 2) return 0;

    records.sort((a, b) => a.startDate.compareTo(b.startDate));
    
    int totalDays = 0;
    int count = 0;
    for (int i = 0; i < records.length - 1; i++) {
      final difference = records[i + 1].startDate.difference(records[i].startDate).inDays;
      if (difference > 0 && difference < 45) {
        totalDays += difference;
        count++;
      }
    }

    return count > 0 ? totalDays / count : 0;
  }

  // 安排通知
  Future<void> scheduleNotification(DateTime nextPeriod) async {
    // TODO: 实现通知安排
  }
}

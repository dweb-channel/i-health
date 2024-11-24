import 'package:hive/hive.dart';
import '../models/period_record.dart';

/// 数据库服务类 - 处理所有数据库相关的操作
class DatabaseService {
  // 单例模式实现
  static final DatabaseService _instance = DatabaseService._();
  factory DatabaseService() => _instance;
  DatabaseService._();

  // Hive数据库实例
  static const String _periodBoxName = 'period_records';
  Box<PeriodRecord>? _periodBox;

  /// 初始化数据库
  Future<void> init() async {
    // 注册所有适配器
    Hive.registerAdapter(PeriodRecordAdapter());
    
    // 打开所有数据库盒子
    _periodBox = await Hive.openBox<PeriodRecord>(_periodBoxName);
  }

  /// 关闭数据库连接
  Future<void> close() async {
    await _periodBox?.close();
  }

  // 经期记录相关操作
  
  /// 添加新的经期记录
  Future<void> addPeriodRecord(PeriodRecord record) async {
    await _periodBox?.add(record);
  }

  /// 更新经期记录
  Future<void> updatePeriodRecord(int index, PeriodRecord record) async {
    await _periodBox?.putAt(index, record);
  }

  /// 删除经期记录
  Future<void> deletePeriodRecord(int index) async {
    await _periodBox?.deleteAt(index);
  }

  /// 获取所有经期记录
  List<PeriodRecord> getAllPeriodRecords() {
    return _periodBox?.values.toList() ?? [];
  }

  /// 获取指定月份的所有经期记录
  List<PeriodRecord> getPeriodRecordsForMonth(DateTime month) {
    return _periodBox?.values.where((record) {
      return record.startDate.year == month.year &&
          record.startDate.month == month.month;
    }).toList() ?? [];
  }

  /// 按日期范围获取经期记录
  List<PeriodRecord> getPeriodRecordsInRange(DateTime start, DateTime end) {
    return _periodBox?.values.where((record) {
      return record.startDate.isAfter(start.subtract(const Duration(days: 1))) &&
          record.startDate.isBefore(end.add(const Duration(days: 1)));
    }).toList() ?? [];
  }

  /// 清除所有经期记录
  Future<void> clearAllPeriodRecords() async {
    await _periodBox?.clear();
  }

  /// 获取最近的经期记录
  PeriodRecord? getLatestPeriodRecord() {
    final records = getAllPeriodRecords();
    if (records.isEmpty) return null;
    
    records.sort((a, b) => b.startDate.compareTo(a.startDate));
    return records.first;
  }

  /// 导出所有数据
  Map<String, dynamic> exportAllData() {
    return {
      'period_records': getAllPeriodRecords().map((record) => {
        'startDate': record.startDate.toIso8601String(),
        'endDate': record.endDate?.toIso8601String(),
        'symptoms': record.symptoms,
        'flow': record.flow,
        'notes': record.notes,
        'mood': record.mood,
      }).toList(),
    };
  }

  /// 导入数据
  Future<void> importData(Map<String, dynamic> data) async {
    // 清除现有数据
    await clearAllPeriodRecords();

    // 导入经期记录
    final periodRecords = (data['period_records'] as List?)?.map((record) => 
      PeriodRecord(
        startDate: DateTime.parse(record['startDate']),
        endDate: record['endDate'] != null ? DateTime.parse(record['endDate']) : null,
        symptoms: Map<String, bool>.from(record['symptoms']),
        flow: record['flow'],
        notes: record['notes'],
        mood: Map<String, bool>.from(record['mood']),
      )).toList() ?? [];

    for (var record in periodRecords) {
      await addPeriodRecord(record);
    }
  }
}

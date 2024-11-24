// 设置页面组件
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../services/period_service.dart';
import '../models/period_record.dart';
import '../services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// 设置页面状态
class _SettingsPageState extends State<SettingsPage> {
  late final SharedPreferences _prefs;
  late final PeriodService _periodService;

  // 通知开关状态
  bool _notificationsEnabled = false;  // 默认关闭通知
  // 提前提醒天数
  int _reminderDays = 2;
  // 导出格式选择
  String _exportFormat = 'CSV';

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    _periodService = PeriodService();
    await _periodService.init();
    await _loadSettings();

    // 检查通知权限状态
    final hasPermission = await _periodService.checkNotificationPermissions();
    setState(() {
      _notificationsEnabled = hasPermission;
    });
    await _saveSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? false;
      _reminderDays = _prefs.getInt('reminder_days') ?? 2;
      _exportFormat = _prefs.getString('export_format') ?? 'CSV';
    });
  }

  Future<void> _saveSettings() async {
    await _prefs.setBool('notifications_enabled', _notificationsEnabled);
    await _prefs.setInt('reminder_days', _reminderDays);
    await _prefs.setString('export_format', _exportFormat);
  }

  Future<void> _updateNotifications() async {
    if (_notificationsEnabled) {
      final nextPeriod = _periodService.predictNextPeriod();
      if (nextPeriod != null) {
        await _periodService.scheduleNotification(nextPeriod, _reminderDays);
      }
    } else {
      await _periodService.cancelAllNotifications();
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // 初始化通知服务
      final notificationService = NotificationService();
      await notificationService.init();
      
      // 请求通知权限
      final hasPermission = await notificationService.requestNotificationPermissions();
      if (hasPermission) {
        setState(() {
          _notificationsEnabled = true;
        });
        // 如果有下一次经期日期，设置通知
        await _updateNotifications();
      } else {
        // 如果用户拒绝了权限，显示提示
        if (mounted) {
          _showAlert(
            context,
            '通知权限',
            '需要通知权限才能发送提醒。请在系统设置中启用通知权限。',
          );
        }
        setState(() {
          _notificationsEnabled = false;
        });
      }
    } else {
      // 关闭通知
      final notificationService = NotificationService();
      await notificationService.cancelAllNotifications();
      setState(() {
        _notificationsEnabled = false;
      });
    }
    await _saveSettings();
  }

  Future<void> _exportData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final fileName =
          'period_data_${now.year}${now.month}${now.day}.${_exportFormat.toLowerCase()}';
      final file = File('${directory.path}/$fileName');

      // 从 Hive 或其他存储中获取数据
      final data = await _getPeriodData();

      switch (_exportFormat) {
        case 'CSV':
          final csvData = [
            ['日期', '经期强度', '症状'], // 表头
            ...data.map((record) => [
                  record['date'],
                  record['flow'],
                  record['symptoms'].join(', '),
                ]),
          ];
          final csv = const ListToCsvConverter().convert(csvData);
          await file.writeAsString(csv);
          break;
        case 'JSON':
          final jsonData = json.encode({'records': data});
          await file.writeAsString(jsonData);
          break;
        case 'PDF':
          // TODO: 实现 PDF 导出
          throw UnimplementedError('PDF export not implemented yet');
      }

      // 分享文件
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '经期记录导出数据',
      );

      // 显示成功提示
      if (mounted) {
        _showAlert(
          context,
          '导出成功',
          '数据已成功导出到文件：$fileName',
        );
      }
    } catch (e) {
      if (mounted) {
        _showAlert(
          context,
          '导出失败',
          '导出数据时发生错误：${e.toString()}',
        );
      }
    }
  }

  Future<void> _backupData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final backupFileName =
          'period_backup_${now.year}${now.month}${now.day}.json';
      final backupFile = File('${directory.path}/$backupFileName');

      // 获取所有需要备份的数据
      final backupData = {
        'settings': {
          'notifications_enabled': _notificationsEnabled,
          'reminder_days': _reminderDays,
          'export_format': _exportFormat,
        },
        'period_data': await _getPeriodData(),
      };

      // 保存备份文件
      await backupFile.writeAsString(json.encode(backupData));

      // 分享备份文件
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: '经期记录备份数据',
      );

      if (mounted) {
        _showAlert(
          context,
          '备份成功',
          '数据已成功备份到文件：$backupFileName',
        );
      }
    } catch (e) {
      if (mounted) {
        _showAlert(
          context,
          '备份失败',
          '备份数据时发生错误：${e.toString()}',
        );
      }
    }
  }

  Future<void> _restoreData() async {
    try {
      // 选择备份文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final content = await file.readAsString();
        final backupData = json.decode(content);

        // 恢复设置
        final settings = backupData['settings'];
        setState(() {
          _notificationsEnabled = settings['notifications_enabled'] ?? false;
          _reminderDays = settings['reminder_days'] ?? 2;
          _exportFormat = settings['export_format'] ?? 'CSV';
        });
        await _saveSettings();

        // 恢复经期数据
        await _restorePeriodData(backupData['period_data']);

        if (mounted) {
          _showAlert(
            context,
            '恢复成功',
            '数据已成功从备份文件恢复',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showAlert(
          context,
          '恢复失败',
          '恢复数据时发生错误：${e.toString()}',
        );
      }
    }
  }

  // 恢复经期数据的辅助方法
  Future<void> _restorePeriodData(List<dynamic> data) async {
    // 首先清除现有数据
    await _periodService.clearAllData();

    // 恢复数据
    for (var recordData in data) {
      final record = PeriodRecord(
        startDate: DateTime.parse(recordData['date']),
        endDate: recordData['end_date'] != null
            ? DateTime.parse(recordData['end_date'])
            : null,
        flow: _getFlowValue(recordData['flow']),
        notes: recordData['notes'] ?? '',
        symptoms: Map<String, bool>.from(recordData['symptoms'] ?? {}),
        mood: recordData['mood'] ?? '',
      );
      await _periodService.restoreRecord(record);
    }
  }

  Future<void> _clearAllData() async {
    try {
      // 清除经期记录
      await _periodService.clearAllData();

      // 清除设置
      await _prefs.clear();

      // 重置设置状态
      setState(() {
        _notificationsEnabled = false;
        _reminderDays = 2;
        _exportFormat = 'CSV';
      });

      // 保存默认设置
      await _saveSettings();

      if (mounted) {
        _showAlert(
          context,
          '清除成功',
          '所有数据已被清除',
        );
      }
    } catch (e) {
      if (mounted) {
        _showAlert(
          context,
          '清除失败',
          '清除数据时发生错误：${e.toString()}',
        );
      }
    }
  }

  // 获取经期数据的辅助方法
  Future<List<Map<String, dynamic>>> _getPeriodData() async {
    final records = _periodService.getAllRecords();
    return records
        .map((record) => {
              'date': record.startDate.toIso8601String(),
              'end_date': record.endDate?.toIso8601String(),
              'flow': _getFlowString(record.flow),
              'symptoms': record.symptoms.entries
                  .where((e) => e.value)
                  .map((e) => e.key)
                  .toList(),
              'mood': record.mood.entries
                  .where((e) => e.value)
                  .map((e) => e.key)
                  .toList(),
              'notes': record.notes,
            })
        .toList();
  }

  String _getFlowString(int flow) {
    switch (flow) {
      case 1:
        return '较轻';
      case 2:
        return '中等';
      case 3:
        return '较重';
      case 4:
        return '很重';
      default:
        return '未知';
    }
  }

  int _getFlowValue(String flow) {
    switch (flow) {
      case '较轻':
        return 1;
      case '中等':
        return 2;
      case '较重':
        return 3;
      case '很重':
        return 4;
      default:
        return 1;
    }
  }

  // 显示提示对话框
  void _showAlert(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://your-website.com/privacy-policy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _openTermsOfService() async {
    const url = 'https://your-website.com/terms-of-service';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('设置'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // 通知设置组
            _buildSettingsGroup(
              '通知设置',
              [
                _buildSwitchItem(
                  '启用通知',
                  _notificationsEnabled,
                  _toggleNotifications,
                ),
                if (_notificationsEnabled)
                  _buildPickerItem(
                    '提前提醒天数',
                    '$_reminderDays 天',
                    _showDaysPicker,
                  ),
              ],
            ),
            // 数据管理设置组
            _buildSettingsGroup(
              '数据管理',
              [
                _buildPickerItem(
                  '导出格式',
                  _exportFormat,
                  _showFormatPicker,
                ),
                _buildNavigationItem(
                  '导出数据',
                  onTap: () {
                    _exportData();
                  },
                ),
                _buildNavigationItem(
                  '备份与恢复',
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        actions: <CupertinoActionSheetAction>[
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              _backupData();
                            },
                            child: const Text('创建备份'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              _restoreData();
                            },
                            child: const Text('从备份恢复'),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('取消'),
                        ),
                      ),
                    );
                  },
                ),
                _buildDestructiveItem(
                  '清除所有数据',
                  onTap: () {
                    _clearAllData();
                  },
                ),
              ],
            ),
            // 关于设置组
            _buildSettingsGroup(
              '关于',
              [
                _buildNavigationItem(
                  '隐私政策',
                  onTap: () {
                    _openPrivacyPolicy();
                  },
                ),
                _buildNavigationItem(
                  '使用条款',
                  onTap: () {
                    _openTermsOfService();
                  },
                ),
                _buildVersionItem('1.0.0'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建设置组
  Widget _buildSettingsGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CupertinoColors.systemGrey5),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  // 构建导航项
  Widget _buildNavigationItem(String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(
              CupertinoIcons.right_chevron,
              color: CupertinoColors.systemGrey3,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // 构建开关项
  Widget _buildSwitchItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: CupertinoColors.systemPink,
          ),
        ],
      ),
    );
  }

  // 构建选择器项
  Widget _buildPickerItem(
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.right_chevron,
                  color: CupertinoColors.systemGrey3,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建破坏性操作项
  Widget _buildDestructiveItem(String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        _showDeleteConfirmation();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: CupertinoColors.destructiveRed,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建版本信息项
  Widget _buildVersionItem(String version) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '版本',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            version,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 显示天数选择器
  void _showDaysPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                _reminderDays = index + 1;
              });
              _saveSettings();
            },
            children: List<Widget>.generate(7, (int index) {
              return Center(
                child: Text('${index + 1}天'),
              );
            }),
          ),
        ),
      ),
    );
  }

  // 显示格式选择器
  void _showFormatPicker() {
    final formats = ['CSV', 'PDF', 'JSON'];
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                _exportFormat = formats[index];
              });
              _saveSettings();
            },
            children:
                formats.map((format) => Center(child: Text(format))).toList(),
          ),
        ),
      ),
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('确认删除'),
        content: const Text('此操作将清除所有数据且无法恢复，是否继续？'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              _clearAllData();
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}

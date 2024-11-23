// 设置页面组件
import 'package:flutter/cupertino.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// 设置页面状态
class _SettingsPageState extends State<SettingsPage> {
  // 通知开关状态
  bool _notificationsEnabled = true;
  // 提前提醒天数
  int _reminderDays = 2;
  // 导出格式选择
  String _exportFormat = 'CSV';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('设置'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // 个人信息设置组
            _buildSettingsGroup(
              '个人信息',
              [
                _buildNavigationItem(
                  '个人资料',
                  onTap: () {
                    // TODO: 导航到个人资料页面
                  },
                ),
                _buildNavigationItem(
                  '周期设置',
                  onTap: () {
                    // TODO: 导航到周期设置页面
                  },
                ),
              ],
            ),
            // 通知设置组
            _buildSettingsGroup(
              '通知设置',
              [
                _buildSwitchItem(
                  '启用通知',
                  _notificationsEnabled,
                  (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                if (_notificationsEnabled)
                  _buildPickerItem(
                    '提前提醒天数',
                    _reminderDays.toString(),
                    () {
                      _showDaysPicker();
                    },
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
                  () {
                    _showFormatPicker();
                  },
                ),
                _buildNavigationItem(
                  '导出数据',
                  onTap: () {
                    // TODO: 实现数据导出功能
                  },
                ),
                _buildNavigationItem(
                  '备份与恢复',
                  onTap: () {
                    // TODO: 导航到备份恢复页面
                  },
                ),
                _buildDestructiveItem(
                  '清除所有数据',
                  onTap: () {
                    _showDeleteConfirmation();
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
                    // TODO: 显示隐私政策
                  },
                ),
                _buildNavigationItem(
                  '使用条款',
                  onTap: () {
                    // TODO: 显示使用条款
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            border: Border(
              top: BorderSide(color: CupertinoColors.systemGrey5),
              bottom: BorderSide(color: CupertinoColors.systemGrey5),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.systemGrey5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            const Icon(
              CupertinoIcons.right_chevron,
              color: CupertinoColors.systemGrey3,
              size: 20,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.systemGrey5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.right_chevron,
                  color: CupertinoColors.systemGrey3,
                  size: 20,
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
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.systemGrey5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: CupertinoColors.destructiveRed,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('版本'),
          Text(
            version,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
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
            },
            children: formats
                .map((format) => Center(child: Text(format)))
                .toList(),
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
              // TODO: 实现数据清除功能
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

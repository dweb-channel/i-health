import 'package:flutter/cupertino.dart';

// 记录页面组件
class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  // 选中的日期
  DateTime _selectedDate = DateTime.now();
  // 选中的经期强度
  String _selectedFlow = '中等';
  // 选中的症状列表
  final List<String> _selectedSymptoms = [];
  // 选中的心情
  String _selectedMood = '平静';
  // 备注文本控制器
  final TextEditingController _notesController = TextEditingController();

  // 经期强度选项
  final List<String> _flowOptions = ['很少', '轻微', '中等', '较多', '很多'];
  // 症状选项
  final List<String> _symptomOptions = [
    '腹痛',
    '头痛',
    '乳房胀痛',
    '疲劳',
    '情绪波动',
    '食欲改变',
    '失眠',
    '痤疮',
    '便秘'
  ];
  // 心情选项
  final List<String> _moodOptions = ['平静', '开心', '焦虑', '疲惫', '烦躁', '沮丧'];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('记录'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 日期选择器
            _buildDatePicker(),
            const SizedBox(height: 20),
            // 经期强度选择器
            _buildFlowSelector(),
            const SizedBox(height: 20),
            // 症状多选器
            _buildSymptomSelector(),
            const SizedBox(height: 20),
            // 心情选择器
            _buildMoodSelector(),
            const SizedBox(height: 20),
            // 备注输入框
            _buildNotesInput(),
            const SizedBox(height: 30),
            // 保存按钮
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // 构建日期选择器
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('日期', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _selectedDate,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _selectedDate = newDate;
              });
            },
          ),
        ),
      ],
    );
  }

  // 构建经期强度选择器
  Widget _buildFlowSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('经期量', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoSlidingSegmentedControl<String>(
            groupValue: _selectedFlow,
            children: {
              for (var flow in _flowOptions) flow: Text(flow),
            },
            onValueChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedFlow = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  // 构建症状多选器
  Widget _buildSymptomSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('症状', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _symptomOptions.map((symptom) {
            final isSelected = _selectedSymptoms.contains(symptom);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSymptoms.remove(symptom);
                  } else {
                    _selectedSymptoms.add(symptom);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? CupertinoColors.systemPink : CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CupertinoColors.systemPink,
                  ),
                ),
                child: Text(
                  symptom,
                  style: TextStyle(
                    color: isSelected ? CupertinoColors.white : CupertinoColors.systemPink,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 构建心情选择器
  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('心情', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoSlidingSegmentedControl<String>(
            groupValue: _selectedMood,
            children: {
              for (var mood in _moodOptions) mood: Text(mood),
            },
            onValueChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedMood = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  // 构建备注输入框
  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('备注', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoTextField(
            controller: _notesController,
            placeholder: '添加备注...',
            padding: const EdgeInsets.all(12),
            maxLines: 4,
          ),
        ),
      ],
    );
  }

  // 构建保存按钮
  Widget _buildSaveButton() {
    return CupertinoButton.filled(
      onPressed: () {
        // TODO: 保存记录到数据库
        // 显示保存成功提示
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('成功'),
            content: const Text('记录已保存'),
            actions: [
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      child: const Text('保存'),
    );
  }
}

import 'package:flutter/cupertino.dart';

// 日历页面组件
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // 当前选中的日期
  DateTime _selectedDate = DateTime.now();
  // 今天的日期
  final DateTime _today = DateTime.now();
  // 经期日期列表
  final List<DateTime> _periodDays = [
    DateTime.now().subtract(const Duration(days: 3)),
    DateTime.now().subtract(const Duration(days: 2)),
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now(),
    DateTime.now().add(const Duration(days: 1)),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('日历'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 月份选择器
            _buildMonthSelector(),
            Expanded(
              child: ListView(
                children: [
                  // 自定义日历视图
                  _buildCalendar(),
                  const SizedBox(height: 20),
                  // 图例说明
                  _buildLegend(),
                  const SizedBox(height: 20),
                  // 预测卡片
                  _buildNextPeriodCard(),
                  const SizedBox(height: 20),
                  if (_isPeriodDay(_selectedDate)) _buildPeriodDetails(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建月份选择器
  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: CupertinoColors.systemBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 上个月按钮
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.left_chevron),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                  _selectedDate.day,
                );
              });
            },
          ),
          // 显示当前月份和年份
          Text(
            '${_selectedDate.year}年${_selectedDate.month}月',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          // 下个月按钮
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.right_chevron),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                  _selectedDate.day,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  // 构建日历视图
  Widget _buildCalendar() {
    // 计算当月天数
    final daysInMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    ).day;
    // 计算当月第一天是星期几
    final firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 星期标签行
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _WeekdayLabel('一'),
                _WeekdayLabel('二'),
                _WeekdayLabel('三'),
                _WeekdayLabel('四'),
                _WeekdayLabel('五'),
                _WeekdayLabel('六'),
                _WeekdayLabel('日'),
              ],
            ),
          ),
          // 日期网格
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            children: List.generate(42, (index) {
              final int day = index - firstWeekday + 2;
              if (day < 1 || day > daysInMonth) {
                return const SizedBox();
              }
              final date =
                  DateTime(_selectedDate.year, _selectedDate.month, day);
              return _CalendarDay(
                date: date,
                isSelected: date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day,
                isToday: date.year == _today.year &&
                    date.month == _today.month &&
                    date.day == _today.day,
                isPeriodDay: _isPeriodDay(date),
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // 构建图例说明
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(
            color: CupertinoColors.systemPink.withOpacity(0.2),
            label: '经期',
            borderColor: CupertinoColors.systemPink,
          ),
          const SizedBox(width: 16),
          const _LegendItem(
            color: CupertinoColors.systemGrey5,
            label: '预测经期',
            borderColor: CupertinoColors.systemPink,
            borderStyle: BorderStyle.solid,
          ),
        ],
      ),
    );
  }

  // 构建预测卡片
  Widget _buildNextPeriodCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '下次经期预测',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '预计开始日期：2024年2月15日',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '距离下次经期还有14天',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  // 构建经期详情
  Widget _buildPeriodDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedDate.month}月${_selectedDate.day}日记录',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const _DetailItem(label: '经期量', value: '中等'),
          const _DetailItem(label: '症状', value: '腹痛、头痛'),
          const _DetailItem(label: '心情', value: '平静'),
          const _DetailItem(label: '备注', value: '今天感觉还不错'),
        ],
      ),
    );
  }

  // 判断是否为经期日
  bool _isPeriodDay(DateTime date) {
    return _periodDays.any((periodDay) =>
        periodDay.year == date.year &&
        periodDay.month == date.month &&
        periodDay.day == date.day);
  }
}

// 星期标签组件
class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// 日历天组件
class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isPeriodDay,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isPeriodDay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemPink
              : isPeriodDay
                  ? CupertinoColors.systemPink.withOpacity(0.2)
                  : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(
                  color: CupertinoColors.systemPink,
                  width: 2,
                )
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: isSelected
                  ? CupertinoColors.white
                  : isPeriodDay
                      ? CupertinoColors.systemPink
                      : null,
              fontWeight:
                  isSelected || isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// 图例项组件
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.borderColor,
    this.borderStyle = BorderStyle.solid,
  });

  final Color color;
  final String label;
  final Color borderColor;
  final BorderStyle borderStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: borderColor,
              style: borderStyle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// 经期详情项组件
class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

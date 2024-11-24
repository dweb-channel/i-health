import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pages/calendar_page.dart';
import 'pages/insights_page.dart';
import 'pages/log_page.dart';
import 'pages/settings_page.dart';
import 'services/navigation_service.dart';

// 应用程序入口
void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化Hive数据库
  await Hive.initFlutter();
  runApp(const MyApp());
}

// 通知插件实例
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 应用程序根组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: '经期追踪',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemPink, // 主题色为粉色
        brightness: Brightness.light, // 亮色主题
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
      ),
      home: HomePage(),
    );
  }
}

// 主页面（包含底部导航栏）
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 当前选中的底部导航项索引
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 设置导航服务的context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService().setContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      // 底部导航栏配置
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: '日历',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.plus_circle),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.graph_circle),
            label: '分析',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: '设置',
          ),
        ],
        currentIndex: _selectedIndex,
        activeColor: CupertinoColors.systemPink, // 选中项的颜色
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      // 根据选中的索引返回对应的页面
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const CalendarPage(); // 日历页面
          case 1:
            return const LogPage(); // 记录页面
          case 2:
            return const InsightsPage(); // 分析页面
          case 3:
            return const SettingsPage(); // 设置页面
          default:
            return const CalendarPage();
        }
      },
    );
  }
}

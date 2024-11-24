import 'package:flutter/widgets.dart';

/// 导航服务类 - 处理应用的所有导航功能
class NavigationService {
  // 单例模式实现
  static final NavigationService _instance = NavigationService._();
  factory NavigationService() => _instance;
  NavigationService._();

  // 存储导航上下文
  BuildContext? _context;

  // 设置上下文
  void setContext(BuildContext context) {
    _context = context;
  }

  // 导航到主页
  void navigateToHome() {
    if (_context != null) {
      Navigator.of(_context!, rootNavigator: true)
          .pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  // 获取当前context
  BuildContext? get currentContext => _context;
}

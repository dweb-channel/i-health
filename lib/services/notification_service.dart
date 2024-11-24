import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'navigation_service.dart';

/// 通知服务类 - 处理应用的所有本地通知功能
/// 使用单例模式确保整个应用只有一个通知服务实例
class NotificationService {
  // 单例模式实现
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  // 通知插件实例
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 初始化通知服务
  /// - 设置时区
  /// - 配置通知渠道
  Future<void> init() async {
    // 初始化时区数据，用于准确调度通知
    tz.initializeTimeZones();

    // 配置 Android 通知设置
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 配置 iOS 通知设置
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // 组合平台特定的设置
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 初始化通知插件
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 使用导航服务进行导航
        NavigationService().navigateToHome();
      },
    );
  }

  /// 安排经期提醒通知
  /// [nextPeriod] 下一次经期的预计日期
  /// [daysInAdvance] 提前提醒的天数
  Future<void> schedulePeriodNotification(
      DateTime nextPeriod, int daysInAdvance) async {
    // 计算通知时间
    final notificationTime = nextPeriod.subtract(Duration(days: daysInAdvance));

    // 如果通知时间已经过去，就不安排通知
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    // Android 通知详情配置
    const androidDetails = AndroidNotificationDetails(
      'period_channel', // 渠道ID
      '经期提醒', // 渠道名称
      channelDescription: '经期提醒通知', // 渠道描述
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    // iOS 通知详情配置
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true, // 显示通知横幅
      presentBadge: true, // 显示应用角标
      presentSound: true, // 播放通知声音
    );

    // 组合通知详情
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 安排通知
    await _notificationsPlugin.zonedSchedule(
      0, // 通知ID
      '经期提醒', // 通知标题
      '您的下一次经期预计将在 $daysInAdvance 天后开始', // 通知内容
      tz.TZDateTime.from(notificationTime, tz.local), // 通知时间
      notificationDetails,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // 允许在低电量模式下发送通知
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime, // 使用绝对时间
    );
  }

  /// 取消所有已安排的通知
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// 请求通知权限
  /// 返回 true 如果用户授予权限，false 如果用户拒绝或发生错误
  Future<bool> requestNotificationPermissions() async {
    final platform = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      final result = await platform.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    return false;
  }

  /// 检查通知权限状态
  /// 返回 true 如果有权限，false 如果没有权限
  Future<bool> checkNotificationPermissions() async {
    final bool? granted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return granted ?? false;
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/constants/app_constants.dart';

/// 本地通知服务 —— 对应 H5 的 Web Notifications。
/// 关键差异：iOS WKWebView / Android WebView 不支持 Web Notifications，
/// 因此用原生本地通知，并在每次计时**开始时调度定点通知**，
/// 即使 App 被系统回收或切后台，到点也能准时响铃提醒。
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  /// Android 13+ 运行时权限。
  ///
  /// 只申请通知权限。**不**在这里申请精确闹钟权限——那个会直接跳到系统设置页，
  /// 每次冷启动都打断用户。精确闹钟改为调度时静默降级（见 [scheduleAt]）。
  Future<void> requestPermission() async {
    final impl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await impl?.requestNotificationsPermission();
  }

  /// 立即显示一条通知（前台完成时）。
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF7FFFD4),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  /// 调度定点通知（番茄/休息结束时触发）。
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    final scheduled =
        tz.TZDateTime.now(tz.local).add(when.difference(DateTime.now()));
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF7FFFD4),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = const NotificationDetails(android: androidDetails, iOS: iosDetails);
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // 未授予「精确闹钟」权限时，退化为非精确调度，避免抛异常导致计时开始失败。
      // 应用在前台时仍会立刻 showNow，后台提醒可能略有延迟。
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

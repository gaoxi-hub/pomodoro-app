/// 应用级常量与默认值。
class AppConstants {
  AppConstants._();

  static const String appName = '番茄钟';

  /// 本地通知渠道（Android 必要）
  static const String notificationChannelId = 'pomodoro_timer';
  static const String notificationChannelName = '番茄钟提醒';
  static const String notificationChannelDescription =
      '专注结束 / 休息结束的本地提醒';

  /// 通知 id（保持固定，便于更新/取消）
  static const int notificationIdWorkEnd = 1001;
  static const int notificationIdBreakEnd = 1002;
  static const int notificationIdEyeCare = 1003;

  /// 默认每日目标番茄数
  static const int defaultDailyGoal = 8;

  /// 默认计时（分钟）
  static const int defaultWorkMin = 25;
  static const int defaultShortMin = 5;
  static const int defaultLongMin = 15;
  static const int defaultLongBreakInterval = 4;

  /// 护眼提醒间隔（毫秒）
  static const int eyeCareIntervalMs = 20 * 60 * 1000;
}

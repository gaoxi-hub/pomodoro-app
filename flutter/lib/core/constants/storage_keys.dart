/// 本地存储键 —— 全项目统一前缀 `pomodoro:`，与原 H5 契约一致。
class StorageKeys {
  StorageKeys._();

  static const String prefix = 'pomodoro:';
  static const String tasks = '${prefix}tasks';
  static const String sessions = '${prefix}sessions';
  static const String settings = '${prefix}settings';
  static const String currentTaskId = '${prefix}currentTaskId';
  static const String goal = '${prefix}goal';
  static const String achievements = '${prefix}achievements';
}

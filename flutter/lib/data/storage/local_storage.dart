import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储封装 —— 对应 H5 的 useStorage（localStorage）。
/// 所有键统一前缀 `pomodoro:`，见 core/constants/storage_keys.dart。
class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
}

import 'dart:convert';
import '../../core/constants/storage_keys.dart';
import '../../core/models/settings.dart';
import '../storage/local_storage.dart';

/// 设置仓储 —— pomodoro:settings
class SettingsRepository {
  final LocalStorage _storage;
  SettingsRepository(this._storage);

  Future<Settings> load() async {
    final raw = _storage.getString(StorageKeys.settings);
    if (raw == null) return Settings.defaults();
    return Settings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(Settings settings) async {
    await _storage.setString(
      StorageKeys.settings,
      jsonEncode(settings.toJson()),
    );
  }
}

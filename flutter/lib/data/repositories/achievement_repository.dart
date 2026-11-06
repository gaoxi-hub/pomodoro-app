import 'dart:convert';
import '../../core/constants/storage_keys.dart';
import '../storage/local_storage.dart';

/// 成就仓储 —— pomodoro:achievements → String[]（已解锁 id）
class AchievementRepository {
  final LocalStorage _storage;
  AchievementRepository(this._storage);

  Future<List<String>> load() async {
    final raw = _storage.getString(StorageKeys.achievements);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => e as String).toList();
  }

  Future<void> save(List<String> ids) async {
    await _storage.setString(StorageKeys.achievements, jsonEncode(ids));
  }
}

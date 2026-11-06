import 'dart:convert';
import '../../core/constants/storage_keys.dart';
import '../../core/models/goal.dart';
import '../storage/local_storage.dart';

/// 目标仓储 —— pomodoro:goal
class GoalRepository {
  final LocalStorage _storage;
  GoalRepository(this._storage);

  Future<Goal> load() async {
    final raw = _storage.getString(StorageKeys.goal);
    if (raw == null) return const Goal();
    return Goal.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(Goal goal) async {
    await _storage.setString(StorageKeys.goal, jsonEncode(goal.toJson()));
  }
}

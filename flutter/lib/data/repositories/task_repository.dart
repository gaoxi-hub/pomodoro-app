import 'dart:convert';
import '../../core/constants/storage_keys.dart';
import '../../core/models/task.dart';
import '../storage/local_storage.dart';

/// 任务仓储 —— pomodoro:tasks → Task[]
class TaskRepository {
  final LocalStorage _storage;
  TaskRepository(this._storage);

  Future<List<Task>> load() async {
    final raw = _storage.getString(StorageKeys.tasks);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<Task> tasks) async {
    final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _storage.setString(StorageKeys.tasks, raw);
  }
}

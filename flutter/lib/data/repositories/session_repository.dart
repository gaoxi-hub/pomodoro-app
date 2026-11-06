import 'dart:convert';
import '../../core/constants/storage_keys.dart';
import '../../core/models/pomodoro_session.dart';
import '../storage/local_storage.dart';

/// 会话仓储 —— pomodoro:sessions → PomodoroSession[]
class SessionRepository {
  final LocalStorage _storage;
  SessionRepository(this._storage);

  Future<List<PomodoroSession>> load() async {
    final raw = _storage.getString(StorageKeys.sessions);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PomodoroSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<PomodoroSession> sessions) async {
    final raw = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _storage.setString(StorageKeys.sessions, raw);
  }

  /// 追加一条会话并持久化。
  Future<List<PomodoroSession>> add(PomodoroSession session) async {
    final all = await load();
    all.add(session);
    await save(all);
    return all;
  }
}

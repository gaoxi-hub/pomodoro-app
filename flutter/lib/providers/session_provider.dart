import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/pomodoro_session.dart';
import '../data/repositories/session_repository.dart';
import 'storage_providers.dart';

final sessionProvider = AsyncNotifierProvider<SessionNotifier,
    List<PomodoroSession>>(SessionNotifier.new);

class SessionNotifier extends AsyncNotifier<List<PomodoroSession>> {
  SessionRepository get _repo => ref.read(sessionRepoProvider);

  @override
  Future<List<PomodoroSession>> build() => _repo.load();

  Future<void> add(PomodoroSession s) async {
    final all = [...state.requireValue, s];
    await _repo.save(all);
    state = AsyncData(all);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/goal.dart';
import '../data/repositories/goal_repository.dart';
import 'storage_providers.dart';

final goalProvider = AsyncNotifierProvider<GoalNotifier, Goal>(GoalNotifier.new);

class GoalNotifier extends AsyncNotifier<Goal> {
  GoalRepository get _repo => ref.read(goalRepoProvider);

  @override
  Future<Goal> build() => _repo.load();

  Future<void> setDaily(int value) async {
    final next = Goal(dailyPomodoros: value.clamp(1, 30));
    await _repo.save(next);
    state = AsyncData(next);
  }
}

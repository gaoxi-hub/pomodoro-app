import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/achievement.dart';
import '../core/models/achievement_definitions.dart';
import '../data/repositories/achievement_repository.dart';
import 'stats_provider.dart';
import 'storage_providers.dart';

final achievementsProvider =
    AsyncNotifierProvider<AchievementsNotifier, List<AchievementView>>(
        AchievementsNotifier.new);

class AchievementsNotifier extends AsyncNotifier<List<AchievementView>> {
  AchievementRepository get _repo => ref.read(achievementRepoProvider);

  @override
  Future<List<AchievementView>> build() async {
    final unlocked = await _repo.load();
    final stats = ref.watch(statsProvider);
    return _views(unlocked, stats);
  }

  List<AchievementView> _views(List<String> unlocked, StatsData stats) {
    return achievementDefs
        .map((d) => AchievementView(
              def: d,
              unlocked: unlocked.contains(d.id),
            ))
        .toList();
  }

  /// 每次番茄完成/每日首次时评估规则，解锁则持久化并刷新状态。
  Future<void> evaluate() async {
    final stats = ref.read(statsProvider);
    final unlocked = await _repo.load();
    final newly = [...unlocked];
    for (final d in achievementDefs) {
      if (!newly.contains(d.id) &&
          d.rule(stats.streak, stats.totalPomodoros, stats.maxDayPomodoros)) {
        newly.add(d.id);
      }
    }
    if (newly.length != unlocked.length) {
      await _repo.save(newly);
      state = AsyncData(_views(newly, stats));
    }
  }
}

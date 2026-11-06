import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/settings.dart';
import '../data/repositories/settings_repository.dart';
import 'storage_providers.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<Settings> {
  SettingsRepository get _repo => ref.read(settingsRepoProvider);

  @override
  Future<Settings> build() => _repo.load();

  Future<void> _save(Settings s) async {
    // 仅做持久化；状态通知由 patch 同步完成，避免 await 之后通知已 dispose 的 widget。
    await _repo.save(s);
  }

  Future<void> patch({
    int? workMin,
    int? shortMin,
    int? longMin,
    int? longBreakInterval,
    bool? autoStartNext,
    bool? breakEndNotify,
    bool? celebrate,
    bool? soundOn,
    NoiseConfig? noise,
  }) async {
    final cur = state.requireValue;
    final next = cur.copyWith(
      workMin: workMin,
      shortMin: shortMin,
      longMin: longMin,
      longBreakInterval: longBreakInterval,
      autoStartNext: autoStartNext,
      breakEndNotify: breakEndNotify,
      celebrate: celebrate,
      soundOn: soundOn,
      noise: noise,
    );
    // 关键：先同步更新内存状态（此时监听的 widget 仍存活），再异步落盘。
    state = AsyncData(next);
    try {
      await _save(next);
    } catch (e) {
      // 持久化失败不影响内存状态，记日志即可。
      // ignore: avoid_print
      print('settings save failed: $e');
    }
  }

  Future<void> toggleSound() => patch(soundOn: !state.requireValue.soundOn);
  Future<void> toggleAutoStart() =>
      patch(autoStartNext: !state.requireValue.autoStartNext);
  Future<void> toggleCelebrate() =>
      patch(celebrate: !state.requireValue.celebrate);
}

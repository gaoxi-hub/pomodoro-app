import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/storage_keys.dart';
import '../data/storage/local_storage.dart';
import '../data/repositories/task_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/goal_repository.dart';
import '../data/repositories/achievement_repository.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';

/// 本地存储（异步初始化，应用启动时 await）。
final localStorageProvider = FutureProvider<LocalStorage>((ref) async {
  return LocalStorage.init();
});

final taskRepoProvider =
    Provider((ref) => TaskRepository(ref.watch(localStorageProvider).requireValue));
final sessionRepoProvider = Provider(
    (ref) => SessionRepository(ref.watch(localStorageProvider).requireValue));
final settingsRepoProvider = Provider(
    (ref) => SettingsRepository(ref.watch(localStorageProvider).requireValue));
final goalRepoProvider =
    Provider((ref) => GoalRepository(ref.watch(localStorageProvider).requireValue));
final achievementRepoProvider = Provider(
    (ref) => AchievementRepository(ref.watch(localStorageProvider).requireValue));

/// 提示音 / 白噪音服务（应用生命周期单例）。
final audioServiceProvider = Provider<AudioService>((ref) {
  final a = AudioService();
  ref.onDispose(a.dispose);
  return a;
});

/// 本地通知服务。
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

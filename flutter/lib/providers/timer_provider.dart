import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/models/pomodoro_session.dart';
import '../core/models/settings.dart';
import '../core/utils/id_utils.dart';
import '../services/timer_service.dart';
import 'achievements_provider.dart';
import 'session_provider.dart';
import 'settings_provider.dart';
import 'storage_providers.dart';
import 'tasks_provider.dart';

/// 计时引擎：ChangeNotifier，UI 通过 watch 获得实时剩余/进度。
final timerServiceProvider = ChangeNotifierProvider<TimerService>((ref) {
  return TimerService(
    getDurationSec: (mode) {
      final s = ref.read(settingsProvider).valueOrNull ?? Settings.defaults();
      return switch (mode) {
        TimerMode.work => s.workMin * 60,
        TimerMode.short => s.shortMin * 60,
        TimerMode.long => s.longMin * 60,
      };
    },
  );
});

/// 计时控制器：把"完成"事件串起 记录会话 / 计数 / 反馈 / 通知 / 模式切换。
final timerControllerProvider = Provider<TimerController>((ref) {
  final c = TimerController(ref);
  ref.read(timerServiceProvider).onComplete = (m) => c.handleComplete(m);
  ref.onDispose(() {
    ref.read(timerServiceProvider).onComplete = (_) {};
  });
  return c;
});

PomodoroType _typeOf(TimerMode m) => switch (m) {
      TimerMode.work => PomodoroType.work,
      TimerMode.short => PomodoroType.short,
      TimerMode.long => PomodoroType.long,
    };

class TimerController {
  final Ref ref;
  int _workSinceLongBreak = 0;

  TimerController(this.ref);

  TimerService get svc => ref.read(timerServiceProvider);

  /// 开始时原生调度定点通知（解决后台/被杀提醒缺口）。
  void _scheduleEnd() {
    final notif = ref.read(notificationServiceProvider);
    final when = DateTime.now().add(Duration(seconds: svc.remainingSec));
    if (svc.mode == TimerMode.work) {
      notif.scheduleAt(
        id: AppConstants.notificationIdWorkEnd,
        title: '专注完成',
        body: '该休息一下啦 🌿',
        when: when,
      );
    } else {
      notif.scheduleAt(
        id: AppConstants.notificationIdBreakEnd,
        title: '休息结束',
        body: '继续专注吧 💎',
        when: when,
      );
    }
  }

  void start() {
    svc.start();
    _scheduleEnd();
    _applyNoise();
  }

  void pause() {
    svc.pause();
    final notif = ref.read(notificationServiceProvider);
    notif.cancel(AppConstants.notificationIdWorkEnd);
    notif.cancel(AppConstants.notificationIdBreakEnd);
    ref.read(audioServiceProvider).stopNoise();
  }

  void reset() {
    svc.reset();
    ref.read(notificationServiceProvider).cancelAll();
    ref.read(audioServiceProvider).stopNoise();
  }

  void selectMode(TimerMode mode) {
    svc.setMode(mode);
  }

  /// 一个番茄/休息自然结束时的统一处理。
  void handleComplete(TimerMode finished) {
    final settings =
        ref.read(settingsProvider).valueOrNull ?? Settings.defaults();
    final tasks = ref.read(tasksProvider).valueOrNull;
    final completed = finished == TimerMode.work;
    final now = DateTime.now().millisecondsSinceEpoch;

    final session = PomodoroSession(
      id: uid(),
      taskId: tasks?.currentTaskId,
      type: _typeOf(finished),
      startedAt: svc.startAt ?? now - svc.totalSec * 1000,
      endedAt: now,
      plannedMin: (svc.totalSec / 60).round(),
      completed: true,
    );
    ref.read(sessionProvider.notifier).add(session);

    if (completed && tasks?.currentTaskId != null) {
      ref
          .read(tasksProvider.notifier)
          .incrementDone(tasks!.currentTaskId!);
    }

    if (settings.soundOn) ref.read(audioServiceProvider).playDing();
    HapticFeedback.mediumImpact();
    ref.read(achievementsProvider.notifier).evaluate();

    final notif = ref.read(notificationServiceProvider);
    notif.cancel(AppConstants.notificationIdWorkEnd);
    notif.cancel(AppConstants.notificationIdBreakEnd);

    if (completed) {
      _workSinceLongBreak++;
      final isLong = _workSinceLongBreak >= settings.longBreakInterval;
      if (isLong) _workSinceLongBreak = 0;
      notif.showNow(
        id: AppConstants.notificationIdWorkEnd,
        title: '专注完成 🎉',
        body: isLong ? '完成一轮，该长休息一下啦' : '太棒了，该休息一下啦 🌿',
      );
      ref.read(audioServiceProvider).stopNoise();
      svc.setMode(isLong ? TimerMode.long : TimerMode.short);
    } else {
      notif.showNow(
        id: AppConstants.notificationIdBreakEnd,
        title: '休息结束',
        body: '继续专注吧 💎',
      );
      svc.setMode(TimerMode.work);
    }

    if (settings.autoStartNext) {
      svc.start();
      _scheduleEnd();
      _applyNoise();
    }
  }

  /// 按设置播放/停止白噪音（仅专注模式播放）。
  void _applyNoise() {
    final settings =
        ref.read(settingsProvider).valueOrNull ?? Settings.defaults();
    final sound = settings.noise.activeSound;
    if (sound != null && svc.mode == TimerMode.work) {
      ref
          .read(audioServiceProvider)
          .playNoise(sound, volume: settings.noise.activeVolume);
    } else {
      ref.read(audioServiceProvider).stopNoise();
    }
  }
}

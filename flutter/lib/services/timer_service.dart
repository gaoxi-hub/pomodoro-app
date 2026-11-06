import 'dart:async';
import 'package:flutter/foundation.dart';

/// 计时模式。
enum TimerMode { work, short, long }

/// 计时状态。
enum TimerStatus { idle, running, paused }

/// 计时引擎 —— 基于时间戳（记录目标结束时间，按 Date.now 计算剩余）。
/// 禁止 setInterval 累加秒数，挂起/切后台回来不漂移。
/// 通过 ChangeNotifier 暴露状态，由 timer_provider 持有并接 Riverpod。
class TimerService with ChangeNotifier {
  TimerMode _mode;
  TimerStatus _status = TimerStatus.idle;
  int _totalSec;
  int _remainingSec;
  int? _endAt; // epoch ms
  int? _startAt; // epoch ms（用于统计 startedAt）
  Timer? _ticker;

  /// 根据模式返回时长（秒）。
  final int Function(TimerMode) getDurationSec;

  /// 倒计时归零时回调（参数为刚结束的模式）。由 TimerController 注入，避免循环依赖。
  void Function(TimerMode) onComplete = (_) {};

  TimerService({
    required this.getDurationSec,
    TimerMode initialMode = TimerMode.work,
  })  : _mode = initialMode,
        _totalSec = getDurationSec(initialMode),
        _remainingSec = getDurationSec(initialMode);

  TimerMode get mode => _mode;
  TimerStatus get status => _status;
  int get totalSec => _totalSec;
  int get remainingSec => _remainingSec;
  int? get startAt => _startAt;

  double get progress =>
      _totalSec <= 0 ? 0.0 : (1 - _remainingSec / _totalSec).clamp(0.0, 1.0);

  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isIdle => _status == TimerStatus.idle;
  bool get isBreak => _mode != TimerMode.work;

  void _computeRemaining() {
    if (_endAt != null) {
      final left =
          (_endAt! - DateTime.now().millisecondsSinceEpoch + 999) ~/ 1000;
      _remainingSec = left < 0 ? 0 : left;
    }
  }

  void _tick(Timer _) {
    _computeRemaining();
    if (_remainingSec <= 0) {
      _complete();
    } else {
      notifyListeners();
    }
  }

  /// 开始 / 继续。
  void start() {
    if (_status == TimerStatus.running) return;
    _startAt ??= DateTime.now().millisecondsSinceEpoch;
    _status = TimerStatus.running;
    _endAt =
        DateTime.now().millisecondsSinceEpoch + _remainingSec * 1000;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), _tick);
    notifyListeners();
  }

  void pause() {
    if (_status != TimerStatus.running) return;
    _computeRemaining();
    _ticker?.cancel();
    _ticker = null;
    _endAt = null;
    _status = TimerStatus.paused;
    notifyListeners();
  }

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _status = TimerStatus.idle;
    _endAt = null;
    _startAt = null;
    _remainingSec = _totalSec;
    notifyListeners();
  }

  /// 切换模式（停止当前计时并重置剩余）。
  void setMode(TimerMode mode) {
    _ticker?.cancel();
    _ticker = null;
    _mode = mode;
    _totalSec = getDurationSec(mode);
    _remainingSec = _totalSec;
    _endAt = null;
    _startAt = null;
    _status = TimerStatus.idle;
    notifyListeners();
  }

  /// 直接跳到结束（用于"跳过"）。
  void skip() {
    _remainingSec = 0;
    _complete();
  }

  void _complete() {
    _ticker?.cancel();
    _ticker = null;
    _status = TimerStatus.idle;
    _endAt = null;
    _remainingSec = 0;
    notifyListeners();
    onComplete(_mode);
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

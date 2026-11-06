import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/pomodoro_session.dart';
import '../core/utils/time_utils.dart';
import 'session_provider.dart';

class ChartPoint {
  final String label;
  final int value;
  const ChartPoint(this.label, this.value);
}

/// 派生统计（实时，随 session 变化重算）。
class StatsData {
  final int todayPomodoros;
  final int todayFocusMinutes;
  final int streak;
  final int maxDayPomodoros;
  final int totalPomodoros;
  final int score;
  final List<ChartPoint> dayPoints;
  final List<ChartPoint> weekPoints;
  final List<ChartPoint> monthPoints;

  const StatsData({
    this.todayPomodoros = 0,
    this.todayFocusMinutes = 0,
    this.streak = 0,
    this.maxDayPomodoros = 0,
    this.totalPomodoros = 0,
    this.score = 0,
    this.dayPoints = const [],
    this.weekPoints = const [],
    this.monthPoints = const [],
  });
}

final statsProvider = Provider<StatsData>((ref) {
  final sessions =
      ref.watch(sessionProvider).valueOrNull ?? const <PomodoroSession>[];
  return computeStats(sessions);
});

String _weekdayShort(int wd) {
  const m = ['一', '二', '三', '四', '五', '六', '日'];
  return m[(wd - 1) % 7];
}

int _weekStart(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final monday = d.subtract(Duration(days: d.weekday - 1));
  return startOfDay(monday.millisecondsSinceEpoch);
}

int _monthKey(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  return d.year * 100 + d.month;
}

StatsData computeStats(List<PomodoroSession> all) {
  final work = all.where((s) => s.countsAsPomodoro).toList();
  final now = DateTime.now();
  final todayStart = startOfDay(now.millisecondsSinceEpoch);

  int todayP = 0;
  int todayMin = 0;
  final perDay = <int, int>{};
  final perWeek = <int, int>{};
  final perMonth = <int, int>{};
  for (final s in work) {
    if (isToday(s.endedAt)) {
      todayP++;
      todayMin += s.plannedMin;
    }
    final dKey = startOfDay(s.endedAt);
    perDay[dKey] = (perDay[dKey] ?? 0) + 1;
    final wKey = _weekStart(s.endedAt);
    perWeek[wKey] = (perWeek[wKey] ?? 0) + 1;
    final mKey = _monthKey(s.endedAt);
    perMonth[mKey] = (perMonth[mKey] ?? 0) + 1;
  }

  // 连续天数：含今日或昨日向前连续有 ≥1 完成工作 session 的天数
  final daySet = perDay.keys.toSet();
  int streak = 0;
  int cursor = daySet.contains(todayStart)
      ? todayStart
      : (daySet.contains(todayStart - 86400000)
          ? todayStart - 86400000
          : -1);
  if (cursor >= 0) {
    streak = 1;
    int prev = cursor - 86400000;
    while (daySet.contains(prev)) {
      streak++;
      prev -= 86400000;
    }
  }

  final maxDay = perDay.values.isEmpty
      ? 0
      : perDay.values.reduce((a, b) => a > b ? a : b);
  final total = work.length;

  final dayPoints = <ChartPoint>[];
  for (int i = 6; i >= 0; i--) {
    final d = todayStart - i * 86400000;
    dayPoints.add(ChartPoint(
      _weekdayShort(DateTime.fromMillisecondsSinceEpoch(d).weekday),
      perDay[d] ?? 0,
    ));
  }

  final thisWeek = _weekStart(now.millisecondsSinceEpoch);
  final weekPoints = <ChartPoint>[];
  for (int i = 7; i >= 0; i--) {
    final w = thisWeek - i * 7 * 86400000;
    final dt = DateTime.fromMillisecondsSinceEpoch(w);
    weekPoints.add(ChartPoint('${dt.month}/${dt.day}', perWeek[w] ?? 0));
  }

  final monthPoints = <ChartPoint>[];
  for (int i = 11; i >= 0; i--) {
    final dt = DateTime(now.year, now.month - i, 1);
    final mk = dt.year * 100 + dt.month;
    monthPoints.add(ChartPoint('${dt.month}月', perMonth[mk] ?? 0));
  }

  return StatsData(
    todayPomodoros: todayP,
    todayFocusMinutes: todayMin,
    streak: streak,
    maxDayPomodoros: maxDay,
    totalPomodoros: total,
    score: todayP * 10,
    dayPoints: dayPoints,
    weekPoints: weekPoints,
    monthPoints: monthPoints,
  );
}

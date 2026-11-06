/// 时间工具。
/// 计时精度：全部基于时间戳（Date.now / DateTime），禁止累加秒数。

/// 今天的中文日期，如「10月28日 · 周三」。
String formatTodayCN([DateTime? now]) {
  final d = now ?? DateTime.now();
  const week = ['一', '二', '三', '四', '五', '六', '日'];
  return '${d.month}月${d.day}日 · 周${week[d.weekday - 1]}';
}

/// 秒数 → MM:SS。
String formatMMSS(int totalSeconds) {
  final s = totalSeconds < 0 ? 0 : totalSeconds;
  final m = s ~/ 60;
  final sec = s % 60;
  return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
}

/// 分钟数 → 中文时长（用于统计页"专注时长"）。
String formatFocusMinutes(int minutes) {
  if (minutes < 60) return '$minutes 分钟';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h 小时' : '$h 小时 $m 分';
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isToday(int epochMs) => isSameDay(
      DateTime.fromMillisecondsSinceEpoch(epochMs),
      DateTime.now(),
    );

String dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

/// 取某天 0 点的 epoch ms。
int startOfDay(int epochMs) {
  final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
  return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
}

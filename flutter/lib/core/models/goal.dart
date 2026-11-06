/// 每日目标 —— 默认每日 8 个番茄。
class Goal {
  final int dailyPomodoros;

  const Goal({this.dailyPomodoros = 8});

  factory Goal.fromJson(Map<String, dynamic> json) =>
      Goal(dailyPomodoros: (json['dailyPomodoros'] as int?) ?? 8);

  Map<String, dynamic> toJson() => {'dailyPomodoros': dailyPomodoros};

  Goal copyWith({int? dailyPomodoros}) =>
      Goal(dailyPomodoros: dailyPomodoros ?? this.dailyPomodoros);
}

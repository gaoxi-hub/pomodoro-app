/// 番茄会话模型 —— 每次计时记录，统计用。对照 H5 PomodoroSession。
enum PomodoroType { work, short, long }

extension PomodoroTypeX on PomodoroType {
  String get label => switch (this) {
        PomodoroType.work => '专注',
        PomodoroType.short => '短休',
        PomodoroType.long => '长休',
      };

  bool get isBreak => this != PomodoroType.work;
}

class PomodoroSession {
  final String id;
  final String? taskId;
  final PomodoroType type;
  final int startedAt; // epoch ms
  final int endedAt; // epoch ms
  final int plannedMin;
  final bool completed;

  const PomodoroSession({
    required this.id,
    required this.taskId,
    required this.type,
    required this.startedAt,
    required this.endedAt,
    required this.plannedMin,
    required this.completed,
  });

  factory PomodoroSession.fromJson(Map<String, dynamic> json) => PomodoroSession(
        id: json['id'] as String,
        taskId: json['taskId'] as String?,
        type: PomodoroType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => PomodoroType.work,
        ),
        startedAt: json['startedAt'] as int,
        endedAt: json['endedAt'] as int,
        plannedMin: json['plannedMin'] as int,
        completed: json['completed'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'type': type.name,
        'startedAt': startedAt,
        'endedAt': endedAt,
        'plannedMin': plannedMin,
        'completed': completed,
      };

  PomodoroSession copyWith({
    String? taskId,
    int? endedAt,
    bool? completed,
  }) =>
      PomodoroSession(
        id: id,
        taskId: taskId ?? this.taskId,
        type: type,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
        plannedMin: plannedMin,
        completed: completed ?? this.completed,
      );

  /// 是否为有效（完成的工作）番茄，用于统计口径。
  bool get countsAsPomodoro => type == PomodoroType.work && completed;
}

/// 任务模型 —— 对照 H5 types/index.ts 的 Task。
class Task {
  final String id;
  final String name;
  final int estimate; // >= 1
  final int done;
  final int createdAt; // epoch ms
  final bool? archived;

  const Task({
    required this.id,
    required this.name,
    required this.estimate,
    this.done = 0,
    required this.createdAt,
    this.archived,
  });

  factory Task.create({
    required String id,
    required String name,
    required int estimate,
  }) =>
      Task(
        id: id,
        name: name,
        estimate: estimate,
        done: 0,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        name: json['name'] as String,
        estimate: json['estimate'] as int,
        done: (json['done'] as int?) ?? 0,
        createdAt: json['createdAt'] as int,
        archived: json['archived'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'estimate': estimate,
        'done': done,
        'createdAt': createdAt,
        if (archived != null) 'archived': archived,
      };

  Task copyWith({
    String? name,
    int? estimate,
    int? done,
    bool? archived,
  }) =>
      Task(
        id: id,
        name: name ?? this.name,
        estimate: estimate ?? this.estimate,
        done: done ?? this.done,
        createdAt: createdAt,
        archived: archived ?? this.archived,
      );

  double get progress =>
      estimate <= 0 ? 0.0 : (done / estimate).clamp(0.0, 1.0);

  bool get isComplete => done >= estimate;
}

/// 成就定义与视图模型。
enum AchievementVariant { accent, energy }

class AchievementDef {
  final String id;
  final String name;
  final String desc;
  final AchievementVariant variant;
  final bool Function(int streak, int total, int maxDay) rule;

  const AchievementDef({
    required this.id,
    required this.name,
    required this.desc,
    required this.variant,
    required this.rule,
  });
}

/// 带解锁状态的成就视图。
class AchievementView {
  final AchievementDef def;
  final bool unlocked;

  const AchievementView({required this.def, required this.unlocked});

  String get id => def.id;
  String get name => def.name;
  String get desc => def.desc;
  AchievementVariant get variant => def.variant;
}

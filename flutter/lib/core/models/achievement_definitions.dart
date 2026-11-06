import 'achievement.dart';

/// 成就定义清单（纯本地，对照 H5 S12）。
/// rule 入参：streak=当前连续天数，total=累计番茄数，maxDay=单日最多番茄数。
final List<AchievementDef> achievementDefs = [
  AchievementDef(
    id: 'first',
    name: '初次点亮',
    desc: '完成第一个番茄',
    variant: AchievementVariant.accent,
    rule: (streak, total, maxDay) => total >= 1,
  ),
  AchievementDef(
    id: 'streak7',
    name: '七日成晶',
    desc: '连续专注 7 天',
    variant: AchievementVariant.energy,
    rule: (streak, total, maxDay) => streak >= 7,
  ),
  AchievementDef(
    id: 'day10',
    name: '十日十番茄',
    desc: '单日完成 10 个番茄',
    variant: AchievementVariant.accent,
    rule: (streak, total, maxDay) => maxDay >= 10,
  ),
  AchievementDef(
    id: 'total100',
    name: '百分宝石',
    desc: '累计完成 100 个番茄',
    variant: AchievementVariant.energy,
    rule: (streak, total, maxDay) => total >= 100,
  ),
];
